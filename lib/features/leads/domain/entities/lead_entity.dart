import 'package:equatable/equatable.dart';

class LeadEntity extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final String? address;
  final String leadSource;
  final String leadStage;
  final String serviceType;
  final String serviceName;
  final String vendorPermission;
  final DateTime createdAt;

  const LeadEntity({
    required this.id,
    required this.name,
    this.email,
    required this.phone,
    this.address,
    required this.leadSource,
    required this.leadStage,
    required this.serviceType,
    required this.serviceName,
    required this.vendorPermission,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        address,
        leadSource,
        leadStage,
        serviceType,
        serviceName,
        vendorPermission,
        createdAt,
      ];
}

class LeadsListEntity extends Equatable {
  final List<LeadEntity> leads;
  final LeadsPaginationEntity pagination;

  const LeadsListEntity({
    required this.leads,
    required this.pagination,
  });

  @override
  List<Object?> get props => [leads, pagination];
}

class LeadsPaginationEntity extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const LeadsPaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}
