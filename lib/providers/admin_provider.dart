import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class AdminProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService = AuthService();

  AdminProvider(this._firestoreService);

  List<UserModel> _pendingVerifications = [];
  List<UserModel> _allUsers = [];
  List<UserModel> _adminEmployees = [];
  Map<String, int> _platformStats = {};
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _pendingSub;
  StreamSubscription? _usersSub;
  StreamSubscription? _employeesSub;
  StreamSubscription? _statsSub;


  List<UserModel> get pendingVerifications => _pendingVerifications;
  List<UserModel> get allUsers => _allUsers;
  List<UserModel> get adminEmployees => _adminEmployees;
  Map<String, int> get platformStats => _platformStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get pendingCount => _pendingVerifications.length;


  void startListening() {
    _isLoading = true;
    notifyListeners();

    _pendingSub?.cancel();
    _pendingSub =
        _firestoreService.getPendingVerifications().listen((list) {
      _pendingVerifications = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    });

    _usersSub?.cancel();
    _usersSub = _firestoreService.getAllUsers().listen((list) {
      _allUsers = list;
      notifyListeners();
    });

    _employeesSub?.cancel();
    _employeesSub = _firestoreService.getAdminEmployees().listen((list) {
      _adminEmployees = list;
      notifyListeners();
    });

    _statsSub?.cancel();
    _statsSub = _firestoreService.getPlatformStats().listen((stats) {
      _platformStats = stats;
      notifyListeners();
    }, onError: (e) {
      _error = 'Failed to load stats: $e';
      notifyListeners();
    });
  }

  Future<void> refreshStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    // Re-trigger all streams
    startListening();
  }


  Future<bool> approveUser(String uid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Attempt 1: Direct update via FirestoreService (Primary App)
      // This works if the logged-in user has proper Firestore permissions.
      try {
        await _firestoreService.approveUser(uid);
      } catch (e) {
        debugPrint('AdminProvider: Direct approval failed, trying bypass: $e');
        // Attempt 2: Bypass via Secondary App with Super Admin account
        await _authService.adminApproveUser(uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AdminProvider: approveUser error: $e');
      _error = 'Failed to approve user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectUser(String uid, String reason) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Attempt 1: Direct update via FirestoreService
      try {
        await _firestoreService.rejectUser(uid, reason);
      } catch (e) {
        debugPrint('AdminProvider: Direct rejection failed, trying bypass: $e');
        // Attempt 2: Bypass
        await _authService.adminRejectUser(uid, reason);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AdminProvider: rejectUser error: $e');
      _error = 'Failed to reject user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  Future<UserModel?> createAdminEmployee({
    required String name,
    required String email,
    required String password,
    required String createdByUid,
    String phone = '',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final user = await _authService.createUserWithCredentials(
        name: name,
        email: email,
        password: password,
        role: UserRole.admin,
        createdByUid: createdByUid,
        phone: phone,
      );

      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _error = 'Failed to create employee: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteUser(String uid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _firestoreService.deleteUser(uid);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> clearAllPendingVerifications() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // We use a copy of the list to avoid concurrent modification issues
      final uids = _pendingVerifications.map((u) => u.uid).toList();
      for (final uid in uids) {
        await _firestoreService.deleteUser(uid);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to clear requests: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }


  @override
  void dispose() {
    _pendingSub?.cancel();
    _usersSub?.cancel();
    _employeesSub?.cancel();
    _statsSub?.cancel();
    super.dispose();
  }
}
