import 'package:equatable/equatable.dart';

class LabTestCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String slug;
  final String status;
  final List<String> files;

  const LabTestCategory({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
    required this.status,
    required this.files,
  });

  factory LabTestCategory.fromJson(Map<String, dynamic> json) {
    return LabTestCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      slug: json['slug'] ?? '',
      status: json['status'] ?? '',
      files: (json['files'] != null && (json['files'] as List).isNotEmpty)
          ? List<String>.from(json['files'])
          : List<String>.from(json['imageUrl'] ?? []),
    );
  }

  @override
  List<Object?> get props => [id, name, description, slug, status, files];
}

class LabTestItem extends Equatable {
  final String id;
  final double price;
  final double discountPrice;
  final String status;
  final LabTestDetails details;

  const LabTestItem({
    required this.id,
    required this.price,
    required this.discountPrice,
    required this.status,
    required this.details,
  });

  factory LabTestItem.fromJson(Map<String, dynamic> json) {
    return LabTestItem(
      id: json['_id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountprice'] ?? 0).toDouble(),
      status: json['status'] ?? 'inactive',
      details: LabTestDetails.fromJson(json['tablets'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [id, price, discountPrice, status, details];
}

class LabTestDetails extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? precaution;
  final String? preparationInstructions;
  final String? sampleType;
  final String? isFasting;
  final String? gender;
  final String? reportsDuration;
  final List<String> files;
  final List<LabTestParameter> parameters;
  final LabTestSubcategory? subcategory;

  const LabTestDetails({
    required this.id,
    required this.name,
    this.description,
    this.precaution,
    this.preparationInstructions,
    this.sampleType,
    this.isFasting,
    this.gender,
    this.reportsDuration,
    required this.files,
    required this.parameters,
    this.subcategory,
  });

  factory LabTestDetails.fromJson(Map<String, dynamic> json) {
    return LabTestDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      precaution: json['precaution'],
      preparationInstructions: json['preparationInstructions'],
      sampleType: json['smapletype'], // Note typo in API: smapletype
      isFasting: json['isFasting'],
      gender: json['gender'],
      reportsDuration: json['reportsDuration'],
      files: (json['files'] != null && (json['files'] as List).isNotEmpty)
          ? List<String>.from(json['files'])
          : List<String>.from(json['imageUrl'] ?? []),
      parameters: (json['parameterss'] as List? ?? [])
          .map((i) => LabTestParameter.fromJson(i))
          .toList(),
      subcategory: json['subcategory'] != null && json['subcategory'] is Map
          ? LabTestSubcategory.fromJson(json['subcategory'])
          : (json['subcategorys'] != null && json['subcategorys'] is Map)
              ? LabTestSubcategory.fromJson(json['subcategorys'])
              : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        precaution,
        preparationInstructions,
        sampleType,
        isFasting,
        gender,
        reportsDuration,
        files,
        parameters,
        subcategory
      ];
}

class LabTestParameter extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? normalRange;
  final String? units;

  const LabTestParameter({
    required this.id,
    required this.name,
    this.description,
    this.normalRange,
    this.units,
  });

  factory LabTestParameter.fromJson(Map<String, dynamic> json) {
    return LabTestParameter(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      normalRange: json['normalRange'],
      units: json['units'],
    );
  }

  @override
  List<Object?> get props => [id, name, description, normalRange, units];
}

class LabTestSubcategory extends Equatable {
  final String id;
  final String name;

  const LabTestSubcategory({required this.id, required this.name});

  factory LabTestSubcategory.fromJson(Map<String, dynamic> json) {
    return LabTestSubcategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class LabTestPagination extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const LabTestPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory LabTestPagination.fromJson(Map<String, dynamic> json) {
    return LabTestPagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}

class LabTestResponse extends Equatable {
  final List<LabTestItem> list;
  final LabTestPagination pagination;

  const LabTestResponse({required this.list, required this.pagination});

  factory LabTestResponse.fromJson(Map<String, dynamic> json) {
    return LabTestResponse(
      list: (json['list'] as List? ?? [])
          .map((i) => LabTestItem.fromJson(i))
          .toList(),
      pagination: LabTestPagination.fromJson(json['pagination'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [list, pagination];
}

class LabTestDropdownItem extends Equatable {
  final String id;
  final String name;
  final double price;
  final String subcategoryId;

  const LabTestDropdownItem({
    required this.id,
    required this.name,
    required this.price,
    required this.subcategoryId,
  });

  factory LabTestDropdownItem.fromJson(Map<String, dynamic> json) {
    String subCatId = '';
    if (json['subcategory'] != null) {
      if (json['subcategory'] is String) {
        subCatId = json['subcategory'];
      } else if (json['subcategory'] is Map) {
        subCatId = json['subcategory']['_id'] ?? '';
      }
    }

    return LabTestDropdownItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      subcategoryId: subCatId,
    );
  }

  @override
  List<Object?> get props => [id, name, price, subcategoryId];
}
