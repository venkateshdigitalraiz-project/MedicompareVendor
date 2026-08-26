import 'package:equatable/equatable.dart';

class AppointmentsListEntity extends Equatable {
  final List<AppointmentItemEntity> appointmentItems;
  final AppointmentPaginationEntity pagination;

  const AppointmentsListEntity({
    required this.appointmentItems,
    required this.pagination,
  });

  @override
  List<Object?> get props => [appointmentItems, pagination];
}

class AppointmentPaginationEntity extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AppointmentPaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}

class AppointmentItemEntity extends Equatable {
  final String id;
  final String orderItemId;
  final String orderStatus;
  final String type;
  final int quantity;
  final double totalPrice;
  final DateTime createdAt;
  final AppointmentProductDetailsEntity productDetails;
  final AppointmentUserDetailsEntity? userDetails;
  final DateTime? appointmentDate;
  final String? branchName;

  const AppointmentItemEntity({
    required this.id,
    required this.orderItemId,
    required this.orderStatus,
    required this.type,
    required this.quantity,
    required this.totalPrice,
    required this.createdAt,
    required this.productDetails,
    this.userDetails,
    this.appointmentDate,
    this.branchName,
  });

  @override
  List<Object?> get props => [
        id,
        orderItemId,
        orderStatus,
        type,
        quantity,
        totalPrice,
        createdAt,
        productDetails,
        userDetails,
        appointmentDate,
        branchName,
      ];
}

class AppointmentProductDetailsEntity extends Equatable {
  final String name;
  final List<String> files;

  const AppointmentProductDetailsEntity({
    required this.name,
    required this.files,
  });

  @override
  List<Object?> get props => [name, files];
}

class AppointmentUserDetailsEntity extends Equatable {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;

  const AppointmentUserDetailsEntity({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, phone];
}
