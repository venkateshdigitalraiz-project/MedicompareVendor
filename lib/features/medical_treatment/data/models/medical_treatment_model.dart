class MedicalTreatmentCategory {
  final String id;
  final String name;

  MedicalTreatmentCategory({
    required this.id,
    required this.name,
  });

  factory MedicalTreatmentCategory.fromJson(Map<String, dynamic> json) {
    return MedicalTreatmentCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class MedicalTreatmentItem {
  final String id;
  final double price;
  final double discountPrice;
  final String status;
  final MedicalTreatmentDetails details;

  MedicalTreatmentItem({
    required this.id,
    required this.price,
    required this.discountPrice,
    required this.status,
    required this.details,
  });

  factory MedicalTreatmentItem.fromJson(Map<String, dynamic> json) {
    return MedicalTreatmentItem(
      id: json['_id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountprice'] ?? 0).toDouble(),
      status: json['status'] ?? 'inactive',
      details: MedicalTreatmentDetails.fromJson(json['tablets'] ?? {}),
    );
  }
}

class MedicalTreatmentDetails {
  final String id;
  final String name;
  final String description;
  final String? complexity;
  final String? duration;
  final String? recoveryTime;
  final String? preparationInstructions;
  final List<String> files;
  final MedicalTreatmentSubcategory? subcategory;

  MedicalTreatmentDetails({
    required this.id,
    required this.name,
    required this.description,
    this.complexity,
    this.duration,
    this.recoveryTime,
    this.preparationInstructions,
    required this.files,
    this.subcategory,
  });

  factory MedicalTreatmentDetails.fromJson(Map<String, dynamic> json) {
    return MedicalTreatmentDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      complexity: json['complexity'],
      duration: json['duration'],
      recoveryTime: json['recoveryTime'],
      preparationInstructions: json['preparationInstructions'],
      files: (json['files'] as List?)?.map((e) => e.toString()).toList() ?? [],
      subcategory: json['subcategory'] is Map
          ? MedicalTreatmentSubcategory.fromJson(json['subcategory'])
          : (json['subcategorys'] is Map
              ? MedicalTreatmentSubcategory.fromJson(json['subcategorys'])
              : null),
    );
  }
}

class MedicalTreatmentSubcategory {
  final String id;
  final String name;
  final String? description;

  MedicalTreatmentSubcategory(
      {required this.id, required this.name, this.description});

  factory MedicalTreatmentSubcategory.fromJson(Map<String, dynamic> json) {
    return MedicalTreatmentSubcategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

class MedicalTreatmentResponse {
  final List<MedicalTreatmentItem> list;
  final MedicalTreatmentPagination pagination;

  MedicalTreatmentResponse({
    required this.list,
    required this.pagination,
  });

  factory MedicalTreatmentResponse.fromJson(Map<String, dynamic> json) {
    return MedicalTreatmentResponse(
      list: (json['list'] as List?)
              ?.map((i) => MedicalTreatmentItem.fromJson(i))
              .toList() ??
          [],
      pagination: MedicalTreatmentPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class MedicalTreatmentPagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  MedicalTreatmentPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory MedicalTreatmentPagination.fromJson(Map<String, dynamic> json) {
    return MedicalTreatmentPagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class MedicalTreatmentDropdownItem {
  final String id;
  final String name;
  final String? description;
  final String? duration;
  final String? complexity;
  final MedicalTreatmentSubcategory? subcategory;

  MedicalTreatmentDropdownItem({
    required this.id,
    required this.name,
    this.description,
    this.duration,
    this.complexity,
    this.subcategory,
  });

  factory MedicalTreatmentDropdownItem.fromJson(Map<String, dynamic> json) {
    return MedicalTreatmentDropdownItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      duration: json['duration'],
      complexity: json['complexity'],
      subcategory: json['subcategory'] is Map
          ? MedicalTreatmentSubcategory.fromJson(json['subcategory'])
          : null,
    );
  }
}
