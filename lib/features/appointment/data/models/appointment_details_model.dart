import '../../domain/entities/appointment_details_entity.dart';

class AppointmentDetailsModel extends AppointmentDetailsEntity {
  const AppointmentDetailsModel({
    required super.orderId,
    required super.orderRef,
    required super.orderStatus,
    required super.paymentStatus,
    required super.paymentMethod,
    required super.bookingType,
    required super.orderType,
    required super.serviceFixedTypes,
    required super.isGroup,
    super.selectedDate,
    required super.selectedTimeSlot,
    super.createdAt,
    required super.referredDoctor,
    required super.billingSummary,
    required super.groupDetails,
    required super.normalItems,
    super.shippingAddress,
    super.billingAddress,
  });

  factory AppointmentDetailsModel.fromJson(Map<String, dynamic> json) {
    final isGroup = json['isGroup'] == true || json['isGroup'] == 'true';

    return AppointmentDetailsModel(
      orderId: json['orderId']?.toString() ??
          json['orderRef']?.toString() ??
          json['_id']?.toString() ??
          '',
      orderRef: json['orderRef']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? 'pending',
      paymentStatus: json['paymentStatus']?.toString() ??
          json['paymentstatus']?.toString() ??
          'pending',
      paymentMethod: json['paymentMethod']?.toString() ??
          json['paymentmethod']?.toString() ??
          '',
      bookingType: json['bookingType']?.toString() ?? '',
      orderType:
          json['orderType']?.toString() ?? json['type']?.toString() ?? '',
      serviceFixedTypes: json['servicefixedTypes']?.toString() ??
          json['serviceFixedTypes']?.toString() ??
          '',
      isGroup: isGroup,
      selectedDate: json['selectedDate'] != null
          ? DateTime.tryParse(json['selectedDate'].toString())
          : null,
      selectedTimeSlot: json['selectedTimeSlot']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal()
          : null,
      referredDoctor: json['referredDoctor']?.toString() ??
          json['referreddoctor']?.toString() ??
          'Self Referral',
      billingSummary: AppointmentDetailsBillingSummaryModel.fromJson(
          json['billingSummary'] ?? json['billingsummary'] ?? {}),
      groupDetails: json['groupDetails'] != null && json['groupDetails'] is List
          ? (json['groupDetails'] as List)
              .map((e) => AppointmentGroupDetailsModel.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : [],
      normalItems: json['items'] != null && json['items'] is List
          ? (json['items'] as List)
              .map((e) => AppointmentServiceItemModel.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : [],
      shippingAddress: json['shippingAddressDetails'] != null
          ? AppointmentAddressModel.fromJson(
              json['shippingAddressDetails'] as Map<String, dynamic>)
          : null,
      billingAddress: json['billingAddressDetails'] != null
          ? AppointmentAddressModel.fromJson(
              json['billingAddressDetails'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AppointmentDetailsBillingSummaryModel
    extends AppointmentDetailsBillingSummaryEntity {
  const AppointmentDetailsBillingSummaryModel({
    required super.subtotal,
    required super.totalGst,
    required super.totalIgst,
    required super.deliveryCharges,
    required super.couponAmount,
    required super.finalAmount,
    required super.walletAmount,
    required super.sampleCollection,
    required super.tax,
    required super.adminCommission,
  });

  factory AppointmentDetailsBillingSummaryModel.fromJson(
      Map<String, dynamic> json) {
    return AppointmentDetailsBillingSummaryModel(
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      totalGst: double.tryParse(json['totalGst']?.toString() ??
              json['totalgst']?.toString() ??
              '0') ??
          0.0,
      totalIgst: double.tryParse(json['totalIgst']?.toString() ??
              json['totaligst']?.toString() ??
              '0') ??
          0.0,
      deliveryCharges: double.tryParse(json['deliveryCharges']?.toString() ??
              json['deliveryCharge']?.toString() ??
              '0') ??
          0.0,
      couponAmount: double.tryParse(json['couponAmount']?.toString() ??
              json['couponamount']?.toString() ??
              '0') ??
          0.0,
      finalAmount:
          double.tryParse(json['finalAmount']?.toString() ?? '0') ?? 0.0,
      walletAmount:
          double.tryParse(json['walletAmount']?.toString() ?? '0') ?? 0.0,
      sampleCollection: double.tryParse(
              json['samplecollectionCharges']?.toString() ??
                  json['sampleCollection']?.toString() ??
                  '0') ??
          0.0,
      tax: double.tryParse(json['tax']?.toString() ?? '0') ?? 0.0,
      adminCommission: double.tryParse(json['vendorCommission']?.toString() ??
              json['vendorcommission']?.toString() ??
              json['adminCommission']?.toString() ??
              json['admincommission']?.toString() ??
              '0') ??
          0.0,
    );
  }
}

class AppointmentGroupDetailsModel extends AppointmentGroupDetailsEntity {
  const AppointmentGroupDetailsModel({
    super.patientDetails,
    required super.items,
  });

  factory AppointmentGroupDetailsModel.fromJson(Map<String, dynamic> json) {
    return AppointmentGroupDetailsModel(
      patientDetails:
          json['patientDetails'] != null && json['patientDetails'] is Map
              ? AppointmentPatientDetailsModel.fromJson(
                  json['patientDetails'] as Map<String, dynamic>)
              : null,
      items: json['items'] != null && json['items'] is List
          ? (json['items'] as List)
              .map((e) => AppointmentServiceItemModel.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}

class AppointmentPatientDetailsModel extends AppointmentPatientDetailsEntity {
  const AppointmentPatientDetailsModel({
    required super.name,
    required super.age,
    required super.gender,
    required super.phone,
    required super.email,
  });

  factory AppointmentPatientDetailsModel.fromJson(Map<String, dynamic> json) {
    return AppointmentPatientDetailsModel(
      name: json['name']?.toString() ?? json['firstName']?.toString() ?? '',
      age: json['age']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['mobile']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class AppointmentServiceItemModel extends AppointmentServiceItemEntity {
  const AppointmentServiceItemModel({
    required super.orderItemId,
    required super.quantity,
    required super.type,
    required super.bookingType,
    required super.serviceTypes,
    required super.price,
    required super.discountPrice,
    required super.totalPrice,
    required super.adminCommission,
    required super.status,
    required super.productName,
    required super.productImages,
  });

  factory AppointmentServiceItemModel.fromJson(Map<String, dynamic> json) {
    // Determine product name cascading
    String productName = '';
    List<String> productImages = [];

    final productDetails = json['productDetails'];
    final productSnapshot = json['productSnapshot'];

    if (productDetails != null && productDetails is Map) {
      final tabletDetails =
          productDetails['tabletdetails'] ?? productDetails['tabletDetails'];
      if (tabletDetails != null && tabletDetails is Map) {
        if (tabletDetails['name'] != null &&
            tabletDetails['name'].toString().isNotEmpty) {
          productName = tabletDetails['name'].toString();
        }
        if (tabletDetails['files'] != null) {
          if (tabletDetails['files'] is List) {
            productImages.addAll(
                (tabletDetails['files'] as List).map((e) => e.toString()));
          } else if (tabletDetails['files'] is String) {
            productImages.add(tabletDetails['files'].toString());
          }
        }
      }
      if (productName.isEmpty && productDetails['name'] != null) {
        productName = productDetails['name'].toString();
      }
    }

    if (productSnapshot != null && productSnapshot is Map) {
      if (productName.isEmpty && productSnapshot['name'] != null) {
        productName = productSnapshot['name'].toString();
      }
      if (productImages.isEmpty && productSnapshot['imageUrl'] != null) {
        if (productSnapshot['imageUrl'] is List) {
          productImages.addAll(
              (productSnapshot['imageUrl'] as List).map((e) => e.toString()));
        } else if (productSnapshot['imageUrl'] is String) {
          productImages.add(productSnapshot['imageUrl'].toString());
        }
      }
    }

    return AppointmentServiceItemModel(
      orderItemId:
          json['orderItemId']?.toString() ?? json['_id']?.toString() ?? '',
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? '',
      bookingType: json['bookingType']?.toString() ?? '',
      serviceTypes: json['serviceTypes']?.toString() ??
          json['servicefixedTypes']?.toString() ??
          '',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      discountPrice: double.tryParse(json['discountprice']?.toString() ??
              json['discountPrice']?.toString() ??
              '0') ??
          0.0,
      totalPrice: double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
      adminCommission: double.tryParse(json['vendorCommission']?.toString() ??
              json['vendorcommission']?.toString() ??
              json['adminCommission']?.toString() ??
              json['admincommission']?.toString() ??
              '0') ??
          0.0,
      status: json['status']?.toString() ?? 'Pending',
      productName: productName,
      productImages: productImages,
    );
  }
}

class AppointmentAddressModel extends AppointmentAddressEntity {
  const AppointmentAddressModel({
    required super.houseNo,
    required super.area,
    required super.landmark,
    required super.locationAddress,
    required super.pincode,
    required super.addressType,
  });

  factory AppointmentAddressModel.fromJson(Map<String, dynamic> json) {
    String locationStr = '';
    if (json['location'] != null && json['location'] is Map) {
      locationStr = json['location']['address']?.toString() ?? '';
    }

    return AppointmentAddressModel(
      houseNo: json['houseNo']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      landmark: json['landmark']?.toString() ?? '',
      locationAddress: locationStr,
      pincode: json['pincode']?.toString() ?? '',
      addressType: json['addressType']?.toString() ?? '',
    );
  }
}
