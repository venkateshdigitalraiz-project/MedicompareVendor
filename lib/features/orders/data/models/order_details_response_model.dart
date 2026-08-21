import '../../domain/entities/order_details_response_entity.dart';
import 'order_model.dart';
import 'rental_booking_model.dart';

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
    super.shippingAddressDetails,
    super.billingAddressDetails,
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
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((e) =>
                  OrderDetailsItemModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [OrderDetailsItemModel.fromJson(json)],
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

class OrderBillingSummaryModel extends OrderBillingSummaryEntity {
  const OrderBillingSummaryModel({
    required super.subtotal,
    required super.totalGst,
    required super.finalAmount,
    required super.unitPrice,
    required super.gstAmount,
    super.paidAmount,
  });

  factory OrderBillingSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderBillingSummaryModel(
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      totalGst: double.tryParse(json['totalGst']?.toString() ?? '0') ?? 0.0,
      finalAmount: double.tryParse(json['finalAmount']?.toString() ?? '0') ?? 0.0,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      gstAmount: double.tryParse(json['gstAmount']?.toString() ?? '0') ?? 0.0,
      paidAmount: double.tryParse(json['paidAmount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class OrderDetailsItemModel extends OrderDetailsItemEntity {
  const OrderDetailsItemModel({
    required super.orderItemId,
    required super.quantity,
    required super.type,
    required super.bookingType,
    required super.price,
    required super.billingSummary,
    required super.productDetails,
    required super.vendorCommissionAmount,
    super.rentalDetails,
  });

  factory OrderDetailsItemModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsItemModel(
      orderItemId: json['orderItemId']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      type: json['type']?.toString() ?? '',
      bookingType: json['bookingType']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      billingSummary: OrderBillingSummaryModel.fromJson(
          json['billingSummary'] ?? <String, dynamic>{}),
      productDetails: json['productDetails'] != null
          ? ProductDetailsModel.fromJson(json['productDetails'])
          : ProductDetailsModel.fromJson(json),
      vendorCommissionAmount: (json['vendorCommissionAmount'] ??
              json['vendorcommissionamount'] ??
              0)
          .toDouble(),
      rentalDetails: json['rentalDetails'] != null
          ? RentalDetailsModel.fromJson(json['rentalDetails'])
          : RentalDetailsModel.fromJson(json),
    );
  }
}
