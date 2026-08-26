import '../../domain/entities/rental_booking_entity.dart';

class RentalBookingResponseModel extends RentalBookingResponseEntity {
  const RentalBookingResponseModel({
    required super.orderItems,
    required super.pagination,
  });

  factory RentalBookingResponseModel.fromJson(Map<String, dynamic> json) {
    return RentalBookingResponseModel(
      orderItems: (json['orderitems'] as List<dynamic>? ?? [])
          .map((e) => RentalBookingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] != null
          ? RentalBookingPaginationModel.fromJson(json['pagination'])
          : const RentalBookingPaginationModel(
              total: 0,
              page: 1,
              limit: 10,
              totalPages: 1,
              hasNextPage: false,
              hasPrevPage: false,
            ),
    );
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

  factory RentalBookingPaginationModel.fromJson(Map<String, dynamic> json) {
    return RentalBookingPaginationModel(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
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

  factory RentalBookingModel.fromJson(Map<String, dynamic> json) {
    return RentalBookingModel(
      id: json['_id']?.toString() ?? '',
      orderItemId: json['orderItemId']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      type: json['type']?.toString() ?? '',
      bookingType: json['bookingType']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      price: (json['price'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      vendorCommissionAmount: (json['vendorCommissionAmount'] ?? 0).toDouble(),
      rentalDetails: json['rentalDetails'] != null
          ? RentalDetailsModel.fromJson(json['rentalDetails'])
          : null,
      orderDetails: json['orderDetails'] != null
          ? RentalOrderDetailsModel.fromJson(json['orderDetails'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
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

  factory RentalDetailsModel.fromJson(Map<String, dynamic> json) {
    return RentalDetailsModel(
      rentalPlan: json['rentalPlan']?.toString() ?? '',
      rentalDuration: int.tryParse(json['rentalDuration']?.toString() ?? '0') ?? 0,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'])
          : null,
      endDate:
          json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
      paymentType: (json['paymentType'] ?? json['paymenttype'])?.toString() ?? '',
      paymentMethod: (json['paymentMethod'] ?? json['paymentmethod'])?.toString() ?? '',
      numberOfInstallments: int.tryParse(json['numberOfInstallments']?.toString() ?? '0') ?? 0,
      basePricePerDay:
          double.tryParse((json['basePricePerDay'] ?? json['price'])?.toString() ?? '0') ?? 0.0,
      totalDays: int.tryParse(json['totalDays']?.toString() ?? '0') ?? 0,
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      installmentAmount: double.tryParse((json['installmentAmount'] ?? json['installmentamount'])?.toString() ?? '0') ?? 0.0,
      serviceCharges:
          double.tryParse((json['serviceCharges'] ?? json['servicecharges'] ?? json['serviceCharge'] ?? json['servicecharge'])?.toString() ?? '0') ?? 0.0,
      returnCharges:
          double.tryParse((json['returnCharges'] ?? json['returncharges'] ?? json['returnCharge'] ?? json['returncharge'])?.toString() ?? '0') ?? 0.0,
      deposit: double.tryParse((json['fixedDeposit'] ?? json['deposit'])?.toString() ?? '0') ?? 0.0,
      productSnapshot: json['productSnapshot'] != null
          ? RentalProductSnapshotModel.fromJson(json['productSnapshot'])
          : RentalProductSnapshotModel.fromJson(json),
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

  factory RentalProductSnapshotModel.fromJson(Map<String, dynamic> json) {
    return RentalProductSnapshotModel(
      name: json['name']?.toString() ?? '',
      perDayRent: (json['perDayRent'] ?? json['price'] ?? 0).toDouble(),
      tabletName: json['tabletName']?.toString(),
      imageUrl: () {
        final img = json['imageUrl'] ?? json['imageurl'];
        if (img is String) return [img];
        if (img is List) return img.map((e) => e.toString()).toList();
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

  factory RentalOrderDetailsModel.fromJson(Map<String, dynamic> json) {
    return RentalOrderDetailsModel(
      id: json['_id']?.toString() ?? '',
      paymentmethod: json['paymentmethod']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      userDetails: json['userDetails'] != null
          ? RentalUserDetailsModel.fromJson(json['userDetails'])
          : null,
    );
  }
}

class RentalUserDetailsModel extends RentalUserDetailsEntity {
  const RentalUserDetailsModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    super.email,
    super.phone,
  });

  factory RentalUserDetailsModel.fromJson(Map<String, dynamic> json) {
    return RentalUserDetailsModel(
      id: json['_id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}
