import 'dart:async';
import 'package:flutter/material.dart';
import '../models/donation_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class LogisticsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  LogisticsProvider(this._firestoreService);

  List<DonationModel> _companyDonations = [];
  List<UserModel> _employees = [];
  List<DonationModel> _unassignedDonations = [];

  List<DonationModel> _activeTasks = [];
  List<DonationModel> _completedTasks = [];

  Map<String, int> _companyStats = {};
  Map<String, int> _employeeStats = {};
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _companySub;
  StreamSubscription? _employeesSub;
  StreamSubscription? _unassignedSub;
  StreamSubscription? _activeTasksSub;
  StreamSubscription? _completedTasksSub;
  StreamSubscription? _companyStatsSub;
  StreamSubscription? _employeeStatsSub;


  List<DonationModel> get companyDonations => _companyDonations;
  List<UserModel> get employees => _employees;
  List<DonationModel> get unassignedDonations => _unassignedDonations;
  List<DonationModel> get activeTasks => _activeTasks;
  List<DonationModel> get completedTasks => _completedTasks;
  List<DonationModel> get employeeTasks => [..._activeTasks, ..._completedTasks];
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, int> get companyStats => _companyStats;
  Map<String, int> get employeeStats => _employeeStats;


  void listenCompanyData(String companyId) {
    _companySub?.cancel();
    _employeesSub?.cancel();
    _unassignedSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _companySub =
        _firestoreService.getDonationsByCompany(companyId).listen((list) {
      _companyDonations = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });

    _employeesSub =
        _firestoreService.getEmployeesByCompany(companyId).listen((list) {
      _employees = list;
      notifyListeners();
    });

    _unassignedSub =
        _firestoreService.getAcceptedUnassignedDonations().listen((list) {
      _unassignedDonations = list;
      notifyListeners();
    });
 
    listenCompanyStats(companyId);
  }
 
  void listenCompanyStats(String companyId) {
    _companyStatsSub?.cancel();
    _companyStatsSub = _firestoreService.getCompanyStats(companyId).listen((stats) {
      _companyStats = stats;
      notifyListeners();
    });
  }


  void listenEmployeeData(String employeeId) {
    _activeTasksSub?.cancel();
    _completedTasksSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _activeTasksSub =
        _firestoreService.getActiveEmployeeDonations(employeeId).listen((list) {
      _activeTasks = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });

    _completedTasksSub =
        _firestoreService.getCompletedEmployeeDonations(employeeId).listen(
            (list) {
      _completedTasks = list;
      notifyListeners();
    });
 
    listenEmployeeStats(employeeId);
  }
 
  void listenEmployeeStats(String employeeId) {
    _employeeStatsSub?.cancel();
    _employeeStatsSub = _firestoreService.getEmployeeStats(employeeId).listen((stats) {
      _employeeStats = stats;
      notifyListeners();
    });
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

  Future<void> unassignEmployee(String donationId) async {
    await _firestoreService.unassignEmployee(donationId);
  }


  Future<void> markPicked(String donationId) async {
    await _firestoreService.updateDonationStatus(
      donationId,
      DonationStatus.picked,
    );
  }

  Future<void> markInTransit(String donationId) async {
    await _firestoreService.updateDonationStatus(
      donationId,
      DonationStatus.inTransit,
    );
  }

  Future<void> markNearLocation(String donationId) async {
    await _firestoreService.updateDonationStatus(
      donationId,
      DonationStatus.nearLocation,
    );
  }

  Future<void> markDelivered(String donationId) async {
    await _firestoreService.updateDonationStatus(
      donationId,
      DonationStatus.delivered,
    );
  }

  void listenEmployeeTasks(String employeeId) {
    listenEmployeeData(employeeId);
  }

  Future<void> updateDeliveryStatus(
      String donationId, DonationStatus status) async {
    await _firestoreService.updateDonationStatus(donationId, status);
  }


  @override
  void dispose() {
    _companySub?.cancel();
    _employeesSub?.cancel();
    _unassignedSub?.cancel();
    _activeTasksSub?.cancel();
    _completedTasksSub?.cancel();
    _companyStatsSub?.cancel();
    _employeeStatsSub?.cancel();
    super.dispose();
  }
}
