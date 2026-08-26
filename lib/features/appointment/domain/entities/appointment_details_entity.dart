import 'package:equatable/equatable.dart';

class AppointmentDetailsEntity extends Equatable {
  final String orderId;
  final String orderRef;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String bookingType;
  final String orderType;
  final String serviceFixedTypes;
  final bool isGroup;
  final DateTime? selectedDate;
  final String selectedTimeSlot;
  final DateTime? createdAt;
  final String referredDoctor;
  final AppointmentDetailsBillingSummaryEntity billingSummary;
  final List<AppointmentGroupDetailsEntity> groupDetails;
  final List<AppointmentServiceItemEntity> normalItems;

  final AppointmentAddressEntity? shippingAddress;
  final AppointmentAddressEntity? billingAddress;
  final AppointmentCouponDetailsEntity? couponDetails;

  const AppointmentDetailsEntity({
    required this.orderId,
    required this.orderRef,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.bookingType,
    required this.orderType,
    required this.serviceFixedTypes,
    required this.isGroup,
    this.selectedDate,
    required this.selectedTimeSlot,
    this.createdAt,
    required this.referredDoctor,
    required this.billingSummary,
    required this.groupDetails,
    required this.normalItems,
    this.shippingAddress,
    this.billingAddress,
    this.couponDetails,
  });

  @override
  List<Object?> get props => [
        orderId,
        orderRef,
        orderStatus,
        paymentStatus,
        paymentMethod,
        bookingType,
        orderType,
        serviceFixedTypes,
        isGroup,
        selectedDate,
        selectedTimeSlot,
        createdAt,
        referredDoctor,
        billingSummary,
        groupDetails,
        normalItems,
        shippingAddress,
        billingAddress,
        couponDetails,
      ];
}

class AppointmentCouponDetailsEntity extends Equatable {
  final String? createdType;

  const AppointmentCouponDetailsEntity({
    this.createdType,
  });

  @override
  List<Object?> get props => [createdType];
}

class AppointmentDetailsBillingSummaryEntity extends Equatable {
  final double subtotal;
  final double totalGst;
  final double totalIgst;
  final double deliveryCharges;
  final double couponAmount;
  final double finalAmount;
  final double walletAmount;
  final double sampleCollection;
  final double tax;
  final double adminCommission;

  const AppointmentDetailsBillingSummaryEntity({
    required this.subtotal,
    required this.totalGst,
    required this.totalIgst,
    required this.deliveryCharges,
    required this.couponAmount,
    required this.finalAmount,
    required this.walletAmount,
    required this.sampleCollection,
    required this.tax,
    required this.adminCommission,
  });

  @override
  List<Object?> get props => [
        subtotal,
        totalGst,
        totalIgst,
        deliveryCharges,
        couponAmount,
        finalAmount,
        walletAmount,
        sampleCollection,
        tax,
        adminCommission,
      ];
}

class AppointmentGroupDetailsEntity extends Equatable {
  final AppointmentPatientDetailsEntity? patientDetails;
  final List<AppointmentServiceItemEntity> items;

  const AppointmentGroupDetailsEntity({
    this.patientDetails,
    required this.items,
  });

  @override
  List<Object?> get props => [patientDetails, items];
}

class AppointmentPatientDetailsEntity extends Equatable {
  final String name;
  final String age;
  final String gender;
  final String phone;
  final String email;

  const AppointmentPatientDetailsEntity({
    required this.name,
    required this.age,
    required this.gender,
    required this.phone,
    required this.email,
  });

  @override
  List<Object?> get props => [name, age, gender, phone, email];
}

class AppointmentServiceItemEntity extends Equatable {
  final String orderItemId;
  final int quantity;
  final String type;
  final String bookingType;
  final String serviceTypes;
  final double price;
  final double discountPrice;
  final double totalPrice;
  final double adminCommission;
  final String status;
  final String productName;
  final List<String> productImages;
  final double couponAmount;

  const AppointmentServiceItemEntity({
    required this.orderItemId,
    required this.quantity,
    required this.type,
    required this.bookingType,
    required this.serviceTypes,
    required this.price,
    required this.discountPrice,
    required this.totalPrice,
    required this.adminCommission,
    required this.status,
    required this.productName,
    required this.productImages,
    required this.couponAmount,
  });

  @override
  List<Object?> get props => [
        orderItemId,
        quantity,
        type,
        bookingType,
        serviceTypes,
        price,
        discountPrice,
        totalPrice,
        adminCommission,
        status,
        productName,
        productImages,
        couponAmount,
      ];
}

class AppointmentAddressEntity extends Equatable {
  final String houseNo;
  final String area;
  final String landmark;
  final String locationAddress;
  final String pincode;
  final String addressType;

  const AppointmentAddressEntity({
    required this.houseNo,
    required this.area,
    required this.landmark,
    required this.locationAddress,
    required this.pincode,
    required this.addressType,
  });

  @override
  List<Object?> get props => [
        houseNo,
        area,
        landmark,
        locationAddress,
        pincode,
        addressType,
      ];
}
