class DentalServiceCategory {
  final String id;
  final String name;

  DentalServiceCategory({
    required this.id,
    required this.name,
  });

  factory DentalServiceCategory.fromJson(Map<String, dynamic> json) {
    return DentalServiceCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class DentalServiceItem {
  final String id;
  final double price;
  final double discountPrice;
  final String status;
  final DentalServiceDetails details;

  DentalServiceItem({
    required this.id,
    required this.price,
    required this.discountPrice,
    required this.status,
    required this.details,
  });

  factory DentalServiceItem.fromJson(Map<String, dynamic> json) {
    return DentalServiceItem(
      id: json['_id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountprice'] ?? 0).toDouble(),
      status: json['status'] ?? 'inactive',
      details: DentalServiceDetails.fromJson(json['tablets'] ?? {}),
    );
  }
}

class DentalServiceDetails {
  final String id;
  final String name;
  final String description;
  final String? treatmentType;
  final String? complexity;
  final List<String> files;
  final DentalServiceSubcategory? subcategory;

  DentalServiceDetails({
    required this.id,
    required this.name,
    required this.description,
    this.treatmentType,
    this.complexity,
    required this.files,
    this.subcategory,
  });

  factory DentalServiceDetails.fromJson(Map<String, dynamic> json) {
    return DentalServiceDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      treatmentType: json['treatmenttype'],
      complexity: json['complexity'],
      files: (json['files'] as List?)?.map((e) => e.toString()).toList() ?? [],
      subcategory: json['subcategory'] is Map
          ? DentalServiceSubcategory.fromJson(json['subcategory'])
          : (json['subcategorys'] is Map
              ? DentalServiceSubcategory.fromJson(json['subcategorys'])
              : null),
    );
  }
}

class DentalServiceSubcategory {
  final String id;
  final String name;
  final String? description;

  DentalServiceSubcategory(
      {required this.id, required this.name, this.description});

  factory DentalServiceSubcategory.fromJson(Map<String, dynamic> json) {
    return DentalServiceSubcategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

class DentalServiceResponse {
  final List<DentalServiceItem> list;
  final DentalServicePagination pagination;

  DentalServiceResponse({
    required this.list,
    required this.pagination,
  });

  factory DentalServiceResponse.fromJson(Map<String, dynamic> json) {
    return DentalServiceResponse(
      list: (json['list'] as List?)
              ?.map((i) => DentalServiceItem.fromJson(i))
              .toList() ??
          [],
      pagination: DentalServicePagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class DentalServicePagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  DentalServicePagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory DentalServicePagination.fromJson(Map<String, dynamic> json) {
    return DentalServicePagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class DentalServiceDropdownItem {
  final String id;
  final String name;
  final String? treatmentType;
  final String? complexity;
  final String? description;
  final DentalServiceSubcategory? subcategory;

  DentalServiceDropdownItem({
    required this.id,
    required this.name,
    this.treatmentType,
    this.complexity,
    this.description,
    this.subcategory,
  });

  factory DentalServiceDropdownItem.fromJson(Map<String, dynamic> json) {
    return DentalServiceDropdownItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      treatmentType: json['treatmenttype'],
      complexity: json['complexity'],
      description: json['description'],
      subcategory: json['subcategory'] is Map
          ? DentalServiceSubcategory.fromJson(json['subcategory'])
          : null,
    );
  }
}
