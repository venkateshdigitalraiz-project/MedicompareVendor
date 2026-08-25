import 'package:equatable/equatable.dart';

class LeadEntity extends Equatable {
  final String id;
  final String name;
  final String? email;
  final String phone;
  final int age;
  final double price;
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
    required this.age,
    required this.price,
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
        age,
        price,
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

class LeadDetailsEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final String leadSource;
  final String leadStage;
  final String serviceType;
  final String vendorAssigned;
  final DateTime? date;
  final String leadType;
  final int age;
  final String gender;
  final String vendorPermission;
  final double price;
  final double discountPrice;
  final String serviceName;
  final String duration;
  final String? serviceImage;
  final UserDetailsEntity? userDetails;
  final String? emailAddress;
  final String? city;
  final String? policyNumber;
  final String? relation;
  final String? preferredTimeline;
  final String? description;
  final String? complexity;
  final String? procedureType;
  final String? recoveryTime;

  const LeadDetailsEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    required this.leadSource,
    required this.leadStage,
    required this.serviceType,
    required this.vendorAssigned,
    this.date,
    required this.leadType,
    required this.age,
    required this.gender,
    required this.vendorPermission,
    required this.price,
    required this.discountPrice,
    required this.serviceName,
    required this.duration,
    this.serviceImage,
    this.userDetails,
    this.emailAddress,
    this.city,
    this.policyNumber,
    this.relation,
    this.preferredTimeline,
    this.description,
    this.complexity,
    this.procedureType,
    this.recoveryTime,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        address,
        leadSource,
        leadStage,
        serviceType,
        vendorAssigned,
        date,
        leadType,
        age,
        gender,
        vendorPermission,
        price,
        discountPrice,
        serviceName,
        duration,
        serviceImage,
        userDetails,
        emailAddress,
        city,
        policyNumber,
        relation,
        preferredTimeline,
        description,
        complexity,
        procedureType,
        recoveryTime,
      ];
}

class UserDetailsEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final List<String> files;

  const UserDetailsEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.files,
  });

  String get fullName => "$firstName $lastName";

  @override
  List<Object?> get props => [id, firstName, lastName, email, phone, files];
}
