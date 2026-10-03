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
    super.otpEnable,
    super.otpStatus,
  });

  factory OrderDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsResponseModel(
      id: json['_id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      orderRef: json['orderRef']?.toString() ?? '',
      vendorId: json['vendorId']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      orderStatus: (json['orderStatus'] ??
              json['status'] ??
              json['orderDetails']?['orderStatus'] ??
              json['orderDetails']?['status'] ??
              (json['items'] is List &&
                      (json['items'] as List).isNotEmpty &&
                      json['items'][0] is Map
                  ? (json['items'][0]['orderStatus'] ??
                      json['items'][0]['status'] ??
                      json['items'][0]['orderDetails']?['orderStatus'] ??
                      json['items'][0]['orderDetails']?['status'])
                  : null))
          ?.toString() ??
          '',
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
      subtotal: double.tryParse((json['subtotal'] ??
              json['subTotal'] ??
              json['baseAmount'] ??
              json['base_amount'] ??
              json['billingSummary']?['subtotal'] ??
              json['billingSummary']?['baseAmount'] ??
              json['billingSummary']?['totalAmount'] ??
              json['total'] ??
              0)
          .toString()) ??
          0.0,
      tax: double.tryParse((json['tax'] ??
              json['gst'] ??
              json['totalGst'] ??
              json['billingSummary']?['totalGst'] ??
              0)
          .toString()) ??
          0.0,
      total: double.tryParse((json['total'] ??
              json['totalAmount'] ??
              json['finalAmount'] ??
              json['billingSummary']?['finalAmount'] ??
              0)
          .toString()) ??
          0.0,
      billingSummary: OrderBillingSummaryModel.fromJson(
          json['billingSummary'] ?? json['billing_summary'] ?? <String, dynamic>{}),
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
            json['orderDetails']?['installmentList'] ??
            json['orderDetails']?['installments'] ??
            (json['items'] is List &&
                    (json['items'] as List).isNotEmpty &&
                    json['items'][0] is Map
                ? (json['items'][0]['installmentlist'] ??
                    json['items'][0]['installmentList'] ??
                    json['items'][0]['installments'] ??
                    json['items'][0]['rentalDetails']?['installmentlist'] ??
                    json['items'][0]['rentalDetails']?['installmentList'] ??
                    json['items'][0]['rentalDetails']?['installments'])
                : null);
        if (list is List) {
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
            json['orderDetails']?['delivery'] ??
            (json['items'] is List &&
                    (json['items'] as List).isNotEmpty &&
                    json['items'][0] is Map
                ? (json['items'][0]['delivery'] ??
                    json['items'][0]['deliveries'] ??
                    json['items'][0]['orderDetails']?['delivery'] ??
                    json['items'][0]['orderDetails']?['deliveries'])
                : null);
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
            json['assignedPartnerDetails'] ??
            json['assignedPartner'] ??
            json['driverDetails'] ??
            json['assignedDriver'] ??
            json['deliveryman'] ??
            json['deliveryMan'] ??
            json['deliverymanDetails'] ??
            json['partnerDetails'] ??
            json['orderDetails']?['deliveryPartnerDetails'] ??
            json['orderDetails']?['deliveryPartner'] ??
            json['orderDetails']?['assignedPartnerDetails'] ??
            json['orderDetails']?['assignedPartner'] ??
            json['orderDetails']?['deliveryman'] ??
            json['orderDetails']?['deliveryMan'];
        if (directPartner is Map) {
          return [
            OrderDeliveryModel(
              id: json['_id']?.toString() ?? '',
              vendorId: json['vendorId']?.toString() ?? '',
              deliveryPartnerType: (json['deliveryPartnerType'] ??
                      json['deliveryManType'] ??
                      directPartner['deliveryManType'] ??
                      directPartner['deliveryPartnerType'] ??
                      'admin')
                  .toString(),
              deliveryPartner: (json['deliveryPartner'] is String
                      ? json['deliveryPartner']
                      : (directPartner['partnerType'] ?? 'medicompares'))
                  .toString(),
              deliveryPartnerId: (json['deliveryPartnerId'] ??
                      json['assignedPartnerId'] ??
                      directPartner['_id'] ??
                      directPartner['id'] ??
                      '')
                  .toString(),
              deliveryOtp: (json['deliveryOtp'] ??
                      json['otp'] ??
                      directPartner['otp'] ??
                      directPartner['deliveryOtp'] ??
                      '')
                  .toString(),
              deliveryAssignedAt: json['deliveryAssignedAt'] != null
                  ? DateTime.tryParse(json['deliveryAssignedAt'].toString())
                  : (json['assignedAt'] != null
                      ? DateTime.tryParse(json['assignedAt'].toString())
                      : (directPartner['assignedAt'] != null
                          ? DateTime.tryParse(
                              directPartner['assignedAt'].toString())
                          : null)),
              deliveryPartnerDetails: OrderDeliveryPartnerDetailsModel.fromJson(
                  Map<String, dynamic>.from(directPartner)),
            )
          ];
        }
        return <OrderDeliveryModel>[];
      }(),
      otpEnable: json['otpEnable']?.toString() ?? json['otp_enable']?.toString() ?? json['orderDetails']?['otpEnable']?.toString() ?? json['orderDetails']?['otp_enable']?.toString() ?? 'no',
      otpStatus: json['otpStatus']?.toString() ?? json['otp_status']?.toString() ?? json['orderDetails']?['otpStatus']?.toString() ?? json['orderDetails']?['otp_status']?.toString() ?? 'pending',
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
    super.baseAmount,
    required super.gstAmount,
    super.paidAmount,
    super.couponType,
    super.couponDiscount,
    super.deliveryCharges,
    super.totalPayAmount,
  });

  factory OrderBillingSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderBillingSummaryModel(
      subtotal: double.tryParse((json['subtotal'] ??
              json['subTotal'] ??
              json['baseAmount'] ??
              json['base_amount'] ??
              json['unitPrice'] ??
              json['totalAmount'] ??
              0)
          .toString()) ??
          0.0,
      totalGst: double.tryParse((json['totalGst'] ?? json['total_gst'] ?? json['gst'] ?? json['tax'] ?? 0).toString()) ?? 0.0,
      finalAmount:
          double.tryParse((json['finalAmount'] ?? json['final_amount'] ?? json['total'] ?? json['totalAmount'] ?? 0).toString()) ?? 0.0,
      unitPrice: double.tryParse((json['unitPrice'] ?? json['unit_price'] ?? json['price'] ?? 0).toString()) ?? 0.0,
      baseAmount: double.tryParse((json['baseAmount'] ?? json['base_amount'] ?? 0).toString()) ?? 0.0,
      gstAmount: double.tryParse((json['gstAmount'] ?? json['gst_amount'] ?? json['tax'] ?? 0).toString()) ?? 0.0,
      paidAmount: double.tryParse((json['paidAmount'] ?? json['paid_amount'] ?? 0).toString()) ?? 0.0,
      couponType: (json['couponType'] ?? json['coupontype'])?.toString(),
      couponDiscount: double.tryParse((json['couponDiscount'] ??
                      json['couponAmount'] ??
                      json['coupon_discount'] ??
                      json['discountAmount'] ??
                      json['discount'] ??
                      json['couponValue'] ??
                      0)
                  .toString()) ??
          0.0,
      deliveryCharges: double.tryParse((json['deliveryCharges'] ?? json['deliveryCharge'] ?? json['delivery_charges'] ?? json['delivery_charge'] ?? json['shippingCharges'] ?? json['shippingFee'] ?? 0).toString()) ?? 0.0,
      totalPayAmount: double.tryParse((json['totalPayAmount'] ?? json['total_pay_amount'] ?? 0).toString()) ?? 0.0,
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
    final rentalDetails = json['rentalDetails'] != null
        ? RentalDetailsModel.fromJson(json['rentalDetails'])
        : RentalDetailsModel.fromJson(json);

    final double price = double.tryParse((json['price'] ??
            json['basePricePerDay'] ??
            json['perDayRent'] ??
            json['unitPrice'] ??
            rentalDetails.basePricePerDay ??
            rentalDetails.productSnapshot?.perDayRent ??
            0)
        .toString()) ??
        0.0;

    final int qty = int.tryParse((json['quantity'] ??
            json['qty'] ??
            json['count'] ??
            json['productQuantity'] ??
            1)
        .toString()) ??
        1;

    return OrderDetailsItemModel(
      orderItemId: (json['orderItemId'] ?? json['orderRef'] ?? json['_id'] ?? '').toString(),
      quantity: qty,
      type: (json['type'] ?? 'rental').toString(),
      bookingType: (json['bookingType'] ?? json['booking_type'] ?? 'rental').toString(),
      price: price,
      billingSummary: OrderBillingSummaryModel.fromJson(
          json['billingSummary'] ?? json['billing_summary'] ?? <String, dynamic>{}),
      productDetails: json['productDetails'] != null
          ? ProductDetailsModel.fromJson(json['productDetails'])
          : json['productSnapshot'] != null
              ? ProductDetailsModel.fromJson(json['productSnapshot'])
              : ProductDetailsModel.fromJson(json),
      vendorCommissionAmount: double.tryParse((json['vendorCommissionAmount'] ??
              json['vendorcommissionamount'] ??
              0)
          .toString()) ??
          0.0,
      rentalDetails: rentalDetails,
    );
  }
}
