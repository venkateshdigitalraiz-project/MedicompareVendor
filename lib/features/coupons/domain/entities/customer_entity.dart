class Customer {
  final String id;
  final String firstName;
  final String? lastName;
  final String? email;
  final String phone;
  final String custId;

  const Customer({
    required this.id,
    required this.firstName,
    this.lastName,
    this.email,
    required this.phone,
    required this.custId,
  });

  String get fullName => '$firstName ${lastName ?? ''}'.trim();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Customer && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
