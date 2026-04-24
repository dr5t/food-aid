import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';
import '../../config/navigation/navigator_key.dart';

class AdminProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService = AuthService();

  List<UserModel> _pendingVerifications = [];
  List<UserModel> _allUsers = [];
  List<UserModel> _adminEmployees = [];
  Map<String, dynamic> _platformStats = {};
  bool _isLoading = false;
  String? _error;

  StreamSubscription? _pendingSub;
  StreamSubscription? _allUsersSub;
  StreamSubscription? _statsSub;

  List<String> _localHiddenUids = [];
  List<String> _persistentDeletedUids = [];

  AdminProvider(this._firestoreService) {
    _init();
  }

  Future<void> _init() async {
    await _loadDeletedUids();
    
    _pendingSub?.cancel();
    _pendingSub = _firestoreService.getPendingVerifications().listen((users) {
      _pendingVerifications = users;
      notifyListeners();
    });

    _allUsersSub?.cancel();
    _allUsersSub = _firestoreService.getAllUsers().listen((users) {
      _allUsers = users;
      notifyListeners();
    });

    _statsSub?.cancel();
    _statsSub = _firestoreService.getPlatformStats().listen((stats) {
      _platformStats = stats;
      notifyListeners();
    });
  }

  void startListening() {
    _init();
  }

  Future<void> refreshStats() async {
    _init();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _loadDeletedUids() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('deleted_uids') ?? [];
      _persistentDeletedUids = list;
      notifyListeners();
    } catch (e) {
      debugPrint('AdminProvider: Failed to load deleted UIDs: $e');
    }
  }

  Future<void> _persistDeletedUid(String uid) async {
    try {
      _persistentDeletedUids.add(uid);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('deleted_uids', _persistentDeletedUids.toList());
      notifyListeners();
    } catch (e) {
      debugPrint('AdminProvider: Failed to persist deleted UID: $e');
    }
  }

  List<UserModel> get pendingVerifications => 
      _pendingVerifications.where((u) => !_localHiddenUids.contains(u.uid) && !_persistentDeletedUids.contains(u.uid)).toList();
  
  List<UserModel> get allUsers => 
      _allUsers.where((u) => !_localHiddenUids.contains(u.uid) && !_persistentDeletedUids.contains(u.uid)).toList();
  
  List<UserModel> get adminEmployees => 
      _adminEmployees.where((u) => !_localHiddenUids.contains(u.uid) && !_persistentDeletedUids.contains(u.uid)).toList();

  int get pendingCount => pendingVerifications.length;
  int get userCount => allUsers.length;
  int get employeeCount => adminEmployees.length;
  Map<String, dynamic> get platformStats => _platformStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> approveUser(String uid) async {
    try {
      _localHiddenUids.add(uid);
      notifyListeners();

      try {
        await _firestoreService.approveUser(uid);
      } catch (e) {
        await _authService.adminApproveUser(uid);
      }

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('User approved successfully'), backgroundColor: Colors.green),
      );
      return true;
    } catch (e) {
      _localHiddenUids.remove(uid);
      notifyListeners();
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Failed to approve user: $e'), backgroundColor: Colors.red),
      );
      return false;
    }
  }

  Future<bool> rejectUser(String uid, String reason) async {
    try {
      _localHiddenUids.add(uid);
      notifyListeners();

      try {
        await _firestoreService.rejectUser(uid, reason);
      } catch (e) {
        await _authService.adminRejectUser(uid, reason);
      }

      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('User rejected successfully'), backgroundColor: Colors.orange),
      );
      return true;
    } catch (e) {
      _localHiddenUids.remove(uid);
      notifyListeners();
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(content: Text('Failed to reject user: $e'), backgroundColor: Colors.red),
      );
      return false;
    }
  }

  Future<bool> deleteUser(String uid) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      _localHiddenUids.add(uid);
      await _persistDeletedUid(uid);
      
      try {
        await _firestoreService.deleteUser(uid);
      } catch (e) {
        await _authService.adminDeleteUser(uid).catchError((_){});
      }
      
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
        _localHiddenUids.add(uid);
        await _persistDeletedUid(uid);
        try {
          await _firestoreService.deleteUser(uid);
        } catch (e) {
          await _authService.adminDeleteUser(uid).catchError((_){});
        }
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

      for (var u in _pendingVerifications) await _persistDeletedUid(u.uid);
      for (var u in _allUsers) if(u.uid != adminUid) await _persistDeletedUid(u.uid);
      
      _localHiddenUids.clear();
      _pendingVerifications = [];
      _allUsers = [];
      _adminEmployees = [];
      _platformStats = {};
      notifyListeners();

      await _authService.adminWipeData(adminUid);
      
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
      _error = null;
      notifyListeners();

      final newUser = await _authService.createUserWithCredentials(
        name: name,
        email: email,
        password: password,
        role: UserRole.admin,
        createdByUid: createdByUid,
        phone: phone,
      );

      _adminEmployees.insert(0, newUser);
      _isLoading = false;
      notifyListeners();
      return newUser;
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
    _allUsersSub?.cancel();
    _statsSub?.cancel();
    super.dispose();
  }
}
