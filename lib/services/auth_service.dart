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
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final doc =
          await _firestore.collection('users').doc(credential.user!.uid).get();

      if (!doc.exists) {
        if (email == 'shalini@admin.com') {
          debugPrint('AuthService: Super Admin profile missing in Firestore. Syncing...');
          await seedSuperAdmin();
          final retryDoc = await _firestore.collection('users').doc(credential.user!.uid).get();
          if (retryDoc.exists) return UserModel.fromFirestore(retryDoc);
        }
        throw Exception('User profile not found. Please sign up again.');
      }

      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      // If superadmin login fails because user doesn't exist, try seeding first
      if (email == 'shalini@admin.com' && (e.code == 'user-not-found' || e.code == 'invalid-credential')) {
        debugPrint('AuthService: Super Admin user not found or invalid. Attempting to seed...');
        await seedSuperAdmin();
        // After seeding, try signing in again with the original credentials
        final credential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        final doc = await _firestore.collection('users').doc(credential.user!.uid).get();
        if (doc.exists) return UserModel.fromFirestore(doc);
        throw Exception('Super Admin profile could not be created.');
      }
      rethrow;
    }
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

    // Try primary
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: primaryEmail,
        password: password,
      );
      
      final superAdmin = UserModel(
        uid: userCredential.user!.uid,
        name: 'Shalini Admin',
        email: primaryEmail,
        role: UserRole.superAdmin,
        createdAt: DateTime.now(),
        isVerified: true,
        verificationStatus: VerificationStatus.approved,
      );

      await _firestore.collection('users').doc(superAdmin.uid).set(superAdmin.toMap());
      debugPrint('AuthService: Primary Super Admin seeded successfully: $primaryEmail');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        debugPrint('AuthService: Primary admin $primaryEmail already exists in Auth. Checking Firestore...');
        final users = await _firestore.collection('users').where('email', isEqualTo: primaryEmail).get();
        if (users.docs.isEmpty) {
          debugPrint('AuthService: Auth exists but Firestore missing. Seeding Firestore record...');
          // We don't have the UID easily without signing in, but we can't sign in if password is unknown.
          // This is a recovery edge case.
        } else {
          debugPrint('AuthService: Primary admin already fully seeded.');
        }
      } else {
        debugPrint('AuthService: Primary seeding error: ${e.message}');
      }
    }

    // Try secondary backup
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: secondaryEmail,
        password: password,
      );
      
      final superAdmin = UserModel(
        uid: userCredential.user!.uid,
        name: 'System Admin',
        email: secondaryEmail,
        role: UserRole.superAdmin,
        createdAt: DateTime.now(),
        isVerified: true,
        verificationStatus: VerificationStatus.approved,
      );

      await _firestore.collection('users').doc(superAdmin.uid).set(superAdmin.toMap());
      debugPrint('AuthService: Secondary Super Admin seeded successfully: $secondaryEmail');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        debugPrint('AuthService: Secondary admin $secondaryEmail already exists.');
      } else {
        debugPrint('AuthService: Secondary seeding error: ${e.message}');
      }
    }
  }

  Future<void> adminWipeData(String adminUid) async {
    debugPrint('AuthService: Admin Wiping Data for admin: $adminUid');
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

  Future<void> adminWipeData(String adminUid) async {
    const email = 'shalini@admin.com';
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
      final collections = ['donations', 'emergencyRequests', 'notifications', 'users'];
      
      for (final coll in collections) {
        final querySnapshot = await secondaryFirestore.collection(coll).get(const GetOptions(source: Source.server));
        
        for (final doc in querySnapshot.docs) {
          final data = doc.data();
          final userEmail = data['email'] as String?;
          
          if (doc.id == adminUid || userEmail == email) {
            if (doc.id == adminUid) continue;
            batch.delete(doc.reference);
          } else {
            batch.delete(doc.reference);
          }
        }
      }
      
      await batch.commit();
      await secondaryAuth.signOut();
      debugPrint('AuthService: Wipe complete.');
    } catch (e) {
      debugPrint('AuthService: Wipe failed: $e');
      rethrow;
    }
  }
}
