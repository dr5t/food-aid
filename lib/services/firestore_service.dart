import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation_model.dart';
import '../models/user_model.dart';
import '../models/emergency_request_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _donations => _firestore.collection('donations');
  CollectionReference get _users => _firestore.collection('users');
  CollectionReference get _notifications =>
      _firestore.collection('notifications');
  CollectionReference get _emergencyRequests =>
      _firestore.collection('emergencyRequests');

  // ═══════════════════════════════════════════════════════════════════
  // DONATION CRUD
  // ═══════════════════════════════════════════════════════════════════

  Future<String> createDonation(DonationModel donation) async {
    final doc = await _donations.add(donation.toMap());
    return doc.id;
  }

  Stream<DonationModel> getDonationStream(String donationId) {
    return _donations.doc(donationId).snapshots().map(
          (doc) => DonationModel.fromFirestore(doc),
        );
  }

  // ─── Donor queries ────────────────────────────────────────────────

  Stream<List<DonationModel>> getDonationsByDonor(String donorId) {
    return _donations
        .where('donorId', isEqualTo: donorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => DonationModel.fromFirestore(d)).toList());
  }

  Stream<List<DonationModel>> getActiveDonationsByDonor(String donorId) {
    return _donations
        .where('donorId', isEqualTo: donorId)
        .where('status',
            whereNotIn: ['delivered', 'rejected', 'expired'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => DonationModel.fromFirestore(d)).toList());
  }

  // ─── NGO queries ──────────────────────────────────────────────────

  Stream<List<DonationModel>> getPendingDonations() {
    return _donations
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => DonationModel.fromFirestore(d)).toList());
  }

  Stream<List<DonationModel>> getDonationsByNgo(String ngoId) {
    return _donations
        .where('ngoId', isEqualTo: ngoId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => DonationModel.fromFirestore(d)).toList());
  }

  Stream<List<DonationModel>> getActiveDonationsByNgo(String ngoId) {
    return _donations
        .where('ngoId', isEqualTo: ngoId)
        .where('status',
            whereNotIn: ['delivered', 'rejected', 'expired', 'pending'])
        .snapshots()
        .map((s) =>
            s.docs.map((d) => DonationModel.fromFirestore(d)).toList());
  }

  // ─── Logistics queries ────────────────────────────────────────────

  Stream<List<DonationModel>> getDonationsByCompany(String companyId) {
    return _donations
        .where('companyId', isEqualTo: companyId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => DonationModel.fromFirestore(d)).toList());
  }

  Stream<List<DonationModel>> getActiveEmployeeDonations(String employeeId) {
    return _donations
        .where('employeeId', isEqualTo: employeeId)
        .where('status', whereIn: ['assigned', 'picked', 'inTransit', 'nearLocation'])
        .snapshots()
        .map((s) =>
            s.docs.map((d) => DonationModel.fromFirestore(d)).toList());
  }

  Stream<List<DonationModel>> getCompletedEmployeeDonations(
      String employeeId) {
    return _donations
        .where('employeeId', isEqualTo: employeeId)
        .where('status', isEqualTo: 'delivered')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => DonationModel.fromFirestore(d)).toList());
  }

  Stream<List<DonationModel>> getAcceptedUnassignedDonations() {
    return _donations
        .where('status', isEqualTo: 'accepted')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => DonationModel.fromFirestore(d)).toList());
  }

  Stream<List<DonationModel>> getAllDonations() {
    return _donations
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => DonationModel.fromFirestore(d)).toList());
  }

  // ═══════════════════════════════════════════════════════════════════
  // DONATION STATUS UPDATES
  // ═══════════════════════════════════════════════════════════════════

  Future<void> updateDonationStatus(
    String donationId,
    DonationStatus status, {
    String? rejectionReason,
  }) async {
    final updates = <String, dynamic>{
      'status': status.name,
      'updatedAt': Timestamp.now(),
    };
    if (rejectionReason != null) updates['rejectionReason'] = rejectionReason;
    await _donations.doc(donationId).update(updates);
  }

  // NGO accepts a donation
  Future<void> acceptDonation(
    String donationId,
    String ngoId,
    String ngoName, {
    String? deliveryAddress,
    GeoPoint? deliveryLocation,
  }) async {
    await _donations.doc(donationId).update({
      'ngoId': ngoId,
      'ngoName': ngoName,
      'status': DonationStatus.accepted.name,
      'deliveryAddress': deliveryAddress,
      'deliveryLocation': deliveryLocation,
      'updatedAt': Timestamp.now(),
    });
  }

  // Reject donation
  Future<void> rejectDonation(
    String donationId,
    String reason,
  ) async {
    await _donations.doc(donationId).update({
      'status': DonationStatus.rejected.name,
      'rejectionReason': reason,
      'updatedAt': Timestamp.now(),
    });
  }

  // Logistics company assigns an employee
  Future<void> assignEmployee(
    String donationId,
    String companyId,
    String companyName,
    String employeeId,
    String employeeName,
  ) async {
    await _donations.doc(donationId).update({
      'companyId': companyId,
      'companyName': companyName,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'status': DonationStatus.assigned.name,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> unassignEmployee(String donationId) async {
    await _donations.doc(donationId).update({
      'companyId': null,
      'companyName': null,
      'employeeId': null,
      'employeeName': null,
      'status': DonationStatus.accepted.name,
      'updatedAt': Timestamp.now(),
    });
  }

  // Update live location during delivery
  Future<void> updateDeliveryLocation(
    String donationId,
    GeoPoint location,
  ) async {
    await _donations.doc(donationId).update({
      'currentLocation': location,
      'updatedAt': Timestamp.now(),
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // EMERGENCY REQUESTS
  // ═══════════════════════════════════════════════════════════════════

  Future<String> createEmergencyRequest(
      EmergencyRequestModel request) async {
    final doc = await _emergencyRequests.add(request.toMap());
    return doc.id;
  }

  Stream<List<EmergencyRequestModel>> getOpenEmergencyRequests() {
    return _emergencyRequests
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => EmergencyRequestModel.fromFirestore(d))
            .toList());
  }

  Stream<List<EmergencyRequestModel>> getEmergencyRequestsByNgo(
      String ngoId) {
    return _emergencyRequests
        .where('ngoId', isEqualTo: ngoId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) => EmergencyRequestModel.fromFirestore(d))
            .toList());
  }

  Future<void> donorAcceptEmergency(
    String requestId,
    String donorId,
    String donorName,
  ) async {
    await _emergencyRequests.doc(requestId).update({
      'donorId': donorId,
      'donorName': donorName,
      'status': EmergencyStatus.donorAccepted.name,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateEmergencyStatus(
    String requestId,
    EmergencyStatus status,
  ) async {
    await _emergencyRequests.doc(requestId).update({
      'status': status.name,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> assignEmployeeToEmergency(
    String requestId,
    String companyId,
    String companyName,
    String employeeId,
    String employeeName,
  ) async {
    await _emergencyRequests.doc(requestId).update({
      'companyId': companyId,
      'companyName': companyName,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'status': EmergencyStatus.assigned.name,
      'updatedAt': Timestamp.now(),
    });
  }

  // ═══════════════════════════════════════════════════════════════════
  // USER & ROLE MANAGEMENT
  // ═══════════════════════════════════════════════════════════════════

  Stream<List<UserModel>> getUsersByRole(UserRole role) {
    return _users
        .where('role', isEqualTo: role.name)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  Stream<List<UserModel>> getEmployeesByCompany(String companyId) {
    return _users
        .where('companyId', isEqualTo: companyId)
        .where('role', isEqualTo: 'logisticsEmployee')
        .snapshots()
        .map((s) =>
            s.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Stream<List<UserModel>> getAllUsers() {
    return _users
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  Future<void> updateUserLocation(String uid, GeoPoint location) async {
    await _users.doc(uid).update({'location': location});
  }

  // ─── Admin Verification ────────────────────────────────────────────

  /// Stream of all users with pending verification status (NGOs + Logistics Companies)
  Stream<List<UserModel>> getPendingVerifications() {
    return _users
        .where('verificationStatus', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  /// Approve a user registration
  Future<void> approveUser(String uid) async {
    await _users.doc(uid).update({
      'verificationStatus': VerificationStatus.approved.name,
      'isVerified': true,
    });
  }

  /// Reject a user registration with a reason
  Future<void> rejectUser(String uid, String reason) async {
    await _users.doc(uid).update({
      'verificationStatus': VerificationStatus.rejected.name,
      'isVerified': false,
      'rejectionReason': reason,
    });
  }

  /// Stream of all admin employees (created by an admin)
  Stream<List<UserModel>> getAdminEmployees() {
    return _users
        .where('role', isEqualTo: 'admin')
        .snapshots()
        .map((s) =>
            s.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  /// Get platform-wide statistics for the admin dashboard
  Future<Map<String, int>> getPlatformStats() async {
    final usersSnapshot = await _users.get();
    final donationsSnapshot = await _donations.get();
    final pendingSnapshot = await _users
        .where('verificationStatus', isEqualTo: 'pending')
        .get();

    int donors = 0, ngos = 0, companies = 0, employees = 0, admins = 0;
    for (final doc in usersSnapshot.docs) {
      final role = (doc.data() as Map<String, dynamic>)['role'] as String?;
      switch (role) {
        case 'donor':
          donors++;
        case 'ngo':
          ngos++;
        case 'logisticsCompany':
          companies++;
        case 'logisticsEmployee':
          employees++;
        case 'admin':
          admins++;
      }
    }

    int activeDonations = 0, completedDonations = 0;
    for (final doc in donationsSnapshot.docs) {
      final status =
          (doc.data() as Map<String, dynamic>)['status'] as String?;
      if (status == 'delivered') {
        completedDonations++;
      } else if (status != 'rejected' && status != 'expired') {
        activeDonations++;
      }
    }

    return {
      'totalUsers': usersSnapshot.docs.length,
      'donors': donors,
      'ngos': ngos,
      'companies': companies,
      'employees': employees,
      'admins': admins,
      'pendingVerifications': pendingSnapshot.docs.length,
      'totalDonations': donationsSnapshot.docs.length,
      'activeDonations': activeDonations,
      'completedDonations': completedDonations,
    };
  }

  // ═══════════════════════════════════════════════════════════════════
  // STATISTICS
  // ═══════════════════════════════════════════════════════════════════

  Future<Map<String, int>> getDonorStats(String donorId) async {
    final snapshot =
        await _donations.where('donorId', isEqualTo: donorId).get();
    int active = 0, completed = 0, pending = 0;

    for (final doc in snapshot.docs) {
      final s = (doc.data() as Map<String, dynamic>)['status'] as String?;
      switch (s) {
        case 'pending':
          pending++;
        case 'delivered':
          completed++;
        case 'rejected':
        case 'expired':
          break;
        default:
          active++;
      }
    }

    return {
      'total': snapshot.docs.length,
      'active': active,
      'completed': completed,
      'pending': pending,
    };
  }

  Future<Map<String, int>> getNgoStats(String ngoId) async {
    final snapshot =
        await _donations.where('ngoId', isEqualTo: ngoId).get();
    int active = 0, completed = 0, inTransit = 0;

    for (final doc in snapshot.docs) {
      final s = (doc.data() as Map<String, dynamic>)['status'] as String?;
      switch (s) {
        case 'delivered':
          completed++;
        case 'picked':
        case 'inTransit':
        case 'nearLocation':
          inTransit++;
        default:
          active++;
      }
    }

    // Also count pending donations available
    final pendingSnapshot =
        await _donations.where('status', isEqualTo: 'pending').get();

    return {
      'total': snapshot.docs.length,
      'active': active,
      'inTransit': inTransit,
      'completed': completed,
      'available': pendingSnapshot.docs.length,
    };
  }

  Future<Map<String, int>> getCompanyStats(String companyId) async {
    final snapshot =
        await _donations.where('companyId', isEqualTo: companyId).get();
    int active = 0, completed = 0;

    for (final doc in snapshot.docs) {
      final s = (doc.data() as Map<String, dynamic>)['status'] as String?;
      if (s == 'delivered') {
        completed++;
      } else {
        active++;
      }
    }

    final employees = await _users
        .where('companyId', isEqualTo: companyId)
        .where('role', isEqualTo: 'logisticsEmployee')
        .get();

    return {
      'total': snapshot.docs.length,
      'active': active,
      'completed': completed,
      'employees': employees.docs.length,
    };
  }

  Future<Map<String, int>> getEmployeeStats(String employeeId) async {
    final snapshot =
        await _donations.where('employeeId', isEqualTo: employeeId).get();
    int assigned = 0, picked = 0, delivered = 0;

    for (final doc in snapshot.docs) {
      final s = (doc.data() as Map<String, dynamic>)['status'] as String?;
      switch (s) {
        case 'assigned':
          assigned++;
        case 'picked':
        case 'inTransit':
        case 'nearLocation':
          picked++;
        case 'delivered':
          delivered++;
        default:
          break;
      }
    }

    return {
      'total': snapshot.docs.length,
      'assigned': assigned,
      'inTransit': picked,
      'delivered': delivered,
    };
  }

  // ═══════════════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════

  Future<void> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) async {
    await _notifications.add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': false,
      'createdAt': Timestamp.now(),
    });
  }

  // Notify all donors within radius of an emergency
  Future<void> notifyNearbyDonors(
    GeoPoint center,
    double radiusKm,
    String title,
    String body,
  ) async {
    // Get all donors
    final donorsSnapshot =
        await _users.where('role', isEqualTo: 'donor').get();

    final batch = _firestore.batch();
    for (final doc in donorsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final loc = data['location'] as GeoPoint?;
      if (loc != null) {
        final distance = _haversineDistance(
          center.latitude,
          center.longitude,
          loc.latitude,
          loc.longitude,
        );
        if (distance <= radiusKm) {
          final notifRef = _notifications.doc();
          batch.set(notifRef, {
            'userId': doc.id,
            'title': title,
            'body': body,
            'type': 'emergency',
            'isRead': false,
            'createdAt': Timestamp.now(),
          });
        }
      }
    }
    await batch.commit();
  }

  double _haversineDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * (3.141592653589793 / 180.0);

  Stream<List<Map<String, dynamic>>> getNotifications(String userId) {
    return _notifications
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map((d) {
              final data = d.data() as Map<String, dynamic>;
              data['id'] = d.id;
              return data;
            }).toList());
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _notifications.doc(notificationId).update({'isRead': true});
  }
}
