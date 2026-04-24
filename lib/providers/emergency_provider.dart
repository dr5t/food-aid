import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_request_model.dart';
import '../services/firestore_service.dart';

class EmergencyProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  EmergencyProvider(this._firestoreService);

  List<EmergencyRequestModel> _requests = [];
  List<EmergencyRequestModel> _ngoRequests = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _openSub;
  StreamSubscription? _ngoSub;

  List<EmergencyRequestModel> get openRequests => _requests;
  List<EmergencyRequestModel> get ngoRequests => _ngoRequests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<EmergencyRequestModel> get activeNgoRequests =>
      _ngoRequests.where((r) => r.isActive).toList();

  void listenOpenRequests() {
    _openSub?.cancel();
    _openSub =
        _firestoreService.getOpenEmergencyRequests().listen((list) {
      _requests = list;
      notifyListeners();
    });
  }

  void listenNgoRequests(String ngoId) {
    _ngoSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _ngoSub =
        _firestoreService.getEmergencyRequestsByNgo(ngoId).listen((list) {
      _ngoRequests = list;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  List<EmergencyRequestModel> getRequestsNear(
      GeoPoint location, double radiusKm) {
    return _requests.where((r) {
      final distance = _haversineKm(
        location.latitude,
        location.longitude,
        r.ngoLocation.latitude,
        r.ngoLocation.longitude,
      );
      return distance <= radiusKm;
    }).toList();
  }

  Future<String> createEmergencyRequest(
      EmergencyRequestModel request) async {
    _isLoading = true;
    notifyListeners();
    try {
      final id = await _firestoreService.createEmergencyRequest(request);

      await _firestoreService.notifyNearbyDonors(
        request.ngoLocation,
        request.radiusKm,
        '🚨 Emergency Food Request',
        '${request.ngoName} urgently needs ${request.quantity} ${request.mealTypeLabel} meals near ${request.ngoAddress}',
      );

      _isLoading = false;
      notifyListeners();
      return id;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> donorAcceptRequest(
    String requestId,
    String donorId,
    String donorName,
  ) async {
    await _firestoreService.donorAcceptEmergency(
      requestId,
      donorId,
      donorName,
    );
  }

  Future<void> cancelRequest(String requestId) async {
    await _firestoreService.updateEmergencyStatus(
      requestId,
      EmergencyStatus.cancelled,
    );
  }

  double _haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = (lat2 - lat1) * (3.141592653589793 / 180.0);
    final dLon = (lon2 - lon1) * (3.141592653589793 / 180.0);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (3.141592653589793 / 180.0)) *
            cos(lat2 * (3.141592653589793 / 180.0)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  @override
  void dispose() {
    _openSub?.cancel();
    _ngoSub?.cancel();
    super.dispose();
  }
}
