import '../../domain/entities/lead_entity.dart';

class LeadModel extends LeadEntity {
  const LeadModel({
    required super.id,
    required super.name,
    super.email,
    required super.phone,
    super.address,
    required super.leadSource,
    required super.leadStage,
    required super.serviceType,
    required super.serviceName,
    required super.vendorPermission,
    required super.createdAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    final productDetails = json['productdetails'] ?? {};
    final tabletDetailsList = (productDetails['tabletdetails'] as List?) ?? [];
    String sName = 'Unknown Service';
    if (tabletDetailsList.isNotEmpty) {
      sName = tabletDetailsList[0]['name'] ?? 'Unknown Service';
    }

    return LeadModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'],
      phone: json['phone'] ?? '',
      address: json['address'],
      leadSource: json['leadSource'] ?? 'Unknown',
      leadStage: json['leadStage'] ?? 'new',
      serviceType: json['serviceType'] ?? 'Unknown',
      serviceName: sName,
      vendorPermission: json['vendorPermission'] ?? 'pending',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

class LeadsListModel extends LeadsListEntity {
  const LeadsListModel({
    required super.leads,
    required super.pagination,
  });

  factory LeadsListModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> leadsJson = json['leads'] ?? [];
    return LeadsListModel(
      leads: leadsJson.map((item) => LeadModel.fromJson(item)).toList(),
      pagination: LeadsPaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }
}

class LeadsPaginationModel extends LeadsPaginationEntity {
  const LeadsPaginationModel({
    required super.total,
    required super.page,
    required super.limit,
    required super.totalPages,
  });

  factory LeadsPaginationModel.fromJson(Map<String, dynamic> json) {
    return LeadsPaginationModel(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
