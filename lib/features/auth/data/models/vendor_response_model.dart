import '../../domain/entities/vendor_entity.dart';

class VendorResponseModel {
  final bool success;
  final String message;
  final VendorDataModel? data;

  VendorResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory VendorResponseModel.fromJson(Map<String, dynamic> json) {
    return VendorResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? VendorDataModel.fromJson(json['data']) : null,
    );
  }
}

class VendorDataModel {
  final String token;
  final UserModel? user;
  final Map<String, dynamic>? business;

  VendorDataModel({required this.token, this.user, this.business});

  factory VendorDataModel.fromJson(Map<String, dynamic> json) {
    return VendorDataModel(
      token: json['token'] ?? '',
      user: json['user'] != null 
          ? UserModel.fromJson(json['user']) 
          : (json['vendor'] != null ? UserModel.fromJson(json['vendor']) : null),
      business: json['business'],
    );
  }
}

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final dynamic mobile;
  final String vendorsId;
  final bool isVerified;
  final bool isProfileCompleted;
  final String? registrationStep;
  final String? proofType;
  final String? adhaarNumber;
  final String? residentialAddress;
  final String? businessName;
  final String? businessLegalName;
  final String? businessEmail;
  final String? businessMobile;
  final String? altMobile;
  final String? businessAddress;
  final List<String>? categoryIds;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.vendorsId,
    required this.isVerified,
    required this.isProfileCompleted,
    this.registrationStep,
    this.proofType,
    this.adhaarNumber,
    this.residentialAddress,
    this.businessName,
    this.businessLegalName,
    this.businessEmail,
    this.businessMobile,
    this.altMobile,
    this.businessAddress,
    this.categoryIds,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile']?.toString() ?? '',
      vendorsId: json['vendorsId'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isProfileCompleted: json['is_profile_completed'] ?? false,
      registrationStep: json['registrationStep'],
      proofType: json['proofType'],
      adhaarNumber: json['adharnumber'],
      residentialAddress: json['residentaladdress'],
      businessName: json['name'],
      businessLegalName: json['bussinesslegalname'],
      businessEmail: json['businessEmail'],
      businessMobile: json['businessMobile'],
      altMobile: json['alt_mobile'],
      businessAddress: json['address'],
      categoryIds: json['categoryIds'] != null ? List<String>.from(json['categoryIds']) : null,
    );
  }

  VendorEntity toEntity(String token) {
    return VendorEntity(
      id: id,
      firstName: firstName,
      lastName: lastName,
      email: email,
      mobile: mobile.toString(),
      token: token,
      vendorsId: vendorsId,
      isVerified: isVerified,
      isProfileCompleted: isProfileCompleted,
      registrationStep: registrationStep,
      proofType: proofType,
      adhaarNumber: adhaarNumber,
      residentialAddress: residentialAddress,
      businessName: businessName,
      businessLegalName: businessLegalName,
      businessEmail: businessEmail,
      businessMobile: businessMobile,
      altMobile: altMobile,
      businessAddress: businessAddress,
      categoryIds: categoryIds,
    );
  }
}
