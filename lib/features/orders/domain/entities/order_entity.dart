import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String id;
  final String orderItemId;
  final String orderId;
  final String productId;
  final int quantity;
  final String type;
  final String bookingType;
  final String orderStatus;
  final String paymentStatus;
  final double price;
  final double discountPrice;
  final double totalPrice;
  final DateTime createdAt;
  final OrderDetailsEntity orderDetails;
  final ProductDetailsEntity productDetails;
  final FullUserDetailsEntity? userDetails;
  final AddressDetailsEntity? shippingAddressDetails;
  final AddressDetailsEntity? billingAddressDetails;

  const OrderItemEntity({
    required this.id,
    required this.orderItemId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.type,
    required this.bookingType,
    required this.orderStatus,
    required this.paymentStatus,
    required this.price,
    required this.discountPrice,
    required this.totalPrice,
    required this.createdAt,
    required this.orderDetails,
    required this.productDetails,
    this.userDetails,
    this.shippingAddressDetails,
    this.billingAddressDetails,
  });

  @override
  List<Object?> get props => [
        id,
        orderItemId,
        orderId,
        productId,
        quantity,
        type,
        bookingType,
        orderStatus,
        paymentStatus,
        price,
        discountPrice,
        totalPrice,
        createdAt,
        orderDetails,
        productDetails,
        userDetails,
        shippingAddressDetails,
        billingAddressDetails,
      ];
}

class OrderDetailsEntity extends Equatable {
  final String id;
  final String orderId;
  final String userId;
  final String paymentMethod;
  final String paymentStatus;
  final String orderStatus;
  final double subtotal;
  final double total;
  final double shipping;
  final double discount;
  final double tax;
  final double cgst;
  final double sgst;
  final String personType;
  final String? doctorName;
  final UserDetailsEntity? userDetails;

  // Rental specific fields
  final double fixedDeposit;
  final double serviceCharges;
  final double returnCharge;
  final String? rentalPlan;
  final String? paymentType;
  final DateTime? startDate;
  final DateTime? endDate;

  const OrderDetailsEntity({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.subtotal,
    required this.total,
    this.shipping = 0,
    this.discount = 0,
    this.tax = 0,
    this.cgst = 0,
    this.sgst = 0,
    required this.personType,
    this.doctorName,
    this.userDetails,
    this.fixedDeposit = 0,
    this.serviceCharges = 0,
    this.returnCharge = 0,
    this.rentalPlan,
    this.paymentType,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        userId,
        paymentMethod,
        paymentStatus,
        orderStatus,
        subtotal,
        total,
        shipping,
        discount,
        tax,
        cgst,
        sgst,
        personType,
        doctorName,
        userDetails,
        fixedDeposit,
        serviceCharges,
        returnCharge,
        rentalPlan,
        paymentType,
        startDate,
        endDate,
      ];
}

class UserDetailsEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const UserDetailsEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [id, firstName, lastName, email, phone];
}

class FullUserDetailsEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final int age;
  final String gender;
  final List<String> files;

  const FullUserDetailsEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.files,
  });

  @override
  List<Object?> get props =>
      [id, firstName, lastName, email, phone, age, gender, files];
}

class AddressDetailsEntity extends Equatable {
  final String id;
  final String houseNo;
  final String area;
  final String landmark;
  final String description;
  final String addressType;
  final String pincode;
  final String fullAddress;

  const AddressDetailsEntity({
    required this.id,
    required this.houseNo,
    required this.area,
    required this.landmark,
    required this.description,
    required this.addressType,
    required this.pincode,
    required this.fullAddress,
  });

  @override
  List<Object?> get props => [
        id,
        houseNo,
        area,
        landmark,
        description,
        addressType,
        pincode,
        fullAddress
      ];
}

class ProductDetailsEntity extends Equatable {
  final String id;
  final String name;
  final dynamic tabletDetails;

  const ProductDetailsEntity({
    required this.id,
    required this.name,
    this.tabletDetails,
  });

  @override
  List<Object?> get props => [id, name, tabletDetails];
}

class PaginationEntity extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const PaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}

class OrdersListEntity extends Equatable {
  final List<OrderItemEntity> orderItems;
  final PaginationEntity pagination;

  const OrdersListEntity({
    required this.orderItems,
    required this.pagination,
  });

  @override
  List<Object?> get props => [orderItems, pagination];
}
