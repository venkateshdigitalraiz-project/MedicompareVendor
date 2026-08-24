import '../../domain/entities/service_fee_user.dart';

class ServiceFeeUserModel extends ServiceFeeUser {
  const ServiceFeeUserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.mobile,
    super.businessName,
    super.businessLegalName,
  });

  factory ServiceFeeUserModel.fromJson(Map<String, dynamic> json) {
    return ServiceFeeUserModel(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile']?.toString() ?? '',
      businessName: json['businessName'],
      businessLegalName: json['businessLegalName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobile': mobile,
      'businessName': businessName,
      'businessLegalName': businessLegalName,
    };
  }
}
