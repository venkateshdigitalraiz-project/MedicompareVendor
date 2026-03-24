// Ambulance Booking / Order entities

class AmbulanceOrderUser {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String? profileImage;
  final int? age;
  final String? gender;
  final String? medicalConditions;

  const AmbulanceOrderUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    this.profileImage,
    this.age,
    this.gender,
    this.medicalConditions,
  });

  String get fullName => '$firstName $lastName'.trim();
}

class AmbulanceOrderLocation {
  final double lat;
  final double lng;
  final String address;

  const AmbulanceOrderLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });
}

class AmbulanceOrderProductDetail {
  final String id;
  final String serviceName; // from tabletdetails[0].name
  final String? ambulanceType; // from tabletdetails[0].ambulancetype
  final double price;
  final double discountPrice;
  final String? imageUrl;
  final String? businessName;
  final String? businessPhone;
  final String? businessEmail;
  final String? businessAddress;

  const AmbulanceOrderProductDetail({
    required this.id,
    required this.serviceName,
    this.ambulanceType,
    required this.price,
    required this.discountPrice,
    this.imageUrl,
    this.businessName,
    this.businessPhone,
    this.businessEmail,
    this.businessAddress,
  });
}

class AmbulanceOrderEntity {
  final String id;
  final String bookingId;
  final AmbulanceOrderLocation pickupLocation;
  final AmbulanceOrderLocation dropoffLocation;
  final double distance;
  final double fare;
  final double totalFare;
  final double gst;
  final String status;
  final String bookingStatus;
  final String paymentMethod;
  final String paymentStatus;
  final String emergencyType;
  final DateTime createdAt;
  final List<AmbulanceOrderUser> users;
  final List<AmbulanceOrderProductDetail> productDetails;

  const AmbulanceOrderEntity({
    required this.id,
    required this.bookingId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.distance,
    required this.fare,
    required this.totalFare,
    required this.gst,
    required this.status,
    required this.bookingStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.emergencyType,
    required this.createdAt,
    required this.users,
    required this.productDetails,
  });

  AmbulanceOrderUser? get customer =>
      users.isNotEmpty ? users.first : null;
  AmbulanceOrderProductDetail? get product =>
      productDetails.isNotEmpty ? productDetails.first : null;
}

class AmbulanceOrdersListEntity {
  final List<AmbulanceOrderEntity> orders;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AmbulanceOrdersListEntity({
    required this.orders,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}
