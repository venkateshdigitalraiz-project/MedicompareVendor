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
  final String paymentMethod;
  final DateTime createdAt;
  final double subtotal;
  final double tax;
  final double total;
  final OrderBillingSummaryEntity billingSummary;
  final List<OrderDetailsItemEntity> items;
  final FullUserDetailsEntity? userDetails;
  final AddressDetailsEntity? shippingAddressDetails;
  final AddressDetailsEntity? billingAddressDetails;
  final dynamic branchDetails;
  final dynamic subBranchDetails;
  final List<InstallmentItemEntity> installmentList;
  final List<OrderDeliveryEntity> deliveries;
  final String? otpEnable;
  final String? otpStatus;
  final String? adminprescription;
  final List<String> prescriptionImages;

  const OrderDetailsResponseEntity({
    required this.id,
    required this.orderId,
    required this.orderRef,
    required this.vendorId,
    required this.paymentStatus,
    required this.orderStatus,
    required this.bookingType,
    required this.orderType,
    required this.paymentMethod,
    required this.createdAt,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.billingSummary,
    required this.items,
    this.userDetails,
    this.shippingAddressDetails,
    this.billingAddressDetails,
    this.branchDetails,
    this.subBranchDetails,
    this.installmentList = const [],
    this.deliveries = const [],
    this.otpEnable = "no",
    this.otpStatus = "pending",
    this.adminprescription,
    this.prescriptionImages = const [],
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
        paymentMethod,
        createdAt,
        subtotal,
        tax,
        total,
        billingSummary,
        items,
        userDetails,
        shippingAddressDetails,
        billingAddressDetails,
        branchDetails,
        subBranchDetails,
        installmentList,
        deliveries,
        otpEnable,
        otpStatus,
        adminprescription,
        prescriptionImages,
      ];
}

class InstallmentItemEntity extends Equatable {
  final String id;
  final String orderId;
  final String userId;
  final int installmentNumber;
  final double amount;
  final DateTime? dueDate;
  final DateTime? paidDate;
  final String status;
  final String paymentMethod;
  final String? paymentId;
  final String? transactionId;
  final double lateFee;
  final bool reminderSent;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InstallmentItemEntity({
    required this.id,
    required this.orderId,
    this.userId = '',
    required this.installmentNumber,
    required this.amount,
    this.dueDate,
    this.paidDate,
    required this.status,
    required this.paymentMethod,
    this.paymentId,
    this.transactionId,
    this.lateFee = 0.0,
    this.reminderSent = false,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        userId,
        installmentNumber,
        amount,
        dueDate,
        paidDate,
        status,
        paymentMethod,
        paymentId,
        transactionId,
        lateFee,
        reminderSent,
        createdAt,
        updatedAt,
      ];
}

class OrderBillingSummaryEntity extends Equatable {
  final double subtotal;
  final double totalGst;
  final double finalAmount;
  final double unitPrice;
  final double baseAmount;
  final double gstAmount;
  final double paidAmount;
  final String? couponType;
  final double couponDiscount;
  final double deliveryCharges;
  final double totalPayAmount;

  const OrderBillingSummaryEntity({
    required this.subtotal,
    required this.totalGst,
    required this.finalAmount,
    required this.unitPrice,
    this.baseAmount = 0.0,
    required this.gstAmount,
    this.paidAmount = 0.0,
    this.couponType,
    this.couponDiscount = 0.0,
    this.deliveryCharges = 0.0,
    this.totalPayAmount = 0.0,
  });

  @override
  List<Object?> get props => [
        subtotal,
        totalGst,
        finalAmount,
        unitPrice,
        baseAmount,
        gstAmount,
        paidAmount,
        couponType,
        couponDiscount,
        deliveryCharges,
        totalPayAmount,
      ];
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

class OrderDeliveryPartnerDetailsEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String vehicleNumber;
  final String? profileImage;
  final double rating;
  final String partnerId;
  final String deliveryManType;

  const OrderDeliveryPartnerDetailsEntity({
    this.id = '',
    required this.name,
    this.phone = '',
    this.email = '',
    this.vehicleNumber = '',
    this.profileImage,
    this.rating = 0.0,
    this.partnerId = '',
    this.deliveryManType = 'admin',
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        vehicleNumber,
        profileImage,
        rating,
        partnerId,
        deliveryManType,
      ];
}

class OrderDeliveryEntity extends Equatable {
  final String id;
  final String vendorId;
  final String deliveryPartnerType;
  final String deliveryPartner;
  final String deliveryPartnerId;
  final double deliveryFee;
  final String? deliveryNotes;
  final DateTime? deliveryAssignedAt;
  final DateTime? deliveryCompletedAt;
  final String deliveryOtp;
  final bool isDeliveryVerified;
  final OrderDeliveryPartnerDetailsEntity? deliveryPartnerDetails;

  const OrderDeliveryEntity({
    this.id = '',
    this.vendorId = '',
    this.deliveryPartnerType = 'admin',
    this.deliveryPartner = 'medicompares',
    this.deliveryPartnerId = '',
    this.deliveryFee = 0.0,
    this.deliveryNotes,
    this.deliveryAssignedAt,
    this.deliveryCompletedAt,
    this.deliveryOtp = '',
    this.isDeliveryVerified = false,
    this.deliveryPartnerDetails,
  });

  @override
  List<Object?> get props => [
        id,
        vendorId,
        deliveryPartnerType,
        deliveryPartner,
        deliveryPartnerId,
        deliveryFee,
        deliveryNotes,
        deliveryAssignedAt,
        deliveryCompletedAt,
        deliveryOtp,
        isDeliveryVerified,
        deliveryPartnerDetails,
      ];
}
