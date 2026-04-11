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

class LeadDetailsModel extends LeadDetailsEntity {
  const LeadDetailsModel({
    required super.id,
    required super.name,
    required super.phone,
    super.address,
    required super.leadSource,
    required super.leadStage,
    required super.serviceType,
    required super.vendorAssigned,
    super.date,
    required super.leadType,
    required super.age,
    required super.gender,
    required super.vendorPermission,
    required super.price,
    required super.discountPrice,
    required super.serviceName,
    required super.duration,
    super.serviceImage,
    super.userDetails,
  });

  factory LeadDetailsModel.fromJson(Map<String, dynamic> json) {
    final productDetails = json['productdetails'] ?? {};
    final tabletDetailsList = (productDetails['tabletdetails'] as List?) ?? [];

    String sName = 'Unknown Service';
    String duration = 'N/A';
    String? serviceImg;
    if (tabletDetailsList.isNotEmpty) {
      final tDetails = tabletDetailsList[0];
      sName = tDetails['name'] ?? 'Unknown Service';
      duration = tDetails['duration']?.toString() ?? 'N/A';
      if (tDetails['files'] != null && (tDetails['files'] as List).isNotEmpty) {
        serviceImg = tDetails['files'][0];
        if (serviceImg != null && !serviceImg.startsWith('http')) {
          serviceImg = "https://api.medicompares.com$serviceImg";
        }
      }
    }

    UserDetailsModel? uDetails;
    if (json['userDetails'] != null) {
      uDetails = UserDetailsModel.fromJson(json['userDetails']);
    }

    return LeadDetailsModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      phone: json['phone']?.toString() ?? '',
      address: json['address'],
      leadSource: json['leadSource'] ?? 'Unknown',
      leadStage: json['leadStage'] ?? 'Unknown',
      serviceType: json['serviceType'] ?? 'Unknown',
      vendorAssigned: json['vendorassined'] ?? 'Unknown',
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      leadType: json['leadType'] ?? 'Unknown',
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age']?.toString() ?? '0') ?? 0,
      gender: json['gender'] ?? 'Unknown',
      vendorPermission: json['vendorPermission'] ?? 'Unknown',
      price: (productDetails['price'] ?? 0).toDouble(),
      discountPrice: (productDetails['discountprice'] ?? 0).toDouble(),
      serviceName: sName,
      duration: duration,
      serviceImage: serviceImg,
      userDetails: uDetails,
    );
  }
}

class UserDetailsModel extends UserDetailsEntity {
  const UserDetailsModel({
    required super.id,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
    required super.files,
  });

  factory UserDetailsModel.fromJson(Map<String, dynamic> json) {
    return UserDetailsModel(
      id: json['_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone']?.toString() ?? '',
      files: (json['files'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
