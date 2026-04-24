import 'package:cloud_firestore/cloud_firestore.dart';

enum DonationStatus {
  pending,
  accepted,
  assigned,
  picked,
  inTransit,
  nearLocation,
  delivered,
  rejected,
  expired,
}

enum FoodType {
  cookedMeal,
  rawGroceries,
  packedFood,
  bakeryItems,
  beverages,
  fruits,
  vegetables,
  other,
}

enum MealType { veg, nonVeg, both }

class DonationModel {
  final String id;
  final String donorId;
  final String donorName;
  final String? donorType;

  final String? ngoId;
  final String? ngoName;

  final String? companyId;
  final String? companyName;
  final String? employeeId;
  final String? employeeName;

  final String title;
  final String description;
  final FoodType foodType;
  final MealType mealType;
  final int? quantity;
  final String unit;
  final DonationStatus status;

  final String pickupAddress;
  final GeoPoint? pickupLocation;
  final String? deliveryAddress;
  final GeoPoint? deliveryLocation;
  final GeoPoint? currentLocation;

  final DateTime expiryDate;
  final DateTime? pickupTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  final bool isEmergency;
  final String? emergencyRequestId;

  final String? rejectionReason;

  const DonationModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    this.donorType,
    this.ngoId,
    this.ngoName,
    this.companyId,
    this.companyName,
    this.employeeId,
    this.employeeName,
    required this.title,
    required this.description,
    required this.foodType,
    this.mealType = MealType.both,
    this.quantity,
    required this.unit,
    required this.status,
    required this.pickupAddress,
    this.pickupLocation,
    this.deliveryAddress,
    this.deliveryLocation,
    this.currentLocation,
    required this.expiryDate,
    this.pickupTime,
    required this.createdAt,
    required this.updatedAt,
    this.isEmergency = false,
    this.emergencyRequestId,
    this.rejectionReason,
  });

  factory DonationModel.fromMap(Map<String, dynamic> data, String id) {
    return DonationModel(
      id: id,
      donorId: data['donorId'] ?? '',
      donorName: data['donorName'] ?? '',
      donorType: data['donorType'],
      ngoId: data['ngoId'],
      ngoName: data['ngoName'],
      companyId: data['companyId'],
      companyName: data['companyName'],
      employeeId: data['employeeId'],
      employeeName: data['employeeName'],
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      foodType: FoodType.values.firstWhere(
        (f) => f.name == data['foodType'],
        orElse: () => FoodType.other,
      ),
      mealType: MealType.values.firstWhere(
        (m) => m.name == data['mealType'],
        orElse: () => MealType.both,
      ),
      quantity: data['quantity'],
      unit: data['unit'] ?? 'servings',
      status: DonationStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => DonationStatus.pending,
      ),
      pickupAddress: data['pickupAddress'] ?? '',
      pickupLocation: data['pickupLocation'] as GeoPoint?,
      deliveryAddress: data['deliveryAddress'],
      deliveryLocation: data['deliveryLocation'] as GeoPoint?,
      currentLocation: data['currentLocation'] as GeoPoint?,
      expiryDate:
          (data['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pickupTime: (data['pickupTime'] as Timestamp?)?.toDate(),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isEmergency: data['isEmergency'] ?? false,
      emergencyRequestId: data['emergencyRequestId'],
      rejectionReason: data['rejectionReason'],
    );
  }

  factory DonationModel.fromFirestore(DocumentSnapshot doc) {
    return DonationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'donorId': donorId,
      'donorName': donorName,
      'donorType': donorType,
      'ngoId': ngoId,
      'ngoName': ngoName,
      'companyId': companyId,
      'companyName': companyName,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'title': title,
      'description': description,
      'foodType': foodType.name,
      'mealType': mealType.name,
      'quantity': quantity,
      'unit': unit,
      'status': status.name,
      'pickupAddress': pickupAddress,
      'pickupLocation': pickupLocation,
      'deliveryAddress': deliveryAddress,
      'deliveryLocation': deliveryLocation,
      'currentLocation': currentLocation,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'pickupTime':
          pickupTime != null ? Timestamp.fromDate(pickupTime!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEmergency': isEmergency,
      'emergencyRequestId': emergencyRequestId,
      'rejectionReason': rejectionReason,
    };
  }

  DonationModel copyWith({
    String? ngoId,
    String? ngoName,
    String? companyId,
    String? companyName,
    String? employeeId,
    String? employeeName,
    DonationStatus? status,
    GeoPoint? currentLocation,
    String? rejectionReason,
    DateTime? updatedAt,
  }) {
    return DonationModel(
      id: id,
      donorId: donorId,
      donorName: donorName,
      donorType: donorType,
      ngoId: ngoId ?? this.ngoId,
      ngoName: ngoName ?? this.ngoName,
      companyId: companyId ?? this.companyId,
      companyName: companyName ?? this.companyName,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      title: title,
      description: description,
      foodType: foodType,
      mealType: mealType,
      quantity: quantity,
      unit: unit,
      status: status ?? this.status,
      pickupAddress: pickupAddress,
      pickupLocation: pickupLocation,
      deliveryAddress: deliveryAddress,
      deliveryLocation: deliveryLocation,
      currentLocation: currentLocation ?? this.currentLocation,
      expiryDate: expiryDate,
      pickupTime: pickupTime,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmergency: isEmergency,
      emergencyRequestId: emergencyRequestId,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  String get foodTypeLabel {
    switch (foodType) {
      case FoodType.cookedMeal:
        return 'Cooked Meal';
      case FoodType.rawGroceries:
        return 'Raw Groceries';
      case FoodType.packedFood:
        return 'Packed Food';
      case FoodType.bakeryItems:
        return 'Bakery Items';
      case FoodType.beverages:
        return 'Beverages';
      case FoodType.fruits:
        return 'Fruits';
      case FoodType.vegetables:
        return 'Vegetables';
      case FoodType.other:
        return 'Other';
    }
  }

  String get mealTypeLabel {
    switch (mealType) {
      case MealType.veg:
        return 'Vegetarian';
      case MealType.nonVeg:
        return 'Non-Vegetarian';
      case MealType.both:
        return 'Veg & Non-Veg';
    }
  }

  String get statusLabel {
    switch (status) {
      case DonationStatus.pending:
        return 'Pending';
      case DonationStatus.accepted:
        return 'Accepted';
      case DonationStatus.assigned:
        return 'Assigned';
      case DonationStatus.picked:
        return 'Pickup';
      case DonationStatus.inTransit:
        return 'In Transit';
      case DonationStatus.nearLocation:
        return 'Near Location';
      case DonationStatus.delivered:
        return 'Delivered';
      case DonationStatus.rejected:
        return 'Rejected';
      case DonationStatus.expired:
        return 'Expired';
    }
  }

  bool get isActive =>
      status != DonationStatus.delivered &&
      status != DonationStatus.rejected &&
      status != DonationStatus.expired;

  bool get isExpired => DateTime.now().isAfter(expiryDate);

  bool get isInDelivery =>
      status == DonationStatus.picked ||
      status == DonationStatus.inTransit ||
      status == DonationStatus.nearLocation;

  String get quantityDisplay =>
      quantity != null ? '$quantity $unit' : 'Qty not specified';
}
