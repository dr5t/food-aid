import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isInitialized => _isInitialized;
  UserRole? get role => _user?.role;

  /// Whether the current user's verification status allows dashboard access.
  VerificationStatus? get verificationStatus => _user?.verificationStatus;
  bool get isApproved => _user?.isApproved ?? false;
  bool get isPendingVerification => _user?.isPendingVerification ?? false;
  bool get isRejected => _user?.isRejected ?? false;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        _user = await _authService.getCurrentUserModel();
      } else {
        _user = null;
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  /// Refresh user data from Firestore (e.g. after admin approves them).
  Future<void> refreshUser() async {
    final updated = await _authService.getCurrentUserModel();
    if (updated != null) {
      _user = updated;
      notifyListeners();
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String phone = '',
    DonorType? donorType,
    String? organizationName,
    String? organizationDescription,
    String? companyId,
    String? address,
    GeoPoint? location,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signUp(
        name: name,
        email: email,
        password: password,
        role: role,
        phone: phone,
        donorType: donorType,
        organizationName: organizationName,
        organizationDescription: organizationDescription,
        companyId: companyId,
        address: address,
        location: location,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      _user = await _authService.signIn(
        email: email,
        password: password,
      );
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('An unexpected error occurred. Please try again.');
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? avatarUrl,
    String? address,
    GeoPoint? location,
  }) async {
    if (_user == null) return;

    _setLoading(true);
    try {
      await _authService.updateProfile(
        uid: _user!.uid,
        name: name,
        phone: phone,
        avatarUrl: avatarUrl,
        address: address,
        location: location,
      );
      _user = _user!.copyWith(
        name: name,
        phone: phone,
        avatarUrl: avatarUrl,
        address: address,
        location: location,
      );
      _setLoading(false);
    } catch (e) {
      _setError('Failed to update profile.');
      _setLoading(false);
    }
  }

  // ─── Credential Generation (delegates to AuthService) ──────────────

  /// Create an employee account under a logistics company.
  Future<UserModel?> createLogisticsEmployee({
    required String name,
    required String email,
    required String password,
    required String companyId,
    required String companyName,
    String phone = '',
  }) async {
    if (_user == null) return null;

    try {
      final employee = await _authService.createUserWithCredentials(
        name: name,
        email: email,
        password: password,
        role: UserRole.logisticsEmployee,
        createdByUid: _user!.uid,
        companyId: companyId,
        organizationName: companyName,
        phone: phone,
      );
      return employee;
    } catch (e) {
      _setError('Failed to create employee: $e');
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
