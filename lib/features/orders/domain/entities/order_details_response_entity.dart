import 'package:equatable/equatable.dart';
import 'order_entity.dart';
import 'rental_booking_entity.dart';

class OrderDetailsResponseEntity extends Equatable {
  final String id;
  final String orderId;
  final String orderRef;
  final String vendorId;
  final String paymentStatus;
  final String orderStatus;
  final String bookingType;
  final String orderType;
  final DateTime createdAt;
  final double subtotal;
  final double tax;
  final double total;
  final OrderBillingSummaryEntity billingSummary;
  final List<OrderDetailsItemEntity> items;
  final FullUserDetailsEntity? userDetails;
  final AddressDetailsEntity? shippingAddressDetails;
  final AddressDetailsEntity? billingAddressDetails;

  const OrderDetailsResponseEntity({
    required this.id,
    required this.orderId,
    required this.orderRef,
    required this.vendorId,
    required this.paymentStatus,
    required this.orderStatus,
    required this.bookingType,
    required this.orderType,
    required this.createdAt,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.billingSummary,
    required this.items,
    this.userDetails,
    this.shippingAddressDetails,
    this.billingAddressDetails,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        orderRef,
        vendorId,
        paymentStatus,
        orderStatus,
        bookingType,
        orderType,
        createdAt,
        subtotal,
        tax,
        total,
        billingSummary,
        items,
        userDetails,
        shippingAddressDetails,
        billingAddressDetails,
      ];
}

class OrderBillingSummaryEntity extends Equatable {
  final double subtotal;
  final double totalGst;
  final double finalAmount;
  final double unitPrice;
  final double gstAmount;
  final double paidAmount;

  const OrderBillingSummaryEntity({
    required this.subtotal,
    required this.totalGst,
    required this.finalAmount,
    required this.unitPrice,
    required this.gstAmount,
    this.paidAmount = 0.0,
  });

  @override
  List<Object?> get props =>
      [subtotal, totalGst, finalAmount, unitPrice, gstAmount, paidAmount];
}

class OrderDetailsItemEntity extends Equatable {
  final String orderItemId;
  final int quantity;
  final String type;
  final String bookingType;
  final double price; // Added to capture item price
  final OrderBillingSummaryEntity billingSummary;
  final ProductDetailsEntity productDetails;
  final double vendorCommissionAmount;
  final RentalDetailsEntity? rentalDetails; // Added for rental orders

  const OrderDetailsItemEntity({
    required this.orderItemId,
    required this.quantity,
    required this.type,
    required this.bookingType,
    required this.price,
    required this.billingSummary,
    required this.productDetails,
    required this.vendorCommissionAmount,
    this.rentalDetails,
  });

  @override
  List<Object?> get props => [
        orderItemId,
        quantity,
        type,
        bookingType,
        price,
        billingSummary,
        productDetails,
        vendorCommissionAmount,
        rentalDetails,
      ];
}
