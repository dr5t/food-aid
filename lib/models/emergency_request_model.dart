import 'package:cloud_firestore/cloud_firestore.dart';

enum EmergencyStatus {
  open,
  donorAccepted,
  assigned,
  picked,
  inTransit,
  nearLocation,
  delivered,
  cancelled,
}

class EmergencyRequestModel {
  final String id;
  final String ngoId;
  final String ngoName;
  final String mealType; // "veg" or "nonVeg"
  final int quantity;
  final GeoPoint ngoLocation;
  final String ngoAddress;
  final double radiusKm;
  final EmergencyStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Filled when a donor accepts
  final String? donorId;
  final String? donorName;
  final String? donationId;

  // Filled when logistics assigned
  final String? companyId;
  final String? companyName;
  final String? employeeId;
  final String? employeeName;

  const EmergencyRequestModel({
    required this.id,
    required this.ngoId,
    required this.ngoName,
    required this.mealType,
    required this.quantity,
    required this.ngoLocation,
    required this.ngoAddress,
    this.radiusKm = 10.0,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.donorId,
    this.donorName,
    this.donationId,
    this.companyId,
    this.companyName,
    this.employeeId,
    this.employeeName,
  });

  factory EmergencyRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyRequestModel(
      id: doc.id,
      ngoId: data['ngoId'] ?? '',
      ngoName: data['ngoName'] ?? '',
      mealType: data['mealType'] ?? 'veg',
      quantity: data['quantity'] ?? 0,
      ngoLocation: data['ngoLocation'] as GeoPoint? ??
          const GeoPoint(0, 0),
      ngoAddress: data['ngoAddress'] ?? '',
      radiusKm: (data['radiusKm'] ?? 10.0).toDouble(),
      status: EmergencyStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => EmergencyStatus.open,
      ),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      donorId: data['donorId'],
      donorName: data['donorName'],
      donationId: data['donationId'],
      companyId: data['companyId'],
      companyName: data['companyName'],
      employeeId: data['employeeId'],
      employeeName: data['employeeName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ngoId': ngoId,
      'ngoName': ngoName,
      'mealType': mealType,
      'quantity': quantity,
      'ngoLocation': ngoLocation,
      'ngoAddress': ngoAddress,
      'radiusKm': radiusKm,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'donorId': donorId,
      'donorName': donorName,
      'donationId': donationId,
      'companyId': companyId,
      'companyName': companyName,
      'employeeId': employeeId,
      'employeeName': employeeName,
    };
  }

  EmergencyRequestModel copyWith({
    EmergencyStatus? status,
    String? donorId,
    String? donorName,
    String? donationId,
    String? companyId,
    String? companyName,
    String? employeeId,
    String? employeeName,
    DateTime? updatedAt,
  }) {
    return EmergencyRequestModel(
      id: id,
      ngoId: ngoId,
      ngoName: ngoName,
      mealType: mealType,
      quantity: quantity,
      ngoLocation: ngoLocation,
      ngoAddress: ngoAddress,
      radiusKm: radiusKm,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      donationId: donationId ?? this.donationId,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
    );
  }

  bool get isOpen => status == EmergencyStatus.open;

  bool get isActive =>
      status != EmergencyStatus.delivered &&
      status != EmergencyStatus.cancelled;

  String get mealTypeLabel =>
      mealType == 'veg' ? 'Vegetarian' : 'Non-Vegetarian';

  String get statusLabel {
    switch (status) {
      case EmergencyStatus.open:
        return 'Waiting for Donor';
      case EmergencyStatus.donorAccepted:
        return 'Donor Accepted';
      case EmergencyStatus.assigned:
        return 'Logistics Assigned';
      case EmergencyStatus.picked:
        return 'Picked Up';
      case EmergencyStatus.inTransit:
        return 'In Transit';
      case EmergencyStatus.nearLocation:
        return 'Near Location';
      case EmergencyStatus.delivered:
        return 'Delivered';
      case EmergencyStatus.cancelled:
        return 'Cancelled';
    }
  }
}
