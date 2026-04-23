import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      throw Exception('User profile not found. Please sign up again.');
    }

    return UserModel.fromFirestore(doc);
  }

  Future<void> signOut() async {
    await _auth.signOut();
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

      await _firestore.collection('users').doc(user.uid).set(user.toMap());

      await secondaryAuth.signOut();

      return user;
    } catch (e) {
      await secondaryAuth.signOut();
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

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        try {
          final credential = await _auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          await credential.user?.updateDisplayName(adminName);

          final user = UserModel(
            uid: credential.user!.uid,
            name: adminName,
            email: email,
            role: UserRole.superAdmin,
            createdAt: DateTime.now(),
            isVerified: true,
            verificationStatus: VerificationStatus.approved,
          );

          await _firestore.collection('users').doc(user.uid).set(user.toMap());
          await _auth.signOut();
          debugPrint('AuthService: Super Admin seeded successfully: $email');
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            // Already exists in Auth but not in Firestore or under a different query
            // Just update role if found later or log it
            debugPrint('AuthService: Email already in use by another user.');
          }
        }
      } else {
        final doc = snapshot.docs.first;
        if (doc['role'] != UserRole.superAdmin.name) {
          await doc.reference.update({'role': UserRole.superAdmin.name});
          debugPrint('AuthService: Updated existing user to Super Admin.');
        }
      }
    } catch (e) {
      debugPrint('AuthService: Seeding super admin failed: $e');
    }
  }
}
