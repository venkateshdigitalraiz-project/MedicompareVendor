import '../../domain/entities/dashboard_entity.dart';

class DashboardModel extends DashboardEntity {
  DashboardModel({
    required super.orderCount,
    required super.revenue,
    required super.leads,
    required super.rating,
    required super.topProducts,
    required super.recentLeads,
    required super.user,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final userData = json['users'];

    return DashboardModel(
      orderCount: OrderCountModel.fromJson(data['ordercount']),
      revenue: RevenueModel.fromJson(data['revenue']),
      leads: LeadsModel.fromJson(data['leads']),
      rating: RatingModel.fromJson(data['rating']),
      topProducts: (data['topproduct'] as List)
          .where((e) => e['_id'] != null)
          .map((e) => TopProductModel.fromJson(e))
          .toList(),
      recentLeads: (data['recentleads'] as List)
          .map((e) => RecentLeadModel.fromJson(e))
          .toList(),
      user: DashboardUserModel.fromJson(userData),
    );
  }
}

class OrderCountModel extends OrderCountEntity {
  OrderCountModel({
    required super.totalOrder,
    required super.currentMonthOrders,
    required super.previousMonthOrders,
    required super.orderStatus,
    required super.orderPercentageChange,
  });

  factory OrderCountModel.fromJson(Map<String, dynamic> json) {
    return OrderCountModel(
      totalOrder: json['totalorder'] ?? 0,
      currentMonthOrders: json['currentMonthOrders'] ?? 0,
      previousMonthOrders: json['previousMonthOrders'] ?? 0,
      orderStatus: json['orderStatus'] ?? 'no change',
      orderPercentageChange:
          (json['orderPercentageChange'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RevenueModel extends RevenueEntity {
  RevenueModel({
    required super.totalAmount,
    required super.currentMonthAmount,
    required super.previousMonthAmount,
    required super.amountStatus,
    required super.amountPercentageChange,
  });

  factory RevenueModel.fromJson(Map<String, dynamic> json) {
    return RevenueModel(
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currentMonthAmount:
          (json['currentMonthAmount'] as num?)?.toDouble() ?? 0.0,
      previousMonthAmount:
          (json['previousMonthAmount'] as num?)?.toDouble() ?? 0.0,
      amountStatus: json['amountStatus'] ?? 'no change',
      amountPercentageChange:
          (json['amountPercentageChange'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LeadsModel extends LeadsEntity {
  LeadsModel({
    required super.totalLeads,
    required super.currentMonthLeads,
    required super.previousMonthLeads,
    required super.leadStatus,
    required super.leadPercentageChange,
  });

  factory LeadsModel.fromJson(Map<String, dynamic> json) {
    return LeadsModel(
      totalLeads: json['totalLeads'] ?? 0,
      currentMonthLeads: json['currentMonthLeads'] ?? 0,
      previousMonthLeads: json['previousMonthLeads'] ?? 0,
      leadStatus: json['leadStatus'] ?? 'no change',
      leadPercentageChange:
          (json['leadPercentageChange'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RatingModel extends RatingEntity {
  RatingModel({
    required super.totalRating,
    required super.currentMonthRating,
    required super.previousMonthRating,
    required super.ratingStatus,
    required super.ratingPercentageChange,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      totalRating: (json['totalrating'] as num?)?.toDouble() ?? 0.0,
      currentMonthRating:
          (json['currentMonthrating'] as num?)?.toDouble() ?? 0.0,
      previousMonthRating:
          (json['previousMonthrating'] as num?)?.toDouble() ?? 0.0,
      ratingStatus: json['ratingStatus'] ?? 'no change',
      ratingPercentageChange:
          (json['ratingPercentageChange'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TopProductModel extends TopProductEntity {
  TopProductModel({
    required super.id,
    required super.totalSales,
    required super.orderCount,
    required super.name,
    required super.categoryName,
    super.imageUrl,
  });

  factory TopProductModel.fromJson(Map<String, dynamic> json) {
    final tabletDetails = json['tabletDetails'] ?? {};
    final files = (tabletDetails['files'] as List?) ?? [];
    final fallbackImageUrls = (tabletDetails['imageUrl'] as List?) ?? [];

    // Prioritize main category name (Medicine, Nursing Care, etc.) as per user request
    final categoryDetails = tabletDetails['categoryDetails'] ?? {};

    String catName = categoryDetails['name']?.toString() ?? 'Medicine';

    return TopProductModel(
      id: json['_id'] ?? '',
      totalSales: json['totalSales'] ?? 0,
      orderCount: json['orderCount'] ?? 0,
      name: tabletDetails['name'] ?? 'Unknown',
      categoryName: catName,
      imageUrl: files.isNotEmpty
          ? files.first
          : (fallbackImageUrls.isNotEmpty ? fallbackImageUrls.first : null),
    );
  }
}

class RecentLeadModel extends RecentLeadEntity {
  RecentLeadModel({
    required super.id,
    required super.name,
    required super.phone,
    super.address,
    required super.serviceName,
    required super.createdAt,
    required super.leadStage,
  });

  factory RecentLeadModel.fromJson(Map<String, dynamic> json) {
    final tabletDetails = json['tabletDetails'] ?? {};

    return RecentLeadModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      phone: json['phone'] ?? '',
      address: json['address'],
      serviceName: tabletDetails['name'] ?? 'Unknown',
      createdAt: DateTime.parse(json['createdAt']),
      leadStage: json['leadStage'] ?? 'new',
    );
  }
}

class DashboardUserModel extends DashboardUserEntity {
  DashboardUserModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.profileImageUrl,
    super.serviceType,
  });

  factory DashboardUserModel.fromJson(Map<String, dynamic> json) {
    return DashboardUserModel(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profileImageUrl:
          json['profileImage'] != null ? json['profileImage']['url'] : null,
      serviceType: json['serviceType'],
    );
  }
}
