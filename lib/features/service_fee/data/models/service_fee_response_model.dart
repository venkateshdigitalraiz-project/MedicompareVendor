import 'service_fee_model.dart';
import 'service_fee_user_model.dart';

class ServiceFeeResponseModel {
  final bool success;
  final String message;
  final ServiceFeeModel? data;
  final ServiceFeeUserModel? user;
  final dynamic errors;

  const ServiceFeeResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.user,
    this.errors,
  });

  factory ServiceFeeResponseModel.fromJson(Map<String, dynamic> json) {
    // Some responses might place users directly or under user
    final usersJson = json['users'] ?? json['user'];
    return ServiceFeeResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ServiceFeeModel.fromJson(json['data']) : null,
      user: usersJson != null ? ServiceFeeUserModel.fromJson(usersJson) : null,
      errors: json['errors'],
    );
  }
}
