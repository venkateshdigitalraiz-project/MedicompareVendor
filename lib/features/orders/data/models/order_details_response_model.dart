import '../../domain/entities/order_details_response_entity.dart';
import 'order_model.dart';

class OrderDetailsResponseModel extends OrderDetailsResponseEntity {
  const OrderDetailsResponseModel({
    required super.id,
    required super.orderId,
    required super.orderRef,
    required super.vendorId,
    required super.paymentStatus,
    required super.orderStatus,
    required super.bookingType,
    required super.orderType,
    required super.createdAt,
    required super.subtotal,
    required super.tax,
    required super.total,
    required super.billingSummary,
    required super.items,
    super.userDetails,
  });

  factory OrderDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsResponseModel(
      id: json['_id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      orderRef: json['orderRef']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      bookingType: json['bookingType']?.toString() ?? '',
      orderType: json['orderType']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      billingSummary: OrderBillingSummaryModel.fromJson(
          json['billingSummary'] ?? <String, dynamic>{}),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => OrderDetailsItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      userDetails: json['userDetails'] != null
          ? FullUserDetailsModel.fromJson(json['userDetails'])
          : null,
    );
  }
}

class OrderBillingSummaryModel extends OrderBillingSummaryEntity {
  const OrderBillingSummaryModel({
    required super.subtotal,
    required super.totalGst,
    required super.finalAmount,
    required super.unitPrice,
    required super.gstAmount,
  });

  factory OrderBillingSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderBillingSummaryModel(
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      totalGst: (json['totalGst'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
    );
  }
}

class OrderDetailsItemModel extends OrderDetailsItemEntity {
  const OrderDetailsItemModel({
    required super.orderItemId,
    required super.quantity,
    required super.type,
    required super.bookingType,
    required super.billingSummary,
    required super.productDetails,
    required super.vendorCommissionAmount,
  });

  factory OrderDetailsItemModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsItemModel(
      orderItemId: json['orderItemId']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      type: json['type']?.toString() ?? '',
      bookingType: json['bookingType']?.toString() ?? '',
      billingSummary: OrderBillingSummaryModel.fromJson(
          json['billingSummary'] ?? <String, dynamic>{}),
      productDetails: () {
        final productSnapshot = Map<String, dynamic>.from(json['productSnapshot'] ?? {});
        if (productSnapshot['imageUrl'] != null) {
          final tabletDetails = productSnapshot['tabletDetails'] ?? productSnapshot['tabletdetails'];
          if (tabletDetails is Map<String, dynamic>) {
            tabletDetails['imageUrl'] = productSnapshot['imageUrl'];
          } else if (tabletDetails == null) {
            productSnapshot['tabletDetails'] = {'imageUrl': productSnapshot['imageUrl']};
          }
        }
        return ProductDetailsModel.fromJson(productSnapshot);
      }(),
      vendorCommissionAmount: (json['vendorCommissionAmount'] ??
              json['vendorcommissionamount'] ??
              0)
          .toDouble(),
    );
  }
}
