import '../../domain/entities/appointment_details_entity.dart';

class AppointmentDetailsModel extends AppointmentDetailsEntity {
  const AppointmentDetailsModel({
    super.id,
    required super.orderId,
    required super.orderRef,
    super.patientId,
    super.personType,
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
    super.couponDetails,
  });

  factory AppointmentDetailsModel.fromJson(Map<String, dynamic> json) {
    final isGroup = json['isGroup'] == true ||
        json['isGroup'] == 'true' ||
        (json['groupDetails'] != null &&
            json['groupDetails'] is List &&
            (json['groupDetails'] as List).isNotEmpty);

    return AppointmentDetailsModel(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          json['orderId']?.toString() ??
          '',
      orderId: json['orderId']?.toString() ??
          json['orderRef']?.toString() ??
          json['_id']?.toString() ??
          '',
      orderRef: json['orderRef']?.toString() ?? '',
      patientId: json['patientId']?.toString() ??
          json['userId']?.toString() ??
          json['customerId']?.toString() ??
          '',
      personType: json['persontype']?.toString() ??
          json['personType']?.toString() ??
          json['person_type']?.toString() ??
          json['selectType']?.toString() ??
          json['selecttype']?.toString() ??
          '',
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
      referredDoctor: (() {
        if (json['doctorName'] != null &&
            json['doctorName'].toString().trim().isNotEmpty) {
          return json['doctorName'].toString().trim();
        }
        if (json['doctorname'] != null &&
            json['doctorname'].toString().trim().isNotEmpty) {
          return json['doctorname'].toString().trim();
        }
        if (json['doctor_name'] != null &&
            json['doctor_name'].toString().trim().isNotEmpty) {
          return json['doctor_name'].toString().trim();
        }
        if (json['referredDoctor'] != null &&
            json['referredDoctor'].toString().trim().isNotEmpty) {
          return json['referredDoctor'].toString().trim();
        }
        if (json['referreddoctor'] != null &&
            json['referreddoctor'].toString().trim().isNotEmpty) {
          return json['referreddoctor'].toString().trim();
        }
        if (json['referred_doctor'] != null &&
            json['referred_doctor'].toString().trim().isNotEmpty) {
          return json['referred_doctor'].toString().trim();
        }
        if (json['doctor'] != null) {
          if (json['doctor'] is Map) {
            final docMap = json['doctor'] as Map;
            return docMap['name']?.toString() ??
                docMap['doctorName']?.toString() ??
                docMap['fullName']?.toString() ??
                'Self Referral';
          }
          if (json['doctor'].toString().trim().isNotEmpty) {
            return json['doctor'].toString().trim();
          }
        }
        return 'Self Referral';
      })(),
      billingSummary: AppointmentDetailsBillingSummaryModel.fromJson(
          json['billingSummary'] ?? json['billingsummary'] ?? {}),
      groupDetails: json['groupDetails'] != null && json['groupDetails'] is List
          ? (json['groupDetails'] as List)
              .map((e) => AppointmentGroupDetailsModel.fromJson(
                  e as Map<String, dynamic>))
              .toList()
          : [],
      couponDetails:
          json['couponDetails'] != null && json['couponDetails'] is Map
              ? AppointmentCouponDetailsModel.fromJson(
                  json['couponDetails'] as Map<String, dynamic>)
              : null,
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

class AppointmentCouponDetailsModel extends AppointmentCouponDetailsEntity {
  const AppointmentCouponDetailsModel({
    super.createdType,
  });

  factory AppointmentCouponDetailsModel.fromJson(Map<String, dynamic> json) {
    return AppointmentCouponDetailsModel(
      createdType:
          json['createdType']?.toString() ?? json['createdtype']?.toString(),
    );
  }
}

class AppointmentGroupDetailsModel extends AppointmentGroupDetailsEntity {
  const AppointmentGroupDetailsModel({
    super.patientId,
    super.selectType,
    super.patientDetails,
    required super.items,
  });

  factory AppointmentGroupDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawPatient = json['patientDetails'] ??
        json['patientdetails'] ??
        json['patient_details'] ??
        json['patient'];

    final patientId = json['patientId']?.toString() ??
        json['_id']?.toString() ??
        json['id']?.toString() ??
        (rawPatient is Map
            ? (rawPatient['_id']?.toString() ??
                rawPatient['patientId']?.toString() ??
                rawPatient['id']?.toString() ??
                '')
            : '');

    final selectType = json['selectType']?.toString() ??
        json['selecttype']?.toString() ??
        json['select_type']?.toString() ??
        json['persontype']?.toString() ??
        json['personType']?.toString() ??
        json['person_type']?.toString() ??
        json['type']?.toString() ??
        'family';

    return AppointmentGroupDetailsModel(
      patientId: patientId,
      selectType: selectType,
      patientDetails: rawPatient != null && rawPatient is Map
          ? AppointmentPatientDetailsModel.fromJson(
              rawPatient as Map<String, dynamic>)
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
    super.patientId,
    required super.name,
    required super.age,
    required super.gender,
    required super.phone,
    required super.email,
  });

  factory AppointmentPatientDetailsModel.fromJson(Map<String, dynamic> json) {
    final patientId = json['patientId']?.toString() ??
        json['_id']?.toString() ??
        json['id']?.toString() ??
        json['userId']?.toString() ??
        '';

    return AppointmentPatientDetailsModel(
      patientId: patientId,
      name: json['name']?.toString() ??
          json['fullName']?.toString() ??
          json['patientName']?.toString() ??
          json['firstName']?.toString() ??
          '',
      age: json['age']?.toString() ??
          json['patientAge']?.toString() ??
          json['Age']?.toString() ??
          '',
      gender: json['gender']?.toString() ??
          json['patientGender']?.toString() ??
          json['Gender']?.toString() ??
          json['sex']?.toString() ??
          '',
      phone: json['phone']?.toString() ??
          json['mobile']?.toString() ??
          json['phoneNumber']?.toString() ??
          json['contactNumber']?.toString() ??
          '',
      email:
          json['email']?.toString() ?? json['patientEmail']?.toString() ?? '',
    );
  }
}

class AppointmentReportModel extends AppointmentReportEntity {
  const AppointmentReportModel({
    super.id,
    super.reportType,
    super.description,
    super.file,
    super.createdAt,
  });

  factory AppointmentReportModel.fromJson(Map<String, dynamic> json) {
    return AppointmentReportModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      reportType: json['reportType']?.toString() ??
          json['reporttype']?.toString() ??
          json['type']?.toString() ??
          '',
      description: json['description']?.toString() ?? '',
      file: json['reportFile']?.toString() ??
          json['reportfile']?.toString() ??
          json['report_file']?.toString() ??
          json['file']?.toString() ??
          json['report']?.toString() ??
          json['url']?.toString() ??
          json['path']?.toString() ??
          '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal()
          : null,
    );
  }
}

class AppointmentServiceItemModel extends AppointmentServiceItemEntity {
  const AppointmentServiceItemModel({
    super.id,
    required super.orderItemId,
    super.patientId,
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
    required super.couponAmount,
    super.reports,
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

    final List<AppointmentReportModel> reports = [];
    if (json['reports'] != null && json['reports'] is List) {
      reports.addAll(
        (json['reports'] as List)
            .map((e) => AppointmentReportModel.fromJson(e as Map<String, dynamic>)),
      );
    } else if (json['report'] != null && json['report'] is Map) {
      reports.add(
        AppointmentReportModel.fromJson(json['report'] as Map<String, dynamic>),
      );
    }

    final id = json['_id']?.toString() ??
        json['id']?.toString() ??
        json['orderItemId']?.toString() ??
        '';

    return AppointmentServiceItemModel(
      id: id,
      orderItemId: id.isNotEmpty
          ? id
          : (json['orderItemId']?.toString() ?? ''),
      patientId: json['patientId']?.toString() ??
          json['userId']?.toString() ??
          '',
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
      totalPrice: double.tryParse(json['totalPrice']?.toString() ??
              json['totalprice']?.toString() ??
              json['price']?.toString() ??
              '0') ??
          0.0,
      adminCommission: (() {
        final billing = json['billingSummary'] ??
            json['billingsummary'] ??
            json['billing_summary'];
        if (billing != null && billing is Map) {
          final amt = billing['vendorCommissionAmount'] ??
              billing['vendorcommissionamount'] ??
              billing['vendor_commission_amount'] ??
              billing['vendorCommission'] ??
              billing['vendorcommission'] ??
              billing['adminCommissionAmount'] ??
              billing['admincommissionamount'] ??
              billing['adminCommission'] ??
              billing['admincommission'] ??
              billing['commission'];
          if (amt != null && double.tryParse(amt.toString()) != null) {
            return double.tryParse(amt.toString())!;
          }
        }
        final rawAmt = json['vendorCommissionAmount'] ??
            json['vendorcommissionamount'] ??
            json['vendorCommission'] ??
            json['vendorcommission'] ??
            json['adminCommissionAmount'] ??
            json['adminCommission'] ??
            json['admincommission'];
        if (rawAmt != null && double.tryParse(rawAmt.toString()) != null) {
          return double.tryParse(rawAmt.toString())!;
        }
        return 0.0;
      })(),
      status: json['status']?.toString() ?? 'Pending',
      productName: productName,
      productImages: productImages,
      couponAmount:
          double.tryParse(json['couponAmount']?.toString() ?? '0') ?? 0.0,
      reports: reports,
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
