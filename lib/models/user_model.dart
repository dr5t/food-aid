import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { donor, ngo, logisticsCompany, logisticsEmployee, admin }

enum DonorType { hotel, restaurant, wedding, home, resort, catering, other }

enum VerificationStatus { pending, approved, rejected }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String phone;
  final String? avatarUrl;
  final DateTime createdAt;

  // Role-specific fields
  final DonorType? donorType;
  final String? organizationName;
  final String? organizationDescription;
  final String? companyId; // Logistics employee → linked company
  final String? address;
  final GeoPoint? location;
  final bool isVerified;

  // Verification system
  final VerificationStatus verificationStatus;
  final String? createdBy; // UID of admin/company who created this user
  final String? rejectionReason;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.avatarUrl,
    required this.createdAt,
    this.donorType,
    this.organizationName,
    this.organizationDescription,
    this.companyId,
    this.address,
    this.location,
    this.isVerified = false,
    this.verificationStatus = VerificationStatus.pending,
    this.createdBy,
    this.rejectionReason,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == data['role'],
        orElse: () => UserRole.donor,
      ),
      phone: data['phone'] ?? '',
      avatarUrl: data['avatarUrl'],
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      donorType: data['donorType'] != null
          ? DonorType.values.firstWhere(
              (d) => d.name == data['donorType'],
              orElse: () => DonorType.other,
            )
          : null,
      organizationName: data['organizationName'],
      organizationDescription: data['organizationDescription'],
      companyId: data['companyId'],
      address: data['address'],
      location: data['location'] as GeoPoint?,
      isVerified: data['isVerified'] ?? false,
      verificationStatus: VerificationStatus.values.firstWhere(
        (v) => v.name == data['verificationStatus'],
        orElse: () => VerificationStatus.pending,
      ),
      createdBy: data['createdBy'],
      rejectionReason: data['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'donorType': donorType?.name,
      'organizationName': organizationName,
      'organizationDescription': organizationDescription,
      'companyId': companyId,
      'address': address,
      'location': location,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus.name,
      'createdBy': createdBy,
      'rejectionReason': rejectionReason,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? phone,
    String? avatarUrl,
    DonorType? donorType,
    String? organizationName,
    String? organizationDescription,
    String? companyId,
    String? address,
    GeoPoint? location,
    bool? isVerified,
    VerificationStatus? verificationStatus,
    String? createdBy,
    String? rejectionReason,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      donorType: donorType ?? this.donorType,
      organizationName: organizationName ?? this.organizationName,
      organizationDescription:
          organizationDescription ?? this.organizationDescription,
      companyId: companyId ?? this.companyId,
      address: address ?? this.address,
      location: location ?? this.location,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdBy: createdBy ?? this.createdBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  /// Whether this user needs admin verification before accessing their dashboard.
  bool get requiresVerification =>
      role == UserRole.ngo || role == UserRole.logisticsCompany;

  /// Whether this user is approved and can access their dashboard.
  bool get isApproved =>
      !requiresVerification || verificationStatus == VerificationStatus.approved;

  /// Whether this user is still waiting for admin approval.
  bool get isPendingVerification =>
      requiresVerification && verificationStatus == VerificationStatus.pending;

  /// Whether admin has rejected this user's registration.
  bool get isRejected =>
      requiresVerification && verificationStatus == VerificationStatus.rejected;

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get roleLabel {
    switch (role) {
      case UserRole.donor:
        return 'Donor';
      case UserRole.ngo:
        return 'NGO / Organization';
      case UserRole.logisticsCompany:
        return 'Logistics Company';
      case UserRole.logisticsEmployee:
        return 'Delivery Partner';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get verificationLabel {
    switch (verificationStatus) {
      case VerificationStatus.pending:
        return 'Pending Review';
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  String get donorTypeLabel {
    switch (donorType) {
      case DonorType.hotel:
        return 'Hotel';
      case DonorType.restaurant:
        return 'Restaurant';
      case DonorType.wedding:
        return 'Wedding / Event';
      case DonorType.home:
        return 'Home';
      case DonorType.resort:
        return 'Resort';
      case DonorType.catering:
        return 'Catering Service';
      case DonorType.other:
        return 'Other';
      case null:
        return 'Not specified';
    }
  }
}
