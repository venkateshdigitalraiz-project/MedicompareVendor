import 'package:equatable/equatable.dart';

class ServiceFeeUser extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String? businessName;
  final String? businessLegalName;

  const ServiceFeeUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    this.businessName,
    this.businessLegalName,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        mobile,
        businessName,
        businessLegalName,
      ];
}
