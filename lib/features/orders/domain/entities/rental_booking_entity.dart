import 'package:equatable/equatable.dart';

class RentalBookingResponseEntity extends Equatable {
  final List<RentalBookingEntity> orderItems;
  final RentalBookingPaginationEntity pagination;

  const RentalBookingResponseEntity({
    required this.orderItems,
    required this.pagination,
  });

  @override
  List<Object?> get props => [orderItems, pagination];
}

class RentalBookingPaginationEntity extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const RentalBookingPaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  @override
  List<Object?> get props =>
      [total, page, limit, totalPages, hasNextPage, hasPrevPage];
}

class RentalBookingEntity extends Equatable {
  final String id;
  final String orderItemId;
  final String orderId;
  final String productId;
  final int quantity;
  final String type;
  final String bookingType;
  final String orderStatus;
  final String paymentStatus;
  final double price;
  final double totalPrice;
  final double vendorCommissionAmount;
  final RentalDetailsEntity? rentalDetails;
  final RentalOrderDetailsEntity? orderDetails;
  final DateTime createdAt;

  const RentalBookingEntity({
    required this.id,
    required this.orderItemId,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.type,
    required this.bookingType,
    required this.orderStatus,
    required this.paymentStatus,
    required this.price,
    required this.totalPrice,
    required this.vendorCommissionAmount,
    this.rentalDetails,
    this.orderDetails,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderItemId,
        orderId,
        productId,
        quantity,
        type,
        bookingType,
        orderStatus,
        paymentStatus,
        price,
        totalPrice,
        vendorCommissionAmount,
        rentalDetails,
        orderDetails,
        createdAt,
      ];
}

class RentalDetailsEntity extends Equatable {
  final String rentalPlan;
  final int rentalDuration;
  final DateTime? startDate;
  final DateTime? endDate;
  final String paymentType;
  final String paymentMethod;
  final int numberOfInstallments;
  final double basePricePerDay;
  final int totalDays;
  final double totalAmount;
  final double installmentAmount;
  final double serviceCharges;
  final double returnCharges;
  final double deposit;
  final RentalProductSnapshotEntity? productSnapshot;

  const RentalDetailsEntity({
    required this.rentalPlan,
    required this.rentalDuration,
    this.startDate,
    this.endDate,
    required this.paymentType,
    required this.paymentMethod,
    required this.numberOfInstallments,
    required this.basePricePerDay,
    required this.totalDays,
    required this.totalAmount,
    this.installmentAmount = 0.0,
    this.serviceCharges = 0.0,
    this.returnCharges = 0.0,
    this.deposit = 0.0,
    this.productSnapshot,
  });

  @override
  List<Object?> get props => [
        rentalPlan,
        rentalDuration,
        startDate,
        endDate,
        paymentType,
        paymentMethod,
        numberOfInstallments,
        basePricePerDay,
        totalDays,
        totalAmount,
        installmentAmount,
        serviceCharges,
        returnCharges,
        deposit,
        productSnapshot,
      ];
}

class RentalProductSnapshotEntity extends Equatable {
  final String name;
  final double perDayRent;
  final String? tabletName;
  final List<String> imageUrl;

  const RentalProductSnapshotEntity({
    required this.name,
    required this.perDayRent,
    this.tabletName,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [name, perDayRent, tabletName, imageUrl];
}

class RentalOrderDetailsEntity extends Equatable {
  final String id;
  final String paymentmethod;
  final String orderStatus;
  final RentalUserDetailsEntity? userDetails;

  const RentalOrderDetailsEntity({
    required this.id,
    required this.paymentmethod,
    required this.orderStatus,
    this.userDetails,
  });

  @override
  List<Object?> get props => [id, paymentmethod, orderStatus, userDetails];
}

class RentalUserDetailsEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;

  const RentalUserDetailsEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [id, firstName, lastName, email, phone];
}
