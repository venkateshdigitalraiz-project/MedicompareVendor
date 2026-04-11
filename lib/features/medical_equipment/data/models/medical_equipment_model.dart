class MedicalEquipmentCategory {
  final String id;
  final String name;

  MedicalEquipmentCategory({
    required this.id,
    required this.name,
  });

  factory MedicalEquipmentCategory.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class MedicalEquipmentItem {
  final String id;
  final double price;
  final double discountPrice;
  final String status;
  final double? fixedDeposit;
  final double? returnCharge;
  final double? serviceCharges;
  final double? interest;
  final double? perDayRent;
  final MedicalEquipmentDetails details;

  MedicalEquipmentItem({
    required this.id,
    required this.price,
    required this.discountPrice,
    required this.status,
    this.fixedDeposit,
    this.returnCharge,
    this.serviceCharges,
    this.interest,
    this.perDayRent,
    required this.details,
  });

  factory MedicalEquipmentItem.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentItem(
      id: json['_id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountprice'] ?? 0).toDouble(),
      status: json['status'] ?? 'inactive',
      fixedDeposit: (json['fixedDeposit'] ?? 0).toDouble(),
      returnCharge: (json['returnCharge'] ?? 0).toDouble(),
      serviceCharges: (json['serviceCharges'] ?? 0).toDouble(),
      interest: (json['interest'] ?? 0).toDouble(),
      perDayRent: (json['perDayRent'] ?? 0).toDouble(),
      details: MedicalEquipmentDetails.fromJson(json['tablets'] ?? {}),
    );
  }
}

class MedicalEquipmentDetails {
  final String id;
  final String name;
  final String description;
  final String? machineType;
  final String? model;
  final String? condition;
  final List<String> files;
  final MedicalEquipmentSubcategory? subcategory;

  MedicalEquipmentDetails({
    required this.id,
    required this.name,
    required this.description,
    this.machineType,
    this.model,
    this.condition,
    required this.files,
    this.subcategory,
  });

  factory MedicalEquipmentDetails.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      machineType: json['machineType'],
      model: json['model'],
      condition: json['condition'],
      files: (json['files'] as List?)?.map((e) => e.toString()).toList() ?? [],
      subcategory: json['subcategory'] is Map
          ? MedicalEquipmentSubcategory.fromJson(json['subcategory'])
          : (json['subcategorys'] is Map
              ? MedicalEquipmentSubcategory.fromJson(json['subcategorys'])
              : null),
    );
  }
}

class MedicalEquipmentSubcategory {
  final String id;
  final String name;
  final String? description;

  MedicalEquipmentSubcategory(
      {required this.id, required this.name, this.description});

  factory MedicalEquipmentSubcategory.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentSubcategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

class MedicalEquipmentResponse {
  final List<MedicalEquipmentItem> list;
  final MedicalEquipmentPagination pagination;

  MedicalEquipmentResponse({
    required this.list,
    required this.pagination,
  });

  factory MedicalEquipmentResponse.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentResponse(
      list: (json['list'] as List?)
              ?.map((i) => MedicalEquipmentItem.fromJson(i))
              .toList() ??
          [],
      pagination: MedicalEquipmentPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class MedicalEquipmentPagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  MedicalEquipmentPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MedicalEquipmentPagination.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentPagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class MedicalEquipmentDropdownItem {
  final String id;
  final String name;
  final String? description;
  final String? model;
  final String? brand;
  final MedicalEquipmentSubcategory? subcategory;

  MedicalEquipmentDropdownItem({
    required this.id,
    required this.name,
    this.description,
    this.model,
    this.brand,
    this.subcategory,
  });

  factory MedicalEquipmentDropdownItem.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentDropdownItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      model: json['model'],
      brand: json['brand'] is Map ? json['brand']['name'] : json['brand'],
      subcategory: json['subcategory'] is Map
          ? MedicalEquipmentSubcategory.fromJson(json['subcategory'])
          : null,
    );
  }
}
