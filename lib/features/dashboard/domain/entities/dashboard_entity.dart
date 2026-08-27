class DashboardEntity {
  final OrderCountEntity orderCount;
  final RevenueEntity revenue;
  final LeadsEntity leads;
  final RatingEntity rating;
  final List<TopProductEntity> topProducts;
  final List<RecentLeadEntity> recentLeads;
  final DashboardUserEntity user;

  DashboardEntity({
    required this.orderCount,
    required this.revenue,
    required this.leads,
    required this.rating,
    required this.topProducts,
    required this.recentLeads,
    required this.user,
  });
}

class OrderCountEntity {
  final int totalOrder;
  final int currentMonthOrders;
  final int previousMonthOrders;
  final String orderStatus;
  final double orderPercentageChange;

  OrderCountEntity({
    required this.totalOrder,
    required this.currentMonthOrders,
    required this.previousMonthOrders,
    required this.orderStatus,
    required this.orderPercentageChange,
  });
}

class RevenueEntity {
  final double totalAmount;
  final double currentMonthAmount;
  final double previousMonthAmount;
  final String amountStatus;
  final double amountPercentageChange;

  RevenueEntity({
    required this.totalAmount,
    required this.currentMonthAmount,
    required this.previousMonthAmount,
    required this.amountStatus,
    required this.amountPercentageChange,
  });
}

class LeadsEntity {
  final int totalLeads;
  final int currentMonthLeads;
  final int previousMonthLeads;
  final String leadStatus;
  final double leadPercentageChange;

  LeadsEntity({
    required this.totalLeads,
    required this.currentMonthLeads,
    required this.previousMonthLeads,
    required this.leadStatus,
    required this.leadPercentageChange,
  });
}

class RatingEntity {
  final double totalRating;
  final double currentMonthRating;
  final double previousMonthRating;
  final String ratingStatus;
  final double ratingPercentageChange;

  RatingEntity({
    required this.totalRating,
    required this.currentMonthRating,
    required this.previousMonthRating,
    required this.ratingStatus,
    required this.ratingPercentageChange,
  });
}

class TopProductEntity {
  final String id;
  final int totalSales;
  final int orderCount;
  final String name;
  final String categoryName;
  final String? imageUrl;

  TopProductEntity({
    required this.id,
    required this.totalSales,
    required this.orderCount,
    required this.name,
    required this.categoryName,
    this.imageUrl,
  });
}

class RecentLeadEntity {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final String serviceName;
  final DateTime createdAt;
  final String leadStage;

  RecentLeadEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    required this.serviceName,
    required this.createdAt,
    required this.leadStage,
  });
}

class DashboardUserEntity {
  final String id;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;
  final String? serviceType;

  DashboardUserEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
    this.serviceType,
  });
}
