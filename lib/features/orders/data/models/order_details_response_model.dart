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
    required super.paymentMethod,
    required super.createdAt,
    required super.subtotal,
    required super.tax,
    required super.total,
    required super.billingSummary,
    required super.items,
    super.userDetails,
    super.shippingAddressDetails,
    super.billingAddressDetails,
    super.branchDetails,
    super.subBranchDetails,
    super.installmentList = const [],
    super.deliveries = const [],
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
      paymentMethod: (json['orderDetails']?['paymentmethod'] ??
                  json['orderDetails']?['paymentMethod'] ??
                  json['paymentMethod'] ??
                  json['paymentmethod'])
              ?.toString() ??
          '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      subtotal: (json['baseAmount'] ?? 0).toDouble(),
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
      userDetails: () {
        final u = json['userDetails'] ??
            json['orderDetails']?['userDetails'] ??
            json['user'] ??
            json['customer'] ??
            json['customerDetails'] ??
            (json['items'] is List &&
                    (json['items'] as List).isNotEmpty &&
                    json['items'][0] is Map
                ? (json['items'][0]['orderDetails']?['userDetails'] ??
                    json['items'][0]['userDetails'])
                : null);
        if (u != null && u is Map) {
          final map = Map<String, dynamic>.from(u);
          if ((map['custId'] == null && map['cust_id'] == null) &&
              (json['custId'] != null || json['customerId'] != null)) {
            map['custId'] = json['custId'] ?? json['customerId'];
          }
          return FullUserDetailsModel.fromJson(map);
        }
        return null;
      }(),
      shippingAddressDetails: json['shippingAddressDetails'] != null
          ? AddressDetailsModel.fromJson(json['shippingAddressDetails'])
          : null,
      billingAddressDetails: json['billingAddressDetails'] != null
          ? AddressDetailsModel.fromJson(json['billingAddressDetails'])
          : null,
      branchDetails: json['branchDetails'] ??
          json['branch'] ??
          json['orderDetails']?['branchDetails'] ??
          json['orderDetails']?['branch'],
      subBranchDetails: json['subBranchDetails'] ??
          json['subBranch'] ??
          json['subbranch'] ??
          json['sub_branch'] ??
          json['subbranchDetails'] ??
          json['orderDetails']?['subBranchDetails'] ??
          json['orderDetails']?['subBranch'],
      installmentList: () {
        final list = json['installmentlist'] ??
            json['installmentList'] ??
            json['installment_list'] ??
            json['installments'] ??
            json['orderDetails']?['installmentlist'] ??
            json['orderDetails']?['installmentList'];
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map((e) => InstallmentItemModel.fromJson(e))
              .toList();
        }
        if (list is List<dynamic>) {
          return list
              .whereType<Map>()
              .map((e) => InstallmentItemModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList();
        }
        return <InstallmentItemModel>[];
      }(),
      deliveries: () {
        final dList = json['deliveries'] ??
            json['delivery'] ??
            json['orderDetails']?['deliveries'] ??
            json['orderDetails']?['delivery'];
        if (dList is List && dList.isNotEmpty) {
          return dList
              .whereType<Map>()
              .map((e) => OrderDeliveryModel.fromJson(
                  Map<String, dynamic>.from(e)))
              .toList();
        } else if (dList is Map) {
          return [
            OrderDeliveryModel.fromJson(Map<String, dynamic>.from(dList))
          ];
        }
        final directPartner = json['deliveryPartnerDetails'] ??
            json['deliveryPartner'] ??
            json['driverDetails'] ??
            json['assignedDriver'] ??
            json['deliveryman'] ??
            json['orderDetails']?['deliveryPartnerDetails'] ??
            json['orderDetails']?['deliveryPartner'];
        if (directPartner is Map) {
          return [
            OrderDeliveryModel(
              id: json['_id']?.toString() ?? '',
              vendorId: json['vendorId']?.toString() ?? '',
              deliveryPartnerType: (json['deliveryPartnerType'] ??
                      json['deliveryManType'] ??
                      directPartner['deliveryManType'] ??
                      'admin')
                  .toString(),
              deliveryPartner: (json['deliveryPartner'] is String
                      ? json['deliveryPartner']
                      : 'medicompares')
                  .toString(),
              deliveryPartnerId: (json['deliveryPartnerId'] ??
                      directPartner['_id'] ??
                      directPartner['id'] ??
                      '')
                  .toString(),
              deliveryOtp: (json['deliveryOtp'] ??
                      json['otp'] ??
                      directPartner['otp'] ??
                      '')
                  .toString(),
              deliveryAssignedAt: json['deliveryAssignedAt'] != null
                  ? DateTime.tryParse(json['deliveryAssignedAt'].toString())
                  : (json['assignedAt'] != null
                      ? DateTime.tryParse(json['assignedAt'].toString())
                      : null),
              deliveryPartnerDetails: OrderDeliveryPartnerDetailsModel.fromJson(
                  Map<String, dynamic>.from(directPartner)),
            )
          ];
        }
        return <OrderDeliveryModel>[];
      }(),
    );
  }
}

class OrderDeliveryPartnerDetailsModel
    extends OrderDeliveryPartnerDetailsEntity {
  const OrderDeliveryPartnerDetailsModel({
    super.id,
    required super.name,
    super.phone,
    super.email,
    super.vehicleNumber,
    super.profileImage,
    super.rating,
    super.partnerId,
    super.deliveryManType,
  });

  factory OrderDeliveryPartnerDetailsModel.fromJson(
      Map<String, dynamic> json) {
    final files = json['files'] is List ? (json['files'] as List) : [];
    final img = files.isNotEmpty
        ? files.first.toString()
        : (json['profileImage'] ?? json['image'])?.toString();

    return OrderDeliveryPartnerDetailsModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: (json['name'] ??
              json['fullName'] ??
              json['firstName'] ??
              'Delivery Partner')
          .toString(),
      phone: (json['phone'] ?? json['mobile'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      vehicleNumber: (json['vehicleNumber'] ??
              json['vehicle_number'] ??
              json['vehicleNo'] ??
              '')
          .toString(),
      profileImage: img,
      rating: double.tryParse((json['rating'] ?? 0).toString()) ?? 0.0,
      partnerId: (json['partnerId'] ??
              json['partner_id'] ??
              json['deliveryManId'] ??
              '')
          .toString(),
      deliveryManType: (json['deliveryManType'] ??
              json['delivery_man_type'] ??
              json['deliveryPartnerType'] ??
              'admin')
          .toString(),
    );
  }
}

class OrderDeliveryModel extends OrderDeliveryEntity {
  const OrderDeliveryModel({
    super.id,
    super.vendorId,
    super.deliveryPartnerType,
    super.deliveryPartner,
    super.deliveryPartnerId,
    super.deliveryFee,
    super.deliveryNotes,
    super.deliveryAssignedAt,
    super.deliveryCompletedAt,
    super.deliveryOtp,
    super.isDeliveryVerified,
    super.deliveryPartnerDetails,
  });

  factory OrderDeliveryModel.fromJson(Map<String, dynamic> json) {
    OrderDeliveryPartnerDetailsModel? partner;
    final pMap = json['deliveryPartnerDetails'] ??
        json['deliveryPartner'] ??
        json['deliveryman'] ??
        json['partner'];
    if (pMap is Map<String, dynamic>) {
      partner = OrderDeliveryPartnerDetailsModel.fromJson(pMap);
    } else if (pMap is Map) {
      partner = OrderDeliveryPartnerDetailsModel.fromJson(
          Map<String, dynamic>.from(pMap));
    }

    return OrderDeliveryModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      vendorId: (json['vendorId'] ?? json['vendor_id'])?.toString() ?? '',
      deliveryPartnerType: (json['deliveryPartnerType'] ??
              json['deliveryManType'] ??
              partner?.deliveryManType ??
              'admin')
          .toString(),
      deliveryPartner: (json['deliveryPartner'] is String
              ? json['deliveryPartner']
              : 'medicompares')
          .toString(),
      deliveryPartnerId: (json['deliveryPartnerId'] ??
              json['delivery_partner_id'] ??
              partner?.id ??
              '')
          .toString(),
      deliveryFee: double.tryParse(
              (json['deliveryFee'] ?? json['delivery_fee'] ?? 0).toString()) ??
          0.0,
      deliveryNotes: json['deliveryNotes']?.toString(),
      deliveryAssignedAt: json['deliveryAssignedAt'] != null
          ? DateTime.tryParse(json['deliveryAssignedAt'].toString())
          : (json['assignedAt'] != null
              ? DateTime.tryParse(json['assignedAt'].toString())
              : null),
      deliveryCompletedAt: json['deliveryCompletedAt'] != null
          ? DateTime.tryParse(json['deliveryCompletedAt'].toString())
          : null,
      deliveryOtp: (json['deliveryOtp'] ??
              json['delivery_otp'] ??
              json['otp'] ??
              '')
          .toString(),
      isDeliveryVerified: json['isDeliveryVerified'] == true ||
          json['is_delivery_verified'] == true,
      deliveryPartnerDetails: partner,
    );
  }
}

class InstallmentItemModel extends InstallmentItemEntity {
  const InstallmentItemModel({
    required super.id,
    required super.orderId,
    super.userId = '',
    required super.installmentNumber,
    required super.amount,
    super.dueDate,
    super.paidDate,
    required super.status,
    required super.paymentMethod,
    super.paymentId,
    super.transactionId,
    super.lateFee = 0.0,
    super.reminderSent = false,
    super.createdAt,
    super.updatedAt,
  });

  factory InstallmentItemModel.fromJson(Map<String, dynamic> json) {
    return InstallmentItemModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      orderId: (json['orderId'] ?? json['order_id'])?.toString() ?? '',
      userId: (json['userId'] ?? json['user_id'])?.toString() ?? '',
      installmentNumber: int.tryParse((json['installmentNumber'] ??
                  json['installment_number'] ??
                  json['sno'] ??
                  0)
              .toString()) ??
          0,
      amount: double.tryParse((json['amount'] ?? 0).toString()) ?? 0.0,
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'].toString())
          : (json['due_date'] != null
              ? DateTime.tryParse(json['due_date'].toString())
              : null),
      paidDate: json['paidDate'] != null
          ? DateTime.tryParse(json['paidDate'].toString())
          : (json['paid_date'] != null
              ? DateTime.tryParse(json['paid_date'].toString())
              : null),
      status: (json['status'] ?? '').toString(),
      paymentMethod: (json['paymentMethod'] ??
              json['paymentmethod'] ??
              json['payment_method'] ??
              json['type'] ??
              '')
          .toString(),
      paymentId: json['paymentId']?.toString(),
      transactionId:
          (json['transactionId'] ?? json['transaction_id'])?.toString(),
      lateFee: double.tryParse(
              (json['lateFee'] ?? json['late_fee'] ?? 0).toString()) ??
          0.0,
      reminderSent:
          json['reminderSent'] == true || json['reminder_sent'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
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
    super.couponType,
    super.couponDiscount,
  });

  factory OrderBillingSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderBillingSummaryModel(
      subtotal: double.tryParse(json['baseAmount']?.toString() ?? '0') ?? 0.0,
      totalGst: double.tryParse(json['totalGst']?.toString() ?? '0') ?? 0.0,
      finalAmount:
          double.tryParse(json['finalAmount']?.toString() ?? '0') ?? 0.0,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      gstAmount: double.tryParse(json['gstAmount']?.toString() ?? '0') ?? 0.0,
      paidAmount: double.tryParse(json['paidAmount']?.toString() ?? '0') ?? 0.0,
      couponType: (json['couponType'] ?? json['coupontype'])?.toString(),
      couponDiscount: double.tryParse((json['couponDiscount'] ??
                      json['couponAmount'] ??
                      json['coupon_discount'] ??
                      json['discountAmount'] ??
                      json['discount'] ??
                      json['couponValue'])
                  ?.toString() ??
              '0') ??
          0.0,
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
          : json['productSnapshot'] != null
              ? ProductDetailsModel.fromJson(json['productSnapshot'])
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
