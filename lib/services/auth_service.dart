import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel> signUp({
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
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Send verification email
    await credential.user?.sendEmailVerification();

    await credential.user?.updateDisplayName(name);

    final verificationStatus = (role == UserRole.ngo ||
            role == UserRole.logisticsCompany)
        ? VerificationStatus.pending
        : VerificationStatus.approved;

    final isVerified = verificationStatus == VerificationStatus.approved;

    final user = UserModel(
      uid: credential.user!.uid,
      name: name,
      email: email,
      role: role,
      phone: phone,
      createdAt: DateTime.now(),
      donorType: donorType,
      organizationName: organizationName,
      organizationDescription: organizationDescription,
      companyId: companyId,
      address: address,
      location: location,
      isVerified: isVerified,
      verificationStatus: verificationStatus,
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

    final doc =
        await _firestore.collection('users').doc(credential.user!.uid).get();

    if (!doc.exists) {
      if (email == 'tiwarishaurya395@gmail.com') {
        debugPrint('AuthService: Super Admin profile missing in Firestore. Syncing...');
        await seedSuperAdmin();
        // Re-fetch doc
        final retryDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
        if (retryDoc.exists) return UserModel.fromFirestore(retryDoc);
      }
      throw Exception('User profile not found. Please sign up again.');
    }

    return UserModel.fromFirestore(doc);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

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

  Future<void> updateProfile({
    required String uid,
    String? name,
    String? phone,
    String? avatarUrl,
    String? address,
    GeoPoint? location,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;
    if (address != null) updates['address'] = address;
    if (location != null) updates['location'] = location;

    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updates);
    }

    if (name != null) {
      await _auth.currentUser?.updateDisplayName(name);
    }
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
      debugPrint('AuthService: Saving user doc to Firestore. UID: ${user.uid}, Data: $data');
      await _firestore.collection('users').doc(user.uid).set(data);

      await secondaryAuth.signOut();
      await secondaryApp.delete();

      return user;
    } catch (e) {
      // ignore: empty_catches
      try { await secondaryAuth.signOut(); } catch (_) {}
      // ignore: empty_catches
      try { await secondaryApp.delete(); } catch (_) {}
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
    const email = 'tiwarishaurya395@gmail.com';
    const password = '123456';
    const adminName = 'Super Admin';

    debugPrint('AuthService: Starting super admin seeding via secondary app...');
    
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = Firebase.app('SeedingApp');
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: 'SeedingApp',
        options: Firebase.app().options,
      );
    }
    
    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    String? uid;

    try {
      // 1. Try to create the user
      try {
        final credential = await secondaryAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        uid = credential.user!.uid;
        await credential.user?.updateDisplayName(adminName);
        debugPrint('AuthService: Created new super admin via secondary app.');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          debugPrint('AuthService: Super admin exists in Auth. Attempting sign-in to sync profile...');
          try {
            final credential = await secondaryAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            uid = credential.user!.uid;
            debugPrint('AuthService: Signed in to existing super admin via secondary app.');
          } catch (signInErr) {
            debugPrint('AuthService: Sign-in failed (possibly wrong password): $signInErr');
          }
        } else {
          rethrow;
        }
      }

      // 2. Sync Firestore profile if we have a UID
      if (uid != null) {
        final user = UserModel(
          uid: uid,
          name: adminName,
          email: email,
          role: UserRole.superAdmin,
          createdAt: DateTime.now(),
          isVerified: true,
          verificationStatus: VerificationStatus.approved,
        );

        // We use the main Firestore instance but we are now "authenticated" in the eyes of Firebase? 
        // Wait, Firestore instance is shared, but Auth state is app-specific.
        // However, if rules allow "read if true" for this specific doc or similar, it might work.
        // If not, we'll try to use the main Auth to sign in briefly.
        
        await _firestore.collection('users').doc(uid).set(user.toMap(), SetOptions(merge: true));
        debugPrint('AuthService: Super admin Firestore profile synchronized for UID: $uid');
      }

      await secondaryAuth.signOut();
      await secondaryApp.delete();
      debugPrint('AuthService: Seeding complete.');
    } catch (e, stack) {
      // ignore: empty_catches
      try { await secondaryApp?.delete(); } catch (_) {}
      debugPrint('AuthService: Seeding failed: $e');
      debugPrint('AuthService: Stack trace: $stack');
    }
  }
}
