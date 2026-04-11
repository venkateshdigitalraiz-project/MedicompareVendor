import 'package:equatable/equatable.dart';

class AmbulanceEntity extends Equatable {
  final String id;
  final String tabletId;
  final String name;
  final String ambulanceType;
  final double price; // Price per km
  final double discountPrice; // Discount Price per km
  final String status;
  final List<AmbulanceFacilityEntity> facilities;
  final List<String> files;

  const AmbulanceEntity({
    required this.id,
    required this.tabletId,
    required this.name,
    required this.ambulanceType,
    required this.price,
    required this.discountPrice,
    required this.status,
    required this.facilities,
    required this.files,
  });

  @override
  List<Object?> get props => [
        id,
        tabletId,
        name,
        ambulanceType,
        price,
        discountPrice,
        status,
        facilities,
        files,
      ];
}

class AmbulanceFacilityEntity extends Equatable {
  final String id;
  final String name;

  const AmbulanceFacilityEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

class AmbulanceCategoryEntity extends Equatable {
  final String id;
  final String name;

  const AmbulanceCategoryEntity({
    required this.id,
    required this.name,
  });

  @override
  List<Object?> get props => [id, name];
}

class AmbulanceNameOptionEntity extends Equatable {
  final String id;
  final String name;
  final String categoryId;

  const AmbulanceNameOptionEntity({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [id, name, categoryId];
}

class AmbulanceListEntity extends Equatable {
  final List<AmbulanceEntity> items;
  final AmbulancePaginationEntity pagination;

  const AmbulanceListEntity({
    required this.items,
    required this.pagination,
  });

  @override
  List<Object?> get props => [items, pagination];
}

class AmbulancePaginationEntity extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const AmbulancePaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}
