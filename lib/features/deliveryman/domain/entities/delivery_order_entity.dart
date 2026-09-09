import 'package:equatable/equatable.dart';

class DeliveryOrderEntity extends Equatable {
  final String id;
  final String orderItemId;
  final String orderId;
  final String customerName;
  final String customerPhone;
  final String deliveryAddress;
  final String assignedPersonnelName;
  final String assignedPersonnelPhone;
  final String status;
  final DateTime? orderDate;
  final double totalAmount;
  final String? itemName;

  const DeliveryOrderEntity({
    required this.id,
    required this.orderItemId,
    required this.orderId,
    required this.customerName,
    required this.customerPhone,
    required this.deliveryAddress,
    required this.assignedPersonnelName,
    required this.assignedPersonnelPhone,
    required this.status,
    this.orderDate,
    this.totalAmount = 0.0,
    this.itemName,
  });

  @override
  List<Object?> get props => [
        id,
        orderItemId,
        orderId,
        customerName,
        customerPhone,
        deliveryAddress,
        assignedPersonnelName,
        assignedPersonnelPhone,
        status,
        orderDate,
        totalAmount,
        itemName,
      ];
}

class DeliveryOrdersSummaryEntity extends Equatable {
  final int totalOrders;
  final int delivered;
  final int inTransit;
  final int assignedPending;

  const DeliveryOrdersSummaryEntity({
    this.totalOrders = 0,
    this.delivered = 0,
    this.inTransit = 0,
    this.assignedPending = 0,
  });

  @override
  List<Object?> get props => [
        totalOrders,
        delivered,
        inTransit,
        assignedPending,
      ];
}

class DeliveryOrdersPaginationEntity extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const DeliveryOrdersPaginationEntity({
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.totalPages = 1,
  });

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}

class DeliveryOrdersResponseEntity extends Equatable {
  final List<DeliveryOrderEntity> list;
  final DeliveryOrdersPaginationEntity pagination;
  final DeliveryOrdersSummaryEntity summary;

  const DeliveryOrdersResponseEntity({
    this.list = const [],
    this.pagination = const DeliveryOrdersPaginationEntity(),
    this.summary = const DeliveryOrdersSummaryEntity(),
  });

  @override
  List<Object?> get props => [list, pagination, summary];
}
