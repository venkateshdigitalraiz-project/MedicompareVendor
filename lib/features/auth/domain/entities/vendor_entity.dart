class VendorEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String token;
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

  VendorEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.token,
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
}
