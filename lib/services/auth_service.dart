import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> get currentUserModel async {
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
    String? companyId,
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
      companyId: companyId,
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
      debugPrint('AuthService: Saving user doc to Firestore (Secondary). UID: ${user.uid}, Data: $data');
      await secondaryFirestore.collection('users').doc(user.uid).set(data);

      await secondaryAuth.signOut();
      // Keep app alive for reuse
      return user;
    } catch (e) {
      // ignore: empty_catches
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
    final secondaryFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);
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
          debugPrint('AuthService: Super admin exists in Auth. Attempting sign-in...');
          try {
            final credential = await secondaryAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            uid = credential.user!.uid;
          } catch (signInError) {
            debugPrint('AuthService: Super admin sign-in failed: $signInError');
            rethrow;
          }
        } else {
          rethrow;
        }
      }

      // 2. Synchronize Firestore profile
      if (uid != null) {
        final user = UserModel(
          uid: uid,
          name: adminName,
          email: email,
          role: UserRole.superAdmin,
          isVerified: true,
          verificationStatus: VerificationStatus.approved,
          createdAt: DateTime.now(),
        );

        await secondaryFirestore.collection('users').doc(uid).set(user.toMap(), SetOptions(merge: true));
        debugPrint('AuthService: Super admin Firestore profile synchronized for UID: $uid');
      }

      await secondaryAuth.signOut();
      debugPrint('AuthService: Seeding complete.');
    } catch (e) {
      debugPrint('AuthService: Seeding failed: $e');
    }
  }

  Future<void> adminDeleteUser(String uid) async {
    const email = 'tiwarishaurya395@gmail.com';
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
      debugPrint('AuthService: AdminDelete failed: $e');
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
    const email = 'tiwarishaurya395@gmail.com';
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
      debugPrint('AuthService: AdminBypass failed: $e');
      rethrow;
    }
  }

  Future<void> adminWipeData(String adminUid) async {
    const email = 'tiwarishaurya395@gmail.com';
    const password = '123456';
    
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = Firebase.app('WipeApp');
    } catch (_) {
      secondaryApp = await Firebase.initializeApp(
        name: 'WipeApp',
        options: Firebase.app().options,
      );
    }
    
    final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    final secondaryFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);
    
    try {
      await secondaryAuth.signInWithEmailAndPassword(email: email, password: password);
      
      final batch = secondaryFirestore.batch();
      
      // Clear major collections
      final collections = ['donations', 'emergencyRequests', 'notifications', 'users'];
      for (final coll in collections) {
        final docs = await secondaryFirestore.collection(coll).get(const GetOptions(source: Source.server));
        for (final doc in docs.docs) {
          if (coll == 'users' && doc.id == adminUid) continue; // Preserve admin
          batch.delete(doc.reference);
        }
      }
      
      await batch.commit();
      await secondaryAuth.signOut();
    } catch (e) {
      debugPrint('AuthService: Wipe failed: $e');
      rethrow;
    }
  }
}
