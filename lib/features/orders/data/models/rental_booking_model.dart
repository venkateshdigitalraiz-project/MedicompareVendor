// ignore_for_file: unnecessary_cast, unnecessary_null_comparison

import '../../domain/entities/rental_booking_entity.dart';

class RentalBookingResponseModel extends RentalBookingResponseEntity {
  const RentalBookingResponseModel({
    required super.orderItems,
    required super.pagination,
  });

  factory RentalBookingResponseModel.fromJson(dynamic json) {
    if (json == null) {
      return const RentalBookingResponseModel(
        orderItems: [],
        pagination: RentalBookingPaginationModel(
          total: 0,
          page: 1,
          limit: 10,
          totalPages: 1,
          hasNextPage: false,
          hasPrevPage: false,
        ),
      );
    }

    if (json is List) {
      final List<RentalBookingEntity> items = [];
      for (var entry in json) {
        if (entry is Map<String, dynamic>) {
          items.addAll(_parseOrderOrItems(entry));
        } else if (entry is Map) {
          items.addAll(_parseOrderOrItems(Map<String, dynamic>.from(entry)));
        }
      }
      return RentalBookingResponseModel(
        orderItems: items,
        pagination: RentalBookingPaginationModel(
          total: items.length,
          page: 1,
          limit: items.length > 0 ? items.length : 10,
          totalPages: 1,
          hasNextPage: false,
          hasPrevPage: false,
        ),
      );
    }

    if (json is Map) {
      final map = Map<String, dynamic>.from(json);

      final rawList = map['orderitems'] ??
          map['orderItems'] ??
          map['orders'] ??
          map['rentalOrders'] ??
          map['items'] ??
          map['data'] ??
          map['list'] ??
          map['docs'];

      final List<RentalBookingEntity> items = [];
      if (rawList is List) {
        for (var entry in rawList) {
          if (entry is Map<String, dynamic>) {
            items.addAll(_parseOrderOrItems(entry));
          } else if (entry is Map) {
            items.addAll(_parseOrderOrItems(Map<String, dynamic>.from(entry)));
          }
        }
      }

      final paginationData = map['pagination'] ??
          (map['meta'] is Map ? map['meta'] : null) ??
          {
            'total': map['total'] ?? items.length,
            'page': map['page'] ?? 1,
            'limit': map['limit'] ?? 10,
            'totalPages': map['totalPages'] ?? map['total_pages'] ?? 1,
          };

      return RentalBookingResponseModel(
        orderItems: items,
        pagination: RentalBookingPaginationModel.fromJson(paginationData),
      );
    }

    return const RentalBookingResponseModel(
      orderItems: [],
      pagination: RentalBookingPaginationModel(
        total: 0,
        page: 1,
        limit: 10,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      ),
    );
  }

  static List<RentalBookingEntity> _parseOrderOrItems(
      Map<String, dynamic> raw) {
    final List<RentalBookingEntity> result = [];

    final parentDbId = (raw['_id'] ?? raw['id'])?.toString() ?? '';
    final parentReadableOrderRef =
        RentalBookingModel.extractReadableOrderId(raw);
    final parentStatus =
        raw['orderStatus']?.toString() ?? raw['status']?.toString() ?? '';
    final parentPaymentStatus = raw['paymentStatus']?.toString() ?? '';
    final parentBookingType = raw['bookingType']?.toString() ?? 'rental';
    final parentCreatedAt = raw['createdAt'] != null
        ? DateTime.tryParse(raw['createdAt'].toString()) ?? DateTime.now()
        : DateTime.now();

    final parentOrderDetailsMap = <String, dynamic>{
      '_id': parentDbId,
      'paymentmethod': raw['paymentMethod'] ?? raw['paymentmethod'] ?? '',
      'orderStatus': parentStatus,
      'userDetails': raw['userDetails'] ??
          raw['user'] ??
          raw['customer'] ??
          raw['customerDetails'],
    };

    final rawItems = raw['items'];
    if (rawItems is List && rawItems.isNotEmpty) {
      for (var itemEntry in rawItems) {
        if (itemEntry is Map) {
          final itemMap = Map<String, dynamic>.from(itemEntry);

          // Extract totalAmount from billingSummary{totalAmount} or rentalDetails{totalAmount}
          final dynamic itemBilling = itemMap['billingSummary'];
          final dynamic parentBilling = raw['billingSummary'];
          final dynamic itemRentalDetails = itemMap['rentalDetails'];
          final dynamic parentRentalDetails = raw['rentalDetails'];

          double extractedTotal = 0.0;
          if (itemBilling is Map && itemBilling['totalAmount'] != null) {
            extractedTotal =
                double.tryParse(itemBilling['totalAmount'].toString()) ?? 0.0;
          } else if (parentBilling is Map &&
              parentBilling['totalAmount'] != null) {
            extractedTotal =
                double.tryParse(parentBilling['totalAmount'].toString()) ?? 0.0;
          } else if (itemRentalDetails is Map &&
              itemRentalDetails['totalAmount'] != null) {
            extractedTotal =
                double.tryParse(itemRentalDetails['totalAmount'].toString()) ??
                    0.0;
          } else if (parentRentalDetails is Map &&
              parentRentalDetails['totalAmount'] != null) {
            extractedTotal = double.tryParse(
                    parentRentalDetails['totalAmount'].toString()) ??
                0.0;
          } else if (itemBilling is Map && itemBilling['total'] != null) {
            extractedTotal =
                double.tryParse(itemBilling['total'].toString()) ?? 0.0;
          } else if (parentBilling is Map && parentBilling['total'] != null) {
            extractedTotal =
                double.tryParse(parentBilling['total'].toString()) ?? 0.0;
          } else {
            extractedTotal = double.tryParse((itemMap['totalPrice'] ??
                        itemMap['total'] ??
                        raw['total'] ??
                        itemMap['price'] ??
                        '0')
                    .toString()) ??
                0.0;
          }

          final merged = <String, dynamic>{
            '_id': parentDbId,
            'id': parentDbId,
            'orderId': parentReadableOrderRef,
            'orderRef': parentReadableOrderRef,
            'orderItemId': parentReadableOrderRef,
            'productId': itemMap['productId'] ??
                itemMap['productSnapshot']?['productId'] ??
                '',
            'quantity': itemMap['quantity'] ?? 1,
            'type': itemMap['type'] ?? 'rental',
            'bookingType': itemMap['bookingType'] ?? parentBookingType,
            'orderStatus': itemMap['orderStatus'] ?? parentStatus,
            'paymentStatus': itemMap['paymentStatus'] ?? parentPaymentStatus,
            'price': itemMap['price'] ??
                itemMap['productSnapshot']?['price'] ??
                raw['baseAmount'] ??
                raw['subtotal'] ??
                0,
            'totalPrice': extractedTotal,
            'billingSummary': itemBilling ?? parentBilling,
            'vendorCommissionAmount': itemMap['vendorCommissionAmount'] ??
                raw['vendorCommissionAmount'] ??
                0,
            'rentalDetails':
                itemMap['rentalDetails'] ?? raw['rentalDetails'] ?? itemMap,
            'orderDetails': itemMap['orderDetails'] ?? parentOrderDetailsMap,
            'createdAt': raw['createdAt'] ??
                itemMap['createdAt'] ??
                parentCreatedAt.toIso8601String(),
          };
          result.add(RentalBookingModel.fromJson(merged));
        }
      }
    }

    if (result.isEmpty) {
      result.add(RentalBookingModel.fromJson(raw));
    }

    return result;
  }
}

class RentalBookingPaginationModel extends RentalBookingPaginationEntity {
  const RentalBookingPaginationModel({
    required super.total,
    required super.page,
    required super.limit,
    required super.totalPages,
    required super.hasNextPage,
    required super.hasPrevPage,
  });

  factory RentalBookingPaginationModel.fromJson(dynamic json) {
    if (json is! Map) {
      return const RentalBookingPaginationModel(
        total: 0,
        page: 1,
        limit: 10,
        totalPages: 1,
        hasNextPage: false,
        hasPrevPage: false,
      );
    }
    final total = int.tryParse(json['total']?.toString() ?? '0') ?? 0;
    final page = int.tryParse(json['page']?.toString() ?? '1') ?? 1;
    final limit = int.tryParse(json['limit']?.toString() ?? '10') ?? 10;
    final totalPages = int.tryParse(
            (json['totalPages'] ?? json['total_pages'] ?? '1').toString()) ??
        1;

    return RentalBookingPaginationModel(
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
      hasNextPage: json['hasNextPage'] == true || page < totalPages,
      hasPrevPage: json['hasPrevPage'] == true || page > 1,
    );
  }
}

class RentalBookingModel extends RentalBookingEntity {
  const RentalBookingModel({
    required super.id,
    required super.orderItemId,
    required super.orderId,
    required super.productId,
    required super.quantity,
    required super.type,
    required super.bookingType,
    required super.orderStatus,
    required super.paymentStatus,
    required super.price,
    required super.totalPrice,
    required super.vendorCommissionAmount,
    super.rentalDetails,
    super.orderDetails,
    required super.createdAt,
  });

  static String extractReadableOrderId(Map<String, dynamic> json) {
    String orderDetailsRef = '';
    String orderDetailsId = '';
    final dynamic rawOrderDetails = json['orderDetails'];
    if (rawOrderDetails is Map) {
      orderDetailsRef =
          (rawOrderDetails['orderRef'] ?? rawOrderDetails['order_ref'] ?? '')
              .toString();
      orderDetailsId =
          (rawOrderDetails['orderId'] ?? rawOrderDetails['order_id'] ?? '')
              .toString();
    } else if (rawOrderDetails is RentalOrderDetailsEntity) {
      orderDetailsId = rawOrderDetails.id;
    }

    final candidates = [
      json['orderRef'],
      json['order_ref'],
      json['orderId'],
      json['order_id'],
      json['orderNumber'],
      json['order_number'],
      json['orderItemId'],
      json['order_item_id'],
      json['customOrderId'],
      json['custom_order_id'],
      json['bookingId'],
      json['booking_id'],
      orderDetailsRef,
      orderDetailsId,
    ];

    for (var c in candidates) {
      if (c != null && c.toString().trim().isNotEmpty) {
        final str = c.toString().trim();
        if (str.toUpperCase().startsWith('ORD') || str.startsWith('#')) {
          return str;
        }
      }
    }

    for (var c in candidates) {
      if (c != null && c.toString().trim().isNotEmpty) {
        final str = c.toString().trim();
        if (str.length != 24) {
          return str;
        }
      }
    }

    if (json['orderRef'] != null &&
        json['orderRef'].toString().trim().isNotEmpty) {
      return json['orderRef'].toString().trim();
    }
    if (json['orderId'] != null &&
        json['orderId'].toString().trim().isNotEmpty) {
      return json['orderId'].toString().trim();
    }

    return (json['_id'] ?? json['id'] ?? '').toString();
  }

  factory RentalBookingModel.fromJson(Map<String, dynamic> json) {
    final dbId = (json['_id'] ?? json['id'])?.toString() ?? '';
    final readableOrderRef = extractReadableOrderId(json);

    String resolvedStatus =
        (json['orderStatus'] ?? json['status'] ?? '').toString();
    String resolvedPaymentStatus =
        (json['paymentStatus'] ?? json['payment_status'] ?? '').toString();

    RentalOrderDetailsEntity? resolvedOrderDetails;
    final dynamic rawOrderDetails = json['orderDetails'];
    if (rawOrderDetails is RentalOrderDetailsEntity) {
      resolvedOrderDetails = rawOrderDetails;
    } else if (rawOrderDetails is Map) {
      resolvedOrderDetails = RentalOrderDetailsModel.fromJson(
          // ignore: duplicate_ignore
          // ignore: unnecessary_cast
          Map<String, dynamic>.from(rawOrderDetails as Map));
    } else {
      resolvedOrderDetails = RentalOrderDetailsModel.fromJson(json);
    }

    if (resolvedStatus.isEmpty && resolvedOrderDetails != null) {
      resolvedStatus = resolvedOrderDetails.orderStatus;
    }

    RentalDetailsEntity? resolvedRentalDetails;
    final dynamic rawRentalDetails = json['rentalDetails'];
    if (rawRentalDetails is RentalDetailsEntity) {
      resolvedRentalDetails = rawRentalDetails;
    } else if (rawRentalDetails is Map) {
      resolvedRentalDetails = RentalDetailsModel.fromJson(
          Map<String, dynamic>.from(rawRentalDetails as Map));
    } else if (json['productSnapshot'] != null ||
        json['rentalPlan'] != null ||
        json['productDetails'] != null) {
      resolvedRentalDetails = RentalDetailsModel.fromJson(json);
    }

    // Extract price from billingSummary{totalAmount} or rentalDetails{totalAmount}
    final dynamic billing = json['billingSummary'];
    final dynamic rentalDet = json['rentalDetails'];

    double extractedTotal = 0.0;
    if (billing is Map && billing['totalAmount'] != null) {
      extractedTotal =
          double.tryParse(billing['totalAmount'].toString()) ?? 0.0;
    } else if (rentalDet is Map && rentalDet['totalAmount'] != null) {
      extractedTotal =
          double.tryParse(rentalDet['totalAmount'].toString()) ?? 0.0;
    } else if (json['totalAmount'] != null) {
      extractedTotal = double.tryParse(json['totalAmount'].toString()) ?? 0.0;
    } else if (resolvedRentalDetails != null &&
        resolvedRentalDetails.totalAmount > 0) {
      extractedTotal = resolvedRentalDetails.totalAmount;
    } else if (billing is Map && billing['total'] != null) {
      extractedTotal = double.tryParse(billing['total'].toString()) ?? 0.0;
    } else {
      extractedTotal = double.tryParse(
              (json['totalPrice'] ?? json['total'] ?? json['price'] ?? '0')
                  .toString()) ??
          0.0;
    }

    return RentalBookingModel(
      id: dbId.isNotEmpty ? dbId : readableOrderRef,
      orderItemId: readableOrderRef,
      orderId: readableOrderRef,
      productId:
          (json['productId'] ?? json['productSnapshot']?['productId'] ?? '')
              .toString(),
      quantity: int.tryParse((json['quantity'] ?? '1').toString()) ?? 1,
      type: (json['type'] ?? 'rental').toString(),
      bookingType:
          (json['bookingType'] ?? json['booking_type'] ?? 'rental').toString(),
      orderStatus: resolvedStatus,
      paymentStatus: resolvedPaymentStatus,
      price: double.tryParse(
              (json['price'] ?? json['baseAmount'] ?? json['subtotal'] ?? '0')
                  .toString()) ??
          0.0,
      totalPrice: extractedTotal,
      vendorCommissionAmount: double.tryParse((json['vendorCommissionAmount'] ??
                  json['vendor_commission_amount'] ??
                  '0')
              .toString()) ??
          0.0,
      rentalDetails: resolvedRentalDetails,
      orderDetails: resolvedOrderDetails,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is DateTime
              ? json['createdAt'] as DateTime
              : DateTime.tryParse(json['createdAt'].toString()) ??
                  DateTime.now())
          : DateTime.now(),
    );
  }
}

class RentalDetailsModel extends RentalDetailsEntity {
  const RentalDetailsModel({
    required super.rentalPlan,
    required super.rentalDuration,
    super.startDate,
    super.endDate,
    required super.paymentType,
    required super.paymentMethod,
    required super.numberOfInstallments,
    required super.basePricePerDay,
    required super.totalDays,
    required super.totalAmount,
    super.installmentAmount,
    super.serviceCharges,
    super.returnCharges,
    super.deposit,
    super.productSnapshot,
  });

  factory RentalDetailsModel.fromJson(dynamic json) {
    if (json is! Map) {
      return const RentalDetailsModel(
        rentalPlan: '',
        rentalDuration: 0,
        paymentType: '',
        paymentMethod: '',
        numberOfInstallments: 0,
        basePricePerDay: 0.0,
        totalDays: 0,
        totalAmount: 0.0,
      );
    }

    final rMap = json['rentalDetails'] is Map
        ? Map<String, dynamic>.from(json['rentalDetails'] as Map)
        : Map<String, dynamic>.from(json);

    final dynamic billing = rMap['billingSummary'] ?? json['billingSummary'];

    double totalAmt = 0.0;
    if (billing is Map && billing['totalAmount'] != null) {
      totalAmt = double.tryParse(billing['totalAmount'].toString()) ?? 0.0;
    } else if (rMap['totalAmount'] != null) {
      totalAmt = double.tryParse(rMap['totalAmount'].toString()) ?? 0.0;
    } else if (rMap['totalamount'] != null) {
      totalAmt = double.tryParse(rMap['totalamount'].toString()) ?? 0.0;
    } else if (billing is Map && billing['total'] != null) {
      totalAmt = double.tryParse(billing['total'].toString()) ?? 0.0;
    } else if (rMap['total'] != null) {
      totalAmt = double.tryParse(rMap['total'].toString()) ?? 0.0;
    }

    return RentalDetailsModel(
      rentalPlan: (rMap['rentalPlan'] ?? rMap['rentalplan'] ?? '').toString(),
      rentalDuration: int.tryParse(
              (rMap['rentalDuration'] ?? rMap['rentalduration'] ?? '0')
                  .toString()) ??
          0,
      startDate: rMap['startDate'] != null
          ? DateTime.tryParse(rMap['startDate'].toString())
          : (rMap['start_date'] != null
              ? DateTime.tryParse(rMap['start_date'].toString())
              : null),
      endDate: rMap['endDate'] != null
          ? DateTime.tryParse(rMap['endDate'].toString())
          : (rMap['end_date'] != null
              ? DateTime.tryParse(rMap['end_date'].toString())
              : null),
      paymentType:
          (rMap['paymentType'] ?? rMap['paymenttype'] ?? '').toString(),
      paymentMethod:
          (rMap['paymentMethod'] ?? rMap['paymentmethod'] ?? '').toString(),
      numberOfInstallments: int.tryParse((rMap['numberOfInstallments'] ??
                  rMap['numberofinstallments'] ??
                  '0')
              .toString()) ??
          0,
      basePricePerDay: double.tryParse((rMap['basePricePerDay'] ??
                  rMap['price'] ??
                  rMap['perDayRent'] ??
                  '0')
              .toString()) ??
          0.0,
      totalDays: int.tryParse(
              (rMap['totalDays'] ?? rMap['totaldays'] ?? '0').toString()) ??
          0,
      totalAmount: totalAmt,
      installmentAmount: double.tryParse((rMap['installmentAmount'] ??
                  rMap['installmentamount'] ??
                  rMap['installment_amount'] ??
                  rMap['firstInstallmentAmount'] ??
                  rMap['firstinstallmentamount'] ??
                  rMap['first_installment_amount'] ??
                  rMap['installamount'] ??
                  rMap['installment'] ??
                  json['installmentAmount'] ??
                  json['installmentamount'] ??
                  json['installment_amount'] ??
                  json['firstInstallmentAmount'] ??
                  json['firstinstallmentamount'] ??
                  json['first_installment_amount'] ??
                  json['installamount'] ??
                  '0')
              .toString()) ??
          0.0,
      serviceCharges: double.tryParse((rMap['serviceCharges'] ??
                  rMap['servicecharges'] ??
                  rMap['serviceCharge'] ??
                  rMap['servicecharge'] ??
                  '0')
              .toString()) ??
          0.0,
      returnCharges: double.tryParse((rMap['returnCharges'] ??
                  rMap['returncharges'] ??
                  rMap['returnCharge'] ??
                  rMap['returncharge'] ??
                  '0')
              .toString()) ??
          0.0,
      deposit: double.tryParse(
              (rMap['fixedDeposit'] ?? rMap['deposit'] ?? '0').toString()) ??
          0.0,
      productSnapshot: rMap['productSnapshot'] != null &&
              rMap['productSnapshot'] is Map
          ? RentalProductSnapshotModel.fromJson(
              Map<String, dynamic>.from(rMap['productSnapshot'] as Map))
          : (json['productSnapshot'] != null && json['productSnapshot'] is Map
              ? RentalProductSnapshotModel.fromJson(
                  Map<String, dynamic>.from(json['productSnapshot'] as Map))
              : (json['productDetails'] != null && json['productDetails'] is Map
                  ? RentalProductSnapshotModel.fromJson(
                      Map<String, dynamic>.from(json['productDetails'] as Map))
                  : RentalProductSnapshotModel.fromJson(json))),
    );
  }
}

class RentalProductSnapshotModel extends RentalProductSnapshotEntity {
  const RentalProductSnapshotModel({
    required super.name,
    required super.perDayRent,
    super.tabletName,
    required super.imageUrl,
  });

  factory RentalProductSnapshotModel.fromJson(dynamic json) {
    if (json is! Map) {
      return const RentalProductSnapshotModel(
        name: '',
        perDayRent: 0.0,
        imageUrl: [],
      );
    }
    final map = Map<String, dynamic>.from(json);

    return RentalProductSnapshotModel(
      name:
          (map['name'] ?? map['productName'] ?? map['title'] ?? '').toString(),
      perDayRent: double.tryParse((map['perDayRent'] ??
                  map['price'] ??
                  map['basePricePerDay'] ??
                  '0')
              .toString()) ??
          0.0,
      tabletName:
          (map['tabletName'] ?? map['name'] ?? map['productName'])?.toString(),
      imageUrl: () {
        final img = map['imageUrl'] ??
            map['imageurl'] ??
            map['images'] ??
            map['image'] ??
            map['files'];
        if (img is String) return [img];
        if (img is List) {
          return img
              .map((e) {
                if (e is Map)
                  return (e['url'] ?? e['file'] ?? e['path'] ?? '').toString();
                return e.toString();
              })
              .where((s) => s.isNotEmpty)
              .toList();
        }
        return <String>[];
      }(),
    );
  }
}

class RentalOrderDetailsModel extends RentalOrderDetailsEntity {
  const RentalOrderDetailsModel({
    required super.id,
    required super.paymentmethod,
    required super.orderStatus,
    super.userDetails,
  });

  factory RentalOrderDetailsModel.fromJson(dynamic json) {
    if (json is! Map) {
      return const RentalOrderDetailsModel(
        id: '',
        paymentmethod: '',
        orderStatus: '',
      );
    }
    final map = Map<String, dynamic>.from(json);

    return RentalOrderDetailsModel(
      id: (map['_id'] ?? map['id'] ?? map['orderId'])?.toString() ?? '',
      paymentmethod:
          (map['paymentmethod'] ?? map['paymentMethod'] ?? '').toString(),
      orderStatus: (map['orderStatus'] ?? map['status'] ?? '').toString(),
      userDetails: () {
        final u = map['userDetails'] ??
            map['user'] ??
            map['customer'] ??
            map['customerDetails'];
        if (u != null && u is Map) {
          return RentalUserDetailsModel.fromJson(Map<String, dynamic>.from(u));
        }
        return null;
      }(),
    );
  }
}

class RentalUserDetailsModel extends RentalUserDetailsEntity {
  const RentalUserDetailsModel({
    required super.id,
    super.custId = '',
    required super.firstName,
    required super.lastName,
    super.email,
    super.phone,
  });

  factory RentalUserDetailsModel.fromJson(dynamic json) {
    if (json is! Map) {
      return const RentalUserDetailsModel(
        id: '',
        firstName: '',
        lastName: '',
      );
    }
    final map = Map<String, dynamic>.from(json);

    String firstName = (map['first_name'] ?? map['firstName'] ?? '').toString();
    String lastName = (map['last_name'] ?? map['lastName'] ?? '').toString();
    if (firstName.isEmpty &&
        lastName.isEmpty &&
        (map['name'] != null || map['fullName'] != null)) {
      final fullName = (map['name'] ?? map['fullName']).toString().trim();
      final parts = fullName.split(' ');
      if (parts.isNotEmpty) {
        firstName = parts.first;
        if (parts.length > 1) {
          lastName = parts.sublist(1).join(' ');
        }
      }
    }
    return RentalUserDetailsModel(
      id: (map['_id'] ?? map['id'])?.toString() ?? '',
      custId: (map['custId'] ?? map['customerId'] ?? map['cust_id'] ?? '')
          .toString(),
      firstName: firstName,
      lastName: lastName,
      email: (map['email'] ?? '').toString(),
      phone: (map['phone'] ?? map['mobile'] ?? '').toString(),
    );
  }
}
