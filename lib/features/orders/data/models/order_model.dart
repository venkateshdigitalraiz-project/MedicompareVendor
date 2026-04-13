import '../../domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.orderItemId,
    required super.orderId,
    required super.productId,
    required super.quantity,
    required super.type,
    required super.bookingType,
    required super.orderStatus,
    required super.paymentStatus,
    required super.price,
    required super.discountPrice,
    required super.totalPrice,
    required super.vendorCommissionAmount,
    required super.createdAt,
    required super.orderDetails,
    required super.productDetails,
    super.userDetails,
    super.shippingAddressDetails,
    super.billingAddressDetails,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['_id']?.toString() ?? '',
      orderItemId: json['orderItemId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      type: json['type']?.toString() ?? '',
      bookingType: json['bookingType']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountprice'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      vendorCommissionAmount: (json['vendorCommissionAmount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      orderDetails: OrderDetailsModel.fromJson(json['orderDetails'] ?? {}),
      productDetails:
          ProductDetailsModel.fromJson(json['productDetails'] ?? {}),
      userDetails: json['userDetails'] != null
          ? FullUserDetailsModel.fromJson(json['userDetails'])
          : null,
      shippingAddressDetails: json['shippingAddressDetails'] != null
          ? AddressDetailsModel.fromJson(json['shippingAddressDetails'])
          : null,
      billingAddressDetails: json['billingAddressDetails'] != null
          ? AddressDetailsModel.fromJson(json['billingAddressDetails'])
          : null,
    );
  }
}

class OrderDetailsModel extends OrderDetailsEntity {
  const OrderDetailsModel({
    required super.id,
    required super.orderId,
    required super.userId,
    required super.paymentMethod,
    required super.paymentStatus,
    required super.orderStatus,
    required super.subtotal,
    required super.total,
    super.shipping = 0,
    super.discount = 0,
    super.tax = 0,
    super.cgst = 0,
    super.sgst = 0,
    required super.personType,
    super.doctorName,
    super.userDetails,
    super.fixedDeposit = 0,
    super.serviceCharges = 0,
    super.returnCharge = 0,
    super.rentalPlan,
    super.paymentType,
    super.startDate,
    super.endDate,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsModel(
      id: json['_id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      paymentMethod: json['paymentmethod']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      shipping: (json['shipping'] ?? 0).toDouble(),
      discount: (json['discount'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      cgst: (json['cgst'] ?? 0).toDouble(),
      sgst: (json['sgst'] ?? 0).toDouble(),
      personType: json['persontype']?.toString() ?? '',
      doctorName: json['doctorName']?.toString(),
      userDetails: json['userDetails'] != null
          ? UserDetailsModel.fromJson(json['userDetails'])
          : null,
      fixedDeposit: (json['fixedDeposit'] ?? 0).toDouble(),
      serviceCharges: (json['serviceCharges'] ?? 0).toDouble(),
      returnCharge: (json['returnCharge'] ?? 0).toDouble(),
      rentalPlan: json['rentalPlan']?.toString(),
      paymentType: json['paymentType']?.toString(),
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }
}

class UserDetailsModel extends UserDetailsEntity {
  const UserDetailsModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
  });

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      id: json['_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }
}

class FullUserDetailsModel extends FullUserDetailsEntity {
  const FullUserDetailsModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.age,
    required super.gender,
    required super.files,
  });

  factory FullUserDetailsModel.fromJson(Map<String, dynamic> json) {
    return FullUserDetailsModel(
      id: json['_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      age: json['age'] ?? 0,
      gender: json['gender']?.toString() ?? '',
      files: (json['files'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class AddressDetailsModel extends AddressDetailsEntity {
  const AddressDetailsModel({
    required super.id,
    required super.houseNo,
    required super.area,
    required super.landmark,
    required super.description,
    required super.addressType,
    required super.pincode,
    required super.fullAddress,
  });

  factory AddressDetailsModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'] ?? {};
    return AddressDetailsModel(
      id: json['_id']?.toString() ?? '',
      houseNo: json['houseNo']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      addressType: json['addressType']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      fullAddress: location['address']?.toString() ?? '',
    );
  }
}

class ProductDetailsModel extends ProductDetailsEntity {
  const ProductDetailsModel({
    required super.id,
    required super.name,
    super.tabletDetails,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    return ProductDetailsModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      tabletDetails: json['tabletdetails'],
    );
  }
}

class PaginationModel extends PaginationEntity {
  const PaginationModel({
    required super.total,
    required super.page,
    required super.limit,
    required super.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class OrdersListModel extends OrdersListEntity {
  const OrdersListModel({
    required super.orderItems,
    required super.pagination,
  });

  factory OrdersListModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> orderItemsJson = json['orderitems'] ?? [];
    return OrdersListModel(
      orderItems:
          orderItemsJson.map((item) => OrderItemModel.fromJson(item)).toList(),
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }
}
