import '../../domain/entities/customer_entity.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.firstName,
    super.lastName,
    super.email,
    required super.phone,
    required super.custId,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      custId: json['custId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'custId': custId,
    };
  }
}
