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
  final DateTime createdAt;
  final OrderDetailsEntity orderDetails;
  final ProductDetailsEntity productDetails;

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
    required this.createdAt,
    required this.orderDetails,
    required this.productDetails,
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
        createdAt,
        orderDetails,
        productDetails,
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
  final String personType;
  final String? doctorName;
  final UserDetailsEntity userDetails;

  const OrderDetailsEntity({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    required this.subtotal,
    required this.total,
    required this.personType,
    this.doctorName,
    required this.userDetails,
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
        personType,
        doctorName,
        userDetails,
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

class ProductDetailsEntity extends Equatable {
  final String id;
  final String name;
  final dynamic tabletDetails; // Can be a map or entity if needed

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
