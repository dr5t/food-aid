import 'dart:async';
import 'package:flutter/material.dart';
import '../models/donation_model.dart';
import '../services/firestore_service.dart';

class DonationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  DonationProvider(this._firestoreService);

  List<DonationModel> _donations = [];
  List<DonationModel> _pendingDonations = [];
  String _searchQuery = '';
  DonationStatus? _statusFilter;
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _donationsSub;
  StreamSubscription? _pendingSub;


  List<DonationModel> get donations => _donations;
  List<DonationModel> get pendingDonations => _pendingDonations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  DonationStatus? get statusFilter => _statusFilter;

  List<DonationModel> get filteredDonations {
    var result = _donations;

    if (_statusFilter != null) {
      result = result.where((d) => d.status == _statusFilter).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((d) {
        return d.title.toLowerCase().contains(q) ||
            d.donorName.toLowerCase().contains(q) ||
            d.pickupAddress.toLowerCase().contains(q) ||
            d.foodTypeLabel.toLowerCase().contains(q) ||
            d.statusLabel.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }


  void listenDonorDonations(String donorId) {
    _donationsSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _donationsSub =
        _firestoreService.getDonationsByDonor(donorId).listen((list) {
      _donations = list;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  void listenNgoDonations(String ngoId) {
    _donationsSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _donationsSub =
        _firestoreService.getDonationsByNgo(ngoId).listen((list) {
      _donations = list;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  void listenPendingDonations() {
    _pendingSub?.cancel();
    _pendingSub =
        _firestoreService.getPendingDonations().listen((list) {
      _pendingDonations = list;
      notifyListeners();
    });
  }

  void listenCompanyDonations(String companyId) {
    _donationsSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _donationsSub =
        _firestoreService.getDonationsByCompany(companyId).listen((list) {
      _donations = list;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  void listenEmployeeDonations(String employeeId) {
    _donationsSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _donationsSub =
        _firestoreService.getActiveEmployeeDonations(employeeId).listen((list) {
      _donations = list;
      _isLoading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });
  }


  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setStatusFilter(DonationStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    notifyListeners();
  }


  Future<String> createDonation(DonationModel donation) async {
    return _firestoreService.createDonation(donation);
  }

  Future<void> acceptDonation(
    String donationId,
    String ngoId,
    String ngoName, {
    String? deliveryAddress,
  }) async {
    await _firestoreService.acceptDonation(
      donationId,
      ngoId,
      ngoName,
      deliveryAddress: deliveryAddress,
    );
  }

  Future<void> rejectDonation(String donationId, String reason) async {
    await _firestoreService.rejectDonation(donationId, reason);
  }

  Future<void> updateStatus(
    String donationId,
    DonationStatus status,
  ) async {
    await _firestoreService.updateDonationStatus(donationId, status);
  }

  Future<void> assignEmployee(
    String donationId,
    String companyId,
    String companyName,
    String employeeId,
    String employeeName,
  ) async {
    await _firestoreService.assignEmployee(
      donationId,
      companyId,
      companyName,
      employeeId,
      employeeName,
    );
  }


  @override
  void dispose() {
    _donationsSub?.cancel();
    _pendingSub?.cancel();
    super.dispose();
  }
}
