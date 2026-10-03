import 'package:equatable/equatable.dart';

// Ambulance Booking / Order entities

class AmbulanceOrderUser extends Equatable {
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
    this.id = '',
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.email = '',
    this.profileImage,
    this.age,
    this.gender,
    this.medicalConditions,
  });

  String get fullName => '$firstName $lastName'.trim();

  AmbulanceOrderUser copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? profileImage,
    int? age,
    String? gender,
    String? medicalConditions,
  }) {
    return AmbulanceOrderUser(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      medicalConditions: medicalConditions ?? this.medicalConditions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        phone,
        email,
        profileImage,
        age,
        gender,
        medicalConditions,
      ];
}

class AmbulanceOrderLocation extends Equatable {
  final double lat;
  final double lng;
  final String address;

  const AmbulanceOrderLocation({
    this.lat = 0.0,
    this.lng = 0.0,
    this.address = '',
  });

  AmbulanceOrderLocation copyWith({
    double? lat,
    double? lng,
    String? address,
  }) {
    return AmbulanceOrderLocation(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
    );
  }

  @override
  List<Object?> get props => [lat, lng, address];
}

class AmbulanceOrderProductDetail extends Equatable {
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
    this.id = '',
    this.serviceName = '',
    this.ambulanceType,
    this.price = 0.0,
    this.discountPrice = 0.0,
    this.imageUrl,
    this.businessName,
    this.businessPhone,
    this.businessEmail,
    this.businessAddress,
  });

  AmbulanceOrderProductDetail copyWith({
    String? id,
    String? serviceName,
    String? ambulanceType,
    double? price,
    double? discountPrice,
    String? imageUrl,
    String? businessName,
    String? businessPhone,
    String? businessEmail,
    String? businessAddress,
  }) {
    return AmbulanceOrderProductDetail(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      ambulanceType: ambulanceType ?? this.ambulanceType,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      businessName: businessName ?? this.businessName,
      businessPhone: businessPhone ?? this.businessPhone,
      businessEmail: businessEmail ?? this.businessEmail,
      businessAddress: businessAddress ?? this.businessAddress,
    );
  }

  @override
  List<Object?> get props => [
        id,
        serviceName,
        ambulanceType,
        price,
        discountPrice,
        imageUrl,
        businessName,
        businessPhone,
        businessEmail,
        businessAddress,
      ];
}

class AmbulanceDriverEntity extends Equatable {
  final String id;
  final String driverId;
  final String name;
  final String phone;
  final String email;
  final String vehicleNumber;
  final String? profileImage;
  final String otp;
  final DateTime? assignedAt;
  final String driverType;

  const AmbulanceDriverEntity({
    this.id = '',
    this.driverId = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.vehicleNumber = '',
    this.profileImage,
    this.otp = '',
    this.assignedAt,
    this.driverType = 'Medicompares Partner',
  });

  AmbulanceDriverEntity copyWith({
    String? id,
    String? driverId,
    String? name,
    String? phone,
    String? email,
    String? vehicleNumber,
    String? profileImage,
    String? otp,
    DateTime? assignedAt,
    String? driverType,
  }) {
    return AmbulanceDriverEntity(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      profileImage: profileImage ?? this.profileImage,
      otp: otp ?? this.otp,
      assignedAt: assignedAt ?? this.assignedAt,
      driverType: driverType ?? this.driverType,
    );
  }

  @override
  List<Object?> get props => [
        id,
        driverId,
        name,
        phone,
        email,
        vehicleNumber,
        profileImage,
        otp,
        assignedAt,
        driverType,
      ];
}

class AmbulanceOrderEntity extends Equatable {
  final String id;
  final String bookingId;
  final AmbulanceOrderLocation pickupLocation;
  final AmbulanceOrderLocation dropoffLocation;
  final double distance;
  final double subtotal;
  final double fare;
  final double totalFare;
  final double gst;
  final double adminCommission;
  final double couponAmount;
  final String couponType;
  final String couponCode;
  final String status;
  final String bookingStatus;
  final String paymentMethod;
  final String paymentStatus;
  final String emergencyType;
  final DateTime? bookingDateTime;
  final DateTime? _createdAt;
  final List<AmbulanceOrderUser> users;
  final List<AmbulanceOrderProductDetail> productDetails;
  final AmbulanceDriverEntity? driver;

  const AmbulanceOrderEntity({
    this.id = '',
    this.bookingId = '',
    this.pickupLocation = const AmbulanceOrderLocation(),
    this.dropoffLocation = const AmbulanceOrderLocation(),
    this.distance = 0.0,
    this.subtotal = 0.0,
    this.fare = 0.0,
    this.totalFare = 0.0,
    this.gst = 0.0,
    this.adminCommission = 0.0,
    this.couponAmount = 0.0,
    this.couponType = '',
    this.couponCode = '',
    this.status = 'pending',
    this.bookingStatus = 'pending',
    this.paymentMethod = 'cod',
    this.paymentStatus = 'unpaid',
    this.emergencyType = '',
    this.bookingDateTime,
    DateTime? createdAt,
    this.users = const [],
    this.productDetails = const [],
    this.driver,
  }) : _createdAt = createdAt;

  DateTime get createdAt =>
      _createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  AmbulanceOrderUser? get customer => users.isNotEmpty ? users.first : null;
  AmbulanceOrderProductDetail? get product =>
      productDetails.isNotEmpty ? productDetails.first : null;

  bool get isVendorCoupon => couponType.trim().toLowerCase() == 'vendor';
  double get effectiveGrandTotal {
    final discount = isVendorCoupon ? couponAmount : 0.0;
    final calculated = fare - adminCommission - discount;
    return calculated < 0.0 ? 0.0 : calculated;
  }
  bool get isConfirmed => bookingStatus.trim().toLowerCase() == 'confirmed';
  bool get isAssigned => bookingStatus.trim().toLowerCase() == 'assigned';
  bool get isPending => bookingStatus.trim().toLowerCase() == 'pending';
  bool get isCancelled =>
      bookingStatus.trim().toLowerCase() == 'cancelled' ||
      status.trim().toLowerCase() == 'cancelled';

  AmbulanceOrderEntity copyWith({
    String? id,
    String? bookingId,
    AmbulanceOrderLocation? pickupLocation,
    AmbulanceOrderLocation? dropoffLocation,
    double? distance,
    double? subtotal,
    double? fare,
    double? totalFare,
    double? gst,
    double? adminCommission,
    double? couponAmount,
    String? couponType,
    String? couponCode,
    String? status,
    String? bookingStatus,
    String? paymentMethod,
    String? paymentStatus,
    String? emergencyType,
    DateTime? bookingDateTime,
    DateTime? createdAt,
    List<AmbulanceOrderUser>? users,
    List<AmbulanceOrderProductDetail>? productDetails,
    AmbulanceDriverEntity? driver,
  }) {
    return AmbulanceOrderEntity(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      distance: distance ?? this.distance,
      subtotal: subtotal ?? this.subtotal,
      fare: fare ?? this.fare,
      totalFare: totalFare ?? this.totalFare,
      gst: gst ?? this.gst,
      adminCommission: adminCommission ?? this.adminCommission,
      couponAmount: couponAmount ?? this.couponAmount,
      couponType: couponType ?? this.couponType,
      couponCode: couponCode ?? this.couponCode,
      status: status ?? this.status,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      emergencyType: emergencyType ?? this.emergencyType,
      bookingDateTime: bookingDateTime ?? this.bookingDateTime,
      createdAt: createdAt ?? _createdAt,
      users: users ?? this.users,
      productDetails: productDetails ?? this.productDetails,
      driver: driver ?? this.driver,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingId,
        pickupLocation,
        dropoffLocation,
        distance,
        subtotal,
        fare,
        totalFare,
        gst,
        adminCommission,
        couponAmount,
        couponType,
        couponCode,
        status,
        bookingStatus,
        paymentMethod,
        paymentStatus,
        emergencyType,
        bookingDateTime,
        _createdAt,
        users,
        productDetails,
        driver,
      ];
}

class AmbulanceOrdersListEntity extends Equatable {
  final List<AmbulanceOrderEntity> orders;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AmbulanceOrdersListEntity({
    this.orders = const [],
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.totalPages = 1,
  });

  @override
  List<Object?> get props => [orders, total, page, limit, totalPages];
}
