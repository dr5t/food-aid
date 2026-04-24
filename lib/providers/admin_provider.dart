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
  final Set<String> _localHiddenUids = {}; // Local blacklist to hide "ghost" records immediately

  StreamSubscription? _pendingSub;
  StreamSubscription? _usersSub;
  StreamSubscription? _employeesSub;
  StreamSubscription? _statsSub;


  List<UserModel> get pendingVerifications => 
      _pendingVerifications.where((u) => !_localHiddenUids.contains(u.uid)).toList();
  
  List<UserModel> get allUsers => 
      _allUsers.where((u) => !_localHiddenUids.contains(u.uid)).toList();

  List<UserModel> get adminEmployees => 
      _adminEmployees.where((u) => !_localHiddenUids.contains(u.uid)).toList();

  Map<String, int> get platformStats => _platformStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get pendingCount => pendingVerifications.length;


  void startListening() {
    _isLoading = true;
    notifyListeners();

    _pendingSub?.cancel();
    _pendingSub = _firestoreService.getPendingVerifications().listen((list) {
      _pendingVerifications = list;
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
    });
  }

  Future<void> refreshStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    startListening();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }


  Future<bool> approveUser(String uid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      try {
        await _firestoreService.approveUser(uid);
      } catch (e) {
        debugPrint('AdminProvider: Direct approval failed, trying bypass: $e');
        await _authService.adminApproveUser(uid);
      }

      _localHiddenUids.add(uid);
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

      try {
        await _firestoreService.rejectUser(uid, reason);
      } catch (e) {
        debugPrint('AdminProvider: Direct rejection failed, trying bypass: $e');
        await _authService.adminRejectUser(uid, reason);
      }

      _localHiddenUids.add(uid);
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

  Future<bool> deleteUser(String uid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      try {
        await _firestoreService.deleteUser(uid);
      } catch (e) {
        debugPrint('AdminProvider: Direct deletion failed, trying bypass: $e');
        await _authService.adminDeleteUser(uid);
      }
      
      _localHiddenUids.add(uid);
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
      
      final uids = _pendingVerifications.map((u) => u.uid).toList();
      for (final uid in uids) {
        try {
          await _firestoreService.deleteUser(uid);
        } catch (e) {
          await _authService.adminDeleteUser(uid);
        }
        _localHiddenUids.add(uid);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to clear all: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> factoryReset(String adminUid) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      // 1. Clear local UI state
      _localHiddenUids.clear();
      
      // 2. Perform server-side total wipe
      await _firestoreService.factoryReset(adminUid);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Factory reset failed: $e';
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

      final data = {
        'name': name,
        'email': email,
        'role': UserRole.admin.name,
        'verificationStatus': VerificationStatus.approved.name,
        'isVerified': true,
        'createdAt': DateTime.now().toIso8601String(),
        'createdBy': createdByUid,
        'phone': phone,
      };

      final user = await _authService.adminCreateUser(
        email: email,
        password: password,
        data: data,
      );

      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
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
