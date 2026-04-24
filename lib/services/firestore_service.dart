import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import '../models/donation_model.dart';
import '../models/user_model.dart';
import '../models/emergency_request_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String usersPath = 'users';
  static const String donationsPath = 'donations';
  static const String notificationsPath = 'notifications';
  static const String emergencyRequestsPath = 'emergencyRequests';

  CollectionReference get _donations => _firestore.collection(donationsPath);
  CollectionReference get _users => _firestore.collection(usersPath);
  CollectionReference get _notifications =>
      _firestore.collection(notificationsPath);
  CollectionReference get _emergencyRequests =>
      _firestore.collection(emergencyRequestsPath);

  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    Query query = _firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    final Stream<QuerySnapshot> snapshots = query.snapshots();
    return snapshots.map((snapshot) {
      final result = snapshot.docs
          .map((snapshot) =>
              builder(snapshot.data() as Map<String, dynamic>, snapshot.id))
          .where((value) => value != null)
          .toList();
      if (sort != null) {
        result.sort(sort);
      }
      return result;
    });
  }

  Stream<T> documentStream<T>({
    required String path,
    required T Function(Map<String, dynamic> data, String documentId) builder,
  }) {
    final DocumentReference reference = _firestore.doc(path);
    final Stream<DocumentSnapshot> snapshots = reference.snapshots();
    return snapshots.map((snapshot) =>
        builder(snapshot.data() as Map<String, dynamic>, snapshot.id));
  }


  Future<String> createDonation(DonationModel donation) async {
    final doc = await _donations.add(donation.toMap());
    return doc.id;
  }

  Stream<DonationModel> getDonationStream(String donationId) {
    return _donations.doc(donationId).snapshots().map(
          (doc) => DonationModel.fromFirestore(doc),
        );
  }


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

  Future<void> updateDeliveryLocation(
    String donationId,
    GeoPoint location,
  ) async {
    await _donations.doc(donationId).update({
      'currentLocation': location,
      'updatedAt': Timestamp.now(),
    });
  }


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


  Stream<List<UserModel>> getPendingVerifications() {
    return _users
        .where('verificationStatus', isEqualTo: 'pending')
        .snapshots()
        .map((s) =>
            s.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  Future<void> approveUser(String uid) async {
    await _users.doc(uid).update({
      'verificationStatus': VerificationStatus.approved.name,
      'isVerified': true,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> rejectUser(String uid, String reason) async {
    await _users.doc(uid).update({
      'verificationStatus': VerificationStatus.rejected.name,
      'isVerified': false,
      'rejectionReason': reason,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteUser(String uid) async {
    await _users.doc(uid).delete();
  }

  Stream<List<UserModel>> getAdminEmployees() {
    return _users
        .where('role', isEqualTo: 'admin')
        .snapshots()
        .map((s) =>
            s.docs.map((d) => UserModel.fromFirestore(d)).toList());
  }

  Stream<Map<String, int>> getPlatformStats() {
    return Rx.combineLatest2(
      _users.snapshots(),
      _donations.snapshots(),
      (usersSnapshot, donationsSnapshot) {
        int donors = 0, ngos = 0, companies = 0, employees = 0, admins = 0;
        int pendingVerifications = 0;

        for (final doc in usersSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final role = data['role'] as String?;
          final vStatus = data['verificationStatus'] as String?;

          if (vStatus == 'pending') pendingVerifications++;

          switch (role) {
            case 'donor':
              donors++;
              break;
            case 'ngo':
              ngos++;
              break;
            case 'logisticsCompany':
              companies++;
              break;
            case 'logisticsEmployee':
              employees++;
              break;
            case 'admin':
            case 'superAdmin':
              admins++;
              break;
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
          'pendingVerifications': pendingVerifications,
          'totalDonations': donationsSnapshot.docs.length,
          'activeDonations': activeDonations,
          'completedDonations': completedDonations,
        };
      },
    );
  }

  Stream<Map<String, int>> getDonorStats(String donorId) {
    return _donations.where('donorId', isEqualTo: donorId).snapshots().map((snapshot) {
      int active = 0, completed = 0, pending = 0;

      for (final doc in snapshot.docs) {
        final s = (doc.data() as Map<String, dynamic>)['status'] as String?;
        switch (s) {
          case 'pending':
            pending++;
            break;
          case 'delivered':
            completed++;
            break;
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
    });
  }

  Stream<Map<String, int>> getNgoStats(String ngoId) {
    return Rx.combineLatest2(
      _donations.where('ngoId', isEqualTo: ngoId).snapshots(),
      _donations.where('status', isEqualTo: 'pending').snapshots(),
      (ngoDonations, pendingDonations) {
        int active = 0, completed = 0, inTransit = 0;

        for (final doc in ngoDonations.docs) {
          final s = (doc.data() as Map<String, dynamic>)['status'] as String?;
          switch (s) {
            case 'delivered':
              completed++;
              break;
            case 'picked':
            case 'inTransit':
            case 'nearLocation':
              inTransit++;
              break;
            default:
              active++;
          }
        }

        return {
          'total': ngoDonations.docs.length,
          'active': active,
          'inTransit': inTransit,
          'completed': completed,
          'available': pendingDonations.docs.length,
        };
      },
    );
  }

  Stream<Map<String, int>> getCompanyStats(String companyId) {
    return Rx.combineLatest2(
      _donations.where('companyId', isEqualTo: companyId).snapshots(),
      _users
          .where('companyId', isEqualTo: companyId)
          .where('role', isEqualTo: 'logisticsEmployee')
          .snapshots(),
      (donationsSnapshot, employeesSnapshot) {
        int active = 0, completed = 0;

        for (final doc in donationsSnapshot.docs) {
          final s = (doc.data() as Map<String, dynamic>)['status'] as String?;
          if (s == 'delivered') {
            completed++;
          } else {
            active++;
          }
        }

        return {
          'total': donationsSnapshot.docs.length,
          'active': active,
          'completed': completed,
          'employees': employeesSnapshot.docs.length,
        };
      },
    );
  }

  Stream<Map<String, int>> getEmployeeStats(String employeeId) {
    return _donations
        .where('employeeId', isEqualTo: employeeId)
        .snapshots()
        .map((snapshot) {
      int assigned = 0, picked = 0, delivered = 0;

      for (final doc in snapshot.docs) {
        final s = (doc.data() as Map<String, dynamic>)['status'] as String?;
        switch (s) {
          case 'assigned':
            assigned++;
            break;
          case 'picked':
          case 'inTransit':
          case 'nearLocation':
            picked++;
            break;
          case 'delivered':
            delivered++;
            break;
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
    });
  }


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

  Future<void> notifyNearbyDonors(
    GeoPoint center,
    double radiusKm,
    String title,
    String body,
  ) async {
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
