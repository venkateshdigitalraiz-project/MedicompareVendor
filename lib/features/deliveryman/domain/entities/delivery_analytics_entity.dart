import 'package:equatable/equatable.dart';

class DeliveryAnalyticsEntity extends Equatable {
  final int totalOrders;
  final int deliveredOrders;
  final double deliveredRate;
  final int inTransitOrders;
  final int activeDeliverymen;
  final int totalDeliverymen;
  final OrderStatusDistributionEntity statusDistribution;
  final List<TopDeliveryPersonnelEntity> topDeliveryPersonnel;

  const DeliveryAnalyticsEntity({
    this.totalOrders = 0,
    this.deliveredOrders = 0,
    this.deliveredRate = 0.0,
    this.inTransitOrders = 0,
    this.activeDeliverymen = 0,
    this.totalDeliverymen = 0,
    this.statusDistribution = const OrderStatusDistributionEntity(),
    this.topDeliveryPersonnel = const [],
  });

  @override
  List<Object?> get props => [
        totalOrders,
        deliveredOrders,
        deliveredRate,
        inTransitOrders,
        activeDeliverymen,
        totalDeliverymen,
        statusDistribution,
        topDeliveryPersonnel,
      ];
}

class OrderStatusDistributionEntity extends Equatable {
  final double deliveredPercentage;
  final double inTransitPercentage;
  final double assignedPercentage;
  final double cancelledPercentage;
  final int deliveredCount;
  final int inTransitCount;
  final int assignedCount;
  final int cancelledCount;

  const OrderStatusDistributionEntity({
    this.deliveredPercentage = 0.0,
    this.inTransitPercentage = 0.0,
    this.assignedPercentage = 0.0,
    this.cancelledPercentage = 0.0,
    this.deliveredCount = 0,
    this.inTransitCount = 0,
    this.assignedCount = 0,
    this.cancelledCount = 0,
  });

  @override
  List<Object?> get props => [
        deliveredPercentage,
        inTransitPercentage,
        assignedPercentage,
        cancelledPercentage,
        deliveredCount,
        inTransitCount,
        assignedCount,
        cancelledCount,
      ];
}

class TopDeliveryPersonnelEntity extends Equatable {
  final String id;
  final String name;
  final int deliveries;
  final String rating;
  final String phone;

  const TopDeliveryPersonnelEntity({
    this.id = '',
    this.name = '',
    this.deliveries = 0,
    this.rating = 'N/A',
    this.phone = '',
  });

  @override
  List<Object?> get props => [id, name, deliveries, rating, phone];
}
