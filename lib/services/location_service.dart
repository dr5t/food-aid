import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class LocationService {
  Future<bool> checkPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (e) {
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 5),
          ),
        );
      } catch (_) {
        
        try {
          final resp = await http.get(Uri.parse('https://ipapi.co/json/')).timeout(const Duration(seconds: 5));
          if (resp.statusCode == 200) {
            final data = jsonDecode(resp.body);
            return Position(
              latitude: data['latitude'],
              longitude: data['longitude'],
              timestamp: DateTime.now(),
              accuracy: 1000,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );
          }
        } catch (_) {}
        return null;
      }
    }
  }

  GeoPoint? positionToGeoPoint(Position? position) {
    if (position == null) return null;
    return GeoPoint(position.latitude, position.longitude);
  }

  Future<GeoPoint?> geocodeAddress(String address) async {
    try {
      if (kIsWeb) {
        
        final uri = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(address)}&format=json&limit=1');
        final resp = await http.get(uri, headers: {'User-Agent': 'FoodAid-App/1.0'});
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          if (data is List && data.isNotEmpty) {
            return GeoPoint(double.parse(data[0]['lat']), double.parse(data[0]['lon']));
          }
        }
      } else {
        final locations = await locationFromAddress(address);
        if (locations.isNotEmpty) {
          return GeoPoint(locations.first.latitude, locations.first.longitude);
        }
      }
    } catch (_) {}
    return null;
  }

  Future<String?> reverseGeocode(GeoPoint point) async {
    try {
      if (kIsWeb) {
        final uri = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json');
        final resp = await http.get(uri, headers: {'User-Agent': 'FoodAid-App/1.0'});
        if (resp.statusCode == 200) {
          final data = jsonDecode(resp.body);
          return data['display_name'];
        }
      } else {
        final placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = [
            p.street,
            p.subLocality,
            p.locality,
            p.administrativeArea,
            p.postalCode,
          ].where((s) => s != null && s.isNotEmpty);
          return parts.join(', ');
        }
      }
    } catch (_) {}
    return null;
  }

  double distanceBetween(GeoPoint a, GeoPoint b) {
    return Geolocator.distanceBetween(a.latitude, a.longitude, b.latitude, b.longitude) / 1000.0;
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50,
      ),
    );
  }
}
