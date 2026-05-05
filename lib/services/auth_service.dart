import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> userStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? organizationName,
    String? organizationDescription,
    String? companyId,
    String? address,
    GeoPoint? location,
    DonorType? donorType,
    String phone = '',
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      role: role,
      phone: phone,
      createdAt: DateTime.now(),
      isVerified: false,
      verificationStatus: VerificationStatus.pending,
      organizationName: organizationName,
      organizationDescription: organizationDescription,
      companyId: companyId,
      address: address,
      location: location,
      donorType: donorType,
    );

    await _firestore.collection('users').doc(user.uid).set(user.toMap());
    return user;
  }

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final doc = await _firestore.collection('users').doc(credential.user!.uid).get();

    if (!doc.exists) {
      throw Exception('User profile not found in database.');
    }

    return UserModel.fromFirestore(doc);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? avatarUrl,
    String? address,
    GeoPoint? location,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;
    if (address != null) data['address'] = address;
    if (location != null) data['location'] = location;
    data['updatedAt'] = FieldValue.serverTimestamp();
    
    if (data.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(data);
    }
  }

  Future<void> resendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<UserModel> createUserWithCredentials({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String createdByUid,
    String? companyId,
    String? organizationName,
    String phone = '',
  }) async {
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = Firebase.app('SecondaryApp');
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );
    }

    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    final secondaryFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);

    try {
      final credential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      final user = UserModel(
        uid: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        phone: phone,
        createdAt: DateTime.now(),
        companyId: companyId,
        organizationName: organizationName,
        isVerified: true,
        verificationStatus: VerificationStatus.approved,
        createdBy: createdByUid,
      );

      final data = user.toMap();
      await secondaryFirestore.collection('users').doc(user.uid).set(data);
      await secondaryAuth.signOut();
      return user;
    } catch (e) {
      
      try { await secondaryAuth.signOut(); } catch (_) {}
      rethrow;
    }
  }

  static String generatePassword({int length = 12}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%&*';
    final random = Random.secure();
    return List.generate(length, (_) => chars[random.nextInt(chars.length)])
        .join();
  }

  Future<void> seedSuperAdmin() async {
    const primaryEmail = 'shalini@admin.com';
    const secondaryEmail = 'admin@foodaid.com';
    const password = '123456';

    debugPrint('AuthService: Starting Super Admin seeding...');

    for (final email in [primaryEmail, secondaryEmail]) {
      try {
        UserCredential? credential;
        try {
          credential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          debugPrint('AuthService: Created new SuperAdmin: $email');
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            debugPrint('AuthService: SuperAdmin $email already exists in Auth. Attempting to sign in to verify.');
            try {
              credential = await _auth.signInWithEmailAndPassword(
                email: email,
                password: password,
              );
              debugPrint('AuthService: SuperAdmin $email signed in successfully.');
            } catch (signInError) {
              debugPrint('AuthService: WARNING - SuperAdmin $email exists but password "123456" is incorrect. Please delete this user from Firebase Auth manually.');
              continue; // Move to next email
            }
          } else {
            debugPrint('AuthService: FirebaseAuthException seeding $email: ${e.code} - ${e.message}');
            continue;
          }
        }

        if (credential?.user != null) {
          final user = UserModel(
            uid: credential!.user!.uid,
            name: 'Shalini Super Admin',
            email: email,
            role: UserRole.superAdmin,
            createdAt: DateTime.now(),
            isVerified: true,
            verificationStatus: VerificationStatus.approved,
          );

          await _firestore
              .collection('users')
              .doc(user.uid)
              .set(user.toMap(), SetOptions(merge: true));
          debugPrint('AuthService: SuperAdmin document ensured in Firestore for $email.');
        }
      } catch (e) {
        debugPrint('AuthService: Unexpected error seeding SuperAdmin $email: $e');
      }
    }
  }

  Future<void> adminWipeData(String adminUid) async {
    debugPrint('AuthService: Starting global data wipe for admin: $adminUid');
    
    // We use a secondary app to perform admin operations if needed, 
    // but since we are already the admin here, we can just use the main firestore instance.
    // However, the factoryReset in FirestoreService is designed for this.
    final firestoreService = FirestoreService();
    await firestoreService.factoryReset(adminUid);
  }

  Future<void> adminDeleteUser(String uid) async {
    const email = 'shalini@admin.com';
    const password = '123456';

    FirebaseApp? secondaryApp;
    try {
      secondaryApp = Firebase.app('AdminDelete');
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: 'AdminDelete',
        options: Firebase.app().options,
      );
    }

    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    final secondaryFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);

    try {
      await secondaryAuth.signInWithEmailAndPassword(email: email, password: password);
      await secondaryFirestore.collection('users').doc(uid).delete();
      await secondaryAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> adminApproveUser(String uid) async {
    await _adminBypassUpdate(uid, {
      'verificationStatus': VerificationStatus.approved.name,
      'isVerified': true,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> adminRejectUser(String uid, String reason) async {
    await _adminBypassUpdate(uid, {
      'verificationStatus': VerificationStatus.rejected.name,
      'isVerified': false,
      'rejectionReason': reason,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> _adminBypassUpdate(String targetUid, Map<String, dynamic> data) async {
    const email = 'shalini@admin.com';
    const password = '123456';

    FirebaseApp? secondaryApp;
    try {
      secondaryApp = Firebase.app('AdminBypass');
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: 'AdminBypass',
        options: Firebase.app().options,
      );
    }

    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    final secondaryFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);

    try {
      await secondaryAuth.signInWithEmailAndPassword(email: email, password: password);
      await secondaryFirestore.collection('users').doc(targetUid).update(data);
      await secondaryAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

}
