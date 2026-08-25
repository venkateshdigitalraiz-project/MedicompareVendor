import '../../domain/entities/medical_equipment_entity.dart';

class MedicalEquipmentCategoryModel extends MedicalEquipmentCategory {
  const MedicalEquipmentCategoryModel({
    required super.id,
    required super.name,
    super.slug,
  });

  factory MedicalEquipmentCategoryModel.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentCategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
    );
  }
}

class MedicalEquipmentItemModel extends MedicalEquipmentItem {
  const MedicalEquipmentItemModel({
    required super.id,
    required super.price,
    required super.discountPrice,
    required super.status,
    super.fixedDeposit,
    super.returnCharge,
    super.serviceCharges,
    super.interest,
    super.perDayRent,
    required super.details,
  });

  factory MedicalEquipmentItemModel.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentItemModel(
      id: json['_id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountprice'] ?? 0).toDouble(),
      status: json['status'] ?? 'inactive',
      fixedDeposit: (json['fixedDeposit'] ?? 0).toDouble(),
      returnCharge: (json['returnCharge'] ?? 0).toDouble(),
      serviceCharges: (json['serviceCharges'] ?? 0).toDouble(),
      interest: (json['interest'] ?? 0).toDouble(),
      perDayRent: (json['perDayRent'] ?? 0).toDouble(),
      details: MedicalEquipmentDetailsModel.fromJson(json['tablets'] ?? {}),
    );
  }
}

class MedicalEquipmentDetailsModel extends MedicalEquipmentDetails {
  const MedicalEquipmentDetailsModel({
    required super.id,
    required super.name,
    required super.description,
    super.machineType,
    super.model,
    super.condition,
    required super.files,
    super.subcategory,
    super.brand,
  });

  factory MedicalEquipmentDetailsModel.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentDetailsModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      machineType: json['machineType'],
      model: json['model'],
      condition: json['condition'],
      files: (json['files'] as List?)?.map((e) => e.toString()).toList() ?? [],
      subcategory: json['subcategory'] is Map
          ? MedicalEquipmentSubcategoryModel.fromJson(json['subcategory'])
          : (json['subcategorys'] is Map
              ? MedicalEquipmentSubcategoryModel.fromJson(json['subcategorys'])
              : null),
      brand: json['manufacture'] is Map ? json['manufacture']['name'] : (json['manufacture'] is String ? json['manufacture'] : null),
    );
  }
}

class MedicalEquipmentSubcategoryModel extends MedicalEquipmentSubcategory {
  const MedicalEquipmentSubcategoryModel({
    required super.id,
    required super.name,
    super.description,
  });

  factory MedicalEquipmentSubcategoryModel.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentSubcategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

class MedicalEquipmentResponseModel extends MedicalEquipmentResponse {
  const MedicalEquipmentResponseModel({
    required super.list,
    required super.pagination,
  });

  factory MedicalEquipmentResponseModel.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentResponseModel(
      list: (json['list'] as List?)
              ?.map((i) => MedicalEquipmentItemModel.fromJson(i))
              .toList() ??
          [],
      pagination: MedicalEquipmentPaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }
}

class MedicalEquipmentPaginationModel extends MedicalEquipmentPagination {
  const MedicalEquipmentPaginationModel({
    required super.total,
    required super.page,
    required super.limit,
    required super.totalPages,
  });

  factory MedicalEquipmentPaginationModel.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentPaginationModel(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class MedicalEquipmentDropdownItemModel extends MedicalEquipmentDropdownItem {
  const MedicalEquipmentDropdownItemModel({
    required super.id,
    required super.name,
    super.description,
    super.model,
    super.brand,
    super.subcategory,
  });

  factory MedicalEquipmentDropdownItemModel.fromJson(Map<String, dynamic> json) {
    return MedicalEquipmentDropdownItemModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      model: json['model'],
      brand: json['brand'] is Map ? json['brand']['name'] : json['brand'],
      subcategory: json['subcategory'] is Map
          ? MedicalEquipmentSubcategoryModel.fromJson(json['subcategory'])
          : null,
    );
  }
}
