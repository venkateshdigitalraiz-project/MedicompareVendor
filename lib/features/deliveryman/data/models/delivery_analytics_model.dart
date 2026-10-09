import 'package:flutter/foundation.dart';
import '../../domain/entities/delivery_analytics_entity.dart';

class DeliveryAnalyticsModel extends DeliveryAnalyticsEntity {
  const DeliveryAnalyticsModel({
    super.totalOrders,
    super.deliveredOrders,
    super.deliveredRate,
    super.inTransitOrders,
    super.activeDeliverymen,
    super.totalDeliverymen,
    super.statusDistribution,
    super.topDeliveryPersonnel,
  });

  factory DeliveryAnalyticsModel.fromJson(Map<String, dynamic> json) {
    try {
      // Check if wrapped in data or direct map
      final Map<String, dynamic> data =
          (json['data'] is Map<String, dynamic>)
              ? json['data']
              : (json['data'] is Map ? Map<String, dynamic>.from(json['data']) : json);

      final Map<String, dynamic> summary = data['summary'] is Map
          ? Map<String, dynamic>.from(data['summary'])
          : data;

      final totalOrders = _parseInt(summary['totalOrders'] ??
          summary['total_orders'] ??
          summary['total'] ??
          summary['totalOrdersCount'] ??
          summary['ordersCount']);

      final deliveredOrders = _parseInt(summary['totalCompleted'] ??
          summary['deliveredOrders'] ??
          summary['delivered_orders'] ??
          summary['delivered'] ??
          summary['deliveredCount'] ??
          summary['delivered_count']);

      final inTransitOrders = _parseInt(summary['totalInTransit'] ??
          summary['inTransitOrders'] ??
          summary['in_transit_orders'] ??
          summary['inTransit'] ??
          summary['in_transit'] ??
          summary['inTransitCount'] ??
          summary['in_transit_count']);

      final activeDeliverymen = _parseInt(summary['activeDeliverymen'] ??
          summary['active_deliverymen'] ??
          summary['active'] ??
          summary['activeDeliveryman'] ??
          summary['active_count'] ??
          summary['activePartners']);

      final totalDeliverymen = _parseInt(summary['totalDeliveryMen'] ??
          summary['totalDeliverymen'] ??
          summary['total_deliverymen'] ??
          summary['totalPersonnel'] ??
          summary['total_personnel'] ??
          summary['deliverymenCount'] ??
          summary['totalDeliveryPartners']);

      double deliveredRate = _parseDouble(summary['deliveredRate'] ??
          summary['delivered_rate'] ??
          summary['deliveryRate'] ??
          summary['delivery_rate'] ??
          summary['successRate'] ??
          summary['success_rate']);

      if (deliveredRate == 0.0 && totalOrders > 0) {
        deliveredRate = ((deliveredOrders / totalOrders) * 100);
      }

      OrderStatusDistributionEntity statusDist =
          const OrderStatusDistributionEntity();

      final rawDist = data['statusDistribution'] ??
          data['status_distribution'] ??
          data['distribution'] ??
          data['order_status_distribution'] ??
          data['orderStatusDistribution'];

      if (rawDist is Map) {
        statusDist = OrderStatusDistributionModel.fromJson(
            Map<String, dynamic>.from(rawDist), totalOrders);
      } else {
        final double delPerc =
            totalOrders > 0 ? (deliveredOrders / totalOrders) * 100 : 0.0;
        final double inTransPerc =
            totalOrders > 0 ? (inTransitOrders / totalOrders) * 100 : 0.0;
        statusDist = OrderStatusDistributionEntity(
          deliveredCount: deliveredOrders,
          deliveredPercentage: delPerc,
          inTransitCount: inTransitOrders,
          inTransitPercentage: inTransPerc,
          assignedCount: _parseInt(data['assignedOrders'] ??
              data['assigned'] ??
              data['assigned_orders']),
          assignedPercentage: _parseDouble(
              data['assignedPercentage'] ?? data['assigned_percentage']),
          cancelledCount: _parseInt(data['cancelledOrders'] ??
              data['cancelled'] ??
              data['cancelled_orders'] ??
              data['canceled']),
          cancelledPercentage: _parseDouble(
              data['cancelledPercentage'] ?? data['cancelled_percentage']),
        );
      }

      List<TopDeliveryPersonnelEntity> topPersonnel = [];
      final rawList = data['deliveryMen'] ??
          data['deliverymen'] ??
          data['topDeliveryPersonnel'] ??
          data['top_delivery_personnel'] ??
          data['topPersonnel'] ??
          data['top_personnel'] ??
          data['partners'] ??
          data['deliveryPartners'] ??
          data['directory'] ??
          data['list'];

      if (rawList is List) {
        for (var item in rawList) {
          if (item is Map) {
            topPersonnel.add(TopDeliveryPersonnelModel.fromJson(
                Map<String, dynamic>.from(item)));
          }
        }
      }

      return DeliveryAnalyticsModel(
        totalOrders: totalOrders,
        deliveredOrders: deliveredOrders,
        deliveredRate: deliveredRate,
        inTransitOrders: inTransitOrders,
        activeDeliverymen: activeDeliverymen,
        totalDeliverymen: totalDeliverymen,
        statusDistribution: statusDist,
        topDeliveryPersonnel: topPersonnel,
      );
    } catch (e, stack) {
      if (kDebugMode) {
        print('[DeliveryAnalyticsModel] Parsing error: $e\n$stack');
      }
      return const DeliveryAnalyticsModel();
    }
  }

  static int _parseInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    if (val is String) {
      return int.tryParse(val) ?? (double.tryParse(val)?.toInt() ?? 0);
    }
    return 0;
  }

  static double _parseDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) {
      final cleaned = val.replaceAll('%', '').trim();
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }
}

class OrderStatusDistributionModel extends OrderStatusDistributionEntity {
  const OrderStatusDistributionModel({
    super.deliveredPercentage,
    super.inTransitPercentage,
    super.assignedPercentage,
    super.cancelledPercentage,
    super.deliveredCount,
    super.inTransitCount,
    super.assignedCount,
    super.cancelledCount,
  });

  factory OrderStatusDistributionModel.fromJson(
      Map<String, dynamic> json, int totalOrders) {
    // Helper to safely extract count or percentage from either direct value or nested map
    dynamic extractValue(String key, String field) {
      if (json[key] is Map) {
        return json[key][field];
      }
      return null;
    }

    final delVal = extractValue('delivered', 'percentage') ??
        json['deliveredPercentage'] ??
        json['delivered_percentage'];
    final inTransVal = extractValue('inTransit', 'percentage') ??
        json['inTransitPercentage'] ??
        json['in_transit_percentage'];
    final assignedVal = extractValue('assigned', 'percentage') ??
        json['assignedPercentage'] ??
        json['assigned_percentage'];
    final cancelledVal = extractValue('cancelled', 'percentage') ??
        json['cancelledPercentage'] ??
        json['cancelled_percentage'];

    double delPerc = DeliveryAnalyticsModel._parseDouble(delVal);
    double inTransPerc = DeliveryAnalyticsModel._parseDouble(inTransVal);
    double assignedPerc = DeliveryAnalyticsModel._parseDouble(assignedVal);
    double cancelledPerc = DeliveryAnalyticsModel._parseDouble(cancelledVal);

    int delCount = DeliveryAnalyticsModel._parseInt(extractValue('delivered', 'count') ??
        json['deliveredCount'] ??
        json['delivered_count'] ??
        (json['delivered'] is num ? json['delivered'] : null));
    int inTransCount = DeliveryAnalyticsModel._parseInt(extractValue('inTransit', 'count') ??
        json['inTransitCount'] ??
        json['in_transit_count'] ??
        (json['inTransit'] is num ? json['inTransit'] : null));
    int assignedCount = DeliveryAnalyticsModel._parseInt(extractValue('assigned', 'count') ??
        json['assignedCount'] ??
        json['assigned_count'] ??
        (json['assigned'] is num ? json['assigned'] : null));
    int cancelledCount = DeliveryAnalyticsModel._parseInt(extractValue('cancelled', 'count') ??
        json['cancelledCount'] ??
        json['cancelled_count'] ??
        (json['cancelled'] is num ? json['cancelled'] : null));

    if (totalOrders > 0) {
      if (delPerc == 0.0 && delCount > 0) {
        delPerc = (delCount / totalOrders) * 100;
      }
      if (inTransPerc == 0.0 && inTransCount > 0) {
        inTransPerc = (inTransCount / totalOrders) * 100;
      }
      if (assignedPerc == 0.0 && assignedCount > 0) {
        assignedPerc = (assignedCount / totalOrders) * 100;
      }
      if (cancelledPerc == 0.0 && cancelledCount > 0) {
        cancelledPerc = (cancelledCount / totalOrders) * 100;
      }
    }

    return OrderStatusDistributionModel(
      deliveredPercentage: delPerc,
      inTransitPercentage: inTransPerc,
      assignedPercentage: assignedPerc,
      cancelledPercentage: cancelledPerc,
      deliveredCount: delCount,
      inTransitCount: inTransCount,
      assignedCount: assignedCount,
      cancelledCount: cancelledCount,
    );
  }
}

class TopDeliveryPersonnelModel extends TopDeliveryPersonnelEntity {
  const TopDeliveryPersonnelModel({
    super.id,
    super.name,
    super.deliveries,
    super.rating,
    super.phone,
  });

  factory TopDeliveryPersonnelModel.fromJson(Map<String, dynamic> json) {
    final rawRating = json['rating'] ??
        json['avg_rating'] ??
        json['averageRating'] ??
        json['average_rating'];
    String ratingStr = 'N/A';
    if (rawRating != null) {
      if (rawRating is num && rawRating > 0) {
        ratingStr = rawRating.toStringAsFixed(1);
      } else if (rawRating is String &&
          rawRating.isNotEmpty &&
          rawRating != 'null') {
        ratingStr = rawRating;
      }
    }

    return TopDeliveryPersonnelModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ??
          json['fullName']?.toString() ??
          json['full_name']?.toString() ??
          json['partner_name']?.toString() ??
          'Personnel',
      deliveries: DeliveryAnalyticsModel._parseInt(json['totalOrders'] ??
          json['deliveries'] ??
          json['total_deliveries'] ??
          json['ordersCount'] ??
          json['deliveredCount'] ??
          json['totalDeliveries']),
      rating: ratingStr,
      phone: json['phone']?.toString() ??
          json['phoneNumber']?.toString() ??
          json['phone_number']?.toString() ??
          json['mobile']?.toString() ??
          json['contact']?.toString() ??
          '',
    );
  }
}
