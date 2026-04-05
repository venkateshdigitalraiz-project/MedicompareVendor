import 'package:equatable/equatable.dart';

class SubscriptionPlan extends Equatable {
  final String id;
  final String name;
  final int limit;
  final double price;
  final String billingCycle;
  final String prioritySet;
  final String status;
  final List<String> features;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.limit,
    required this.price,
    required this.billingCycle,
    required this.prioritySet,
    required this.status,
    required this.features,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      limit: json['limit']?.toInt() ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      billingCycle: json['billingCycle'] ?? '',
      prioritySet: json['prioritySet'] ?? '',
      status: json['status'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, limit, price, billingCycle, status, features];
}

class CurrentPack extends Equatable {
  final String id;
  final String planId;
  final String vendorId;
  final String? employeeId;
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String paymentStatus;
  final double amount;
  final int usage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SubscriptionPlan? plan;

  const CurrentPack({
    required this.id,
    required this.planId,
    required this.vendorId,
    this.employeeId,
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.paymentStatus,
    required this.amount,
    required this.usage,
    required this.createdAt,
    required this.updatedAt,
    this.plan,
  });

  factory CurrentPack.fromJson(Map<String, dynamic> json) {
    return CurrentPack(
      id: json['_id'] ?? '',
      planId: json['planId'] ?? '',
      vendorId: json['vendorId'] ?? '',
      employeeId: json['employeeId'],
      razorpayPaymentId: json['razorpayPaymentId'] ?? '',
      razorpayOrderId: json['razorpayOrderId'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      usage: json['usage']?.toInt() ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      plan:
          json['plan'] != null ? SubscriptionPlan.fromJson(json['plan']) : null,
    );
  }

  @override
  List<Object?> get props =>
      [id, planId, vendorId, paymentStatus, amount, usage, plan];
}

class SubscriptionHistory extends Equatable {
  final CurrentPack? currentPack;
  final List<CurrentPack> planHistory;

  const SubscriptionHistory({
    this.currentPack,
    required this.planHistory,
  });

  factory SubscriptionHistory.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistory(
      currentPack: json['currentPack'] != null
          ? CurrentPack.fromJson(json['currentPack'])
          : null,
      planHistory: (json['planHistory'] as List?)
              ?.map((e) => CurrentPack.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [currentPack, planHistory];
}

class SubscriptionListResponse extends Equatable {
  final List<SubscriptionPlan> list;
  final Pagination pagination;

  const SubscriptionListResponse({
    required this.list,
    required this.pagination,
  });

  factory SubscriptionListResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionListResponse(
      list: (json['list'] as List?)
              ?.map((e) => SubscriptionPlan.fromJson(e))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [list, pagination];
}

class Pagination extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total']?.toInt() ?? 0,
      page: json['page']?.toInt() ?? 1,
      limit: json['limit']?.toInt() ?? 10,
      totalPages: json['totalPages']?.toInt() ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }

  @override
  List<Object?> get props =>
      [total, page, limit, totalPages, hasNextPage, hasPrevPage];
}
