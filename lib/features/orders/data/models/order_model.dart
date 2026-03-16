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
    required super.createdAt,
    required super.orderDetails,
    required super.productDetails,
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
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      orderDetails: OrderDetailsModel.fromJson(json['orderDetails'] ?? {}),
      productDetails: ProductDetailsModel.fromJson(json['productDetails'] ?? {}),
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
    required super.personType,
    super.doctorName,
    required super.userDetails,
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
      personType: json['persontype']?.toString() ?? '',
      doctorName: json['doctorName']?.toString(),
      userDetails: UserDetailsModel.fromJson(json['userDetails'] ?? {}),
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
      orderItems: orderItemsJson.map((item) => OrderItemModel.fromJson(item)).toList(),
      pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }
}
