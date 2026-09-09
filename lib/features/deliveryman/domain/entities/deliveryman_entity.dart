import 'package:equatable/equatable.dart';

class DeliverymanEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String vehicleType;
  final String vehicleNumber;
  final String status;
  final int totalDeliveries;
  final String? profileImage;
  final double rating;
  final DateTime? createdAt;

  const DeliverymanEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.status,
    required this.totalDeliveries,
    this.profileImage,
    this.rating = 0.0,
    this.createdAt,
  });

  bool get isActive => status.toLowerCase() == 'active';

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        phone,
        vehicleType,
        vehicleNumber,
        status,
        totalDeliveries,
        profileImage,
        rating,
        createdAt,
      ];
}

class DeliverymanSummaryEntity extends Equatable {
  final int totalPersonnel;
  final int activePartners;
  final int inactivePartners;
  final int completedDeliveries;

  const DeliverymanSummaryEntity({
    this.totalPersonnel = 0,
    this.activePartners = 0,
    this.inactivePartners = 0,
    this.completedDeliveries = 0,
  });

  @override
  List<Object?> get props => [
        totalPersonnel,
        activePartners,
        inactivePartners,
        completedDeliveries,
      ];
}

class DeliverymanPaginationEntity extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const DeliverymanPaginationEntity({
    this.total = 0,
    this.page = 1,
    this.limit = 10,
    this.totalPages = 1,
  });

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}

class DeliverymanListResponseEntity extends Equatable {
  final List<DeliverymanEntity> list;
  final DeliverymanPaginationEntity pagination;
  final DeliverymanSummaryEntity summary;

  const DeliverymanListResponseEntity({
    this.list = const [],
    this.pagination = const DeliverymanPaginationEntity(),
    this.summary = const DeliverymanSummaryEntity(),
  });

  @override
  List<Object?> get props => [list, pagination, summary];
}
