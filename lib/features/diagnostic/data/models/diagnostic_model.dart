import 'package:equatable/equatable.dart';

class DiagnosticCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String slug;
  final String status;
  final List<String> files;

  const DiagnosticCategory({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
    required this.status,
    required this.files,
  });

  factory DiagnosticCategory.fromJson(Map<String, dynamic> json) {
    return DiagnosticCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      slug: json['slug'] ?? '',
      status: json['status'] ?? '',
      files: List<String>.from(json['files'] ?? []),
    );
  }

  @override
  List<Object?> get props => [id, name, description, slug, status, files];
}

class DiagnosticItem extends Equatable {
  final String id;
  final double price;
  final double discountPrice;
  final String status;
  final DiagnosticDetails details;

  const DiagnosticItem({
    required this.id,
    required this.price,
    required this.discountPrice,
    required this.status,
    required this.details,
  });

  factory DiagnosticItem.fromJson(Map<String, dynamic> json) {
    return DiagnosticItem(
      id: json['_id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountprice'] ?? 0).toDouble(),
      status: json['status'] ?? 'inactive',
      details: DiagnosticDetails.fromJson(json['tablets'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [id, price, discountPrice, status, details];
}

class DiagnosticDetails extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? precaution;
  final String? preparationInstructions;
  final String? sideEffects;
  final String? bodyPart;
  final String? isContrast;
  final String? reportsDuration;
  final String? gender;
  final List<String> files;
  final DiagnosticSubcategory? subcategory;

  const DiagnosticDetails({
    required this.id,
    required this.name,
    this.description,
    this.precaution,
    this.preparationInstructions,
    this.sideEffects,
    this.bodyPart,
    this.isContrast,
    this.reportsDuration,
    this.gender,
    required this.files,
    this.subcategory,
  });

  factory DiagnosticDetails.fromJson(Map<String, dynamic> json) {
    return DiagnosticDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      precaution: json['precaution'],
      preparationInstructions: json['preparationInstructions'],
      sideEffects: json['sideeffects'],
      bodyPart: json['bodypart'],
      isContrast: json['iscontrast'],
      reportsDuration: json['reportsDuration'],
      gender: json['gender'],
      files: List<String>.from(json['files'] ?? []),
      subcategory: json['subcategory'] != null && json['subcategory'] is Map
          ? DiagnosticSubcategory.fromJson(json['subcategory'])
          : (json['subcategorys'] != null && json['subcategorys'] is Map)
              ? DiagnosticSubcategory.fromJson(json['subcategorys'])
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
        sideEffects,
        bodyPart,
        isContrast,
        reportsDuration,
        gender,
        files,
        subcategory
      ];
}

class DiagnosticSubcategory extends Equatable {
  final String id;
  final String name;
  final String? description;

  const DiagnosticSubcategory(
      {required this.id, required this.name, this.description});

  factory DiagnosticSubcategory.fromJson(Map<String, dynamic> json) {
    return DiagnosticSubcategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [id, name, description];
}

class DiagnosticPagination extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const DiagnosticPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory DiagnosticPagination.fromJson(Map<String, dynamic> json) {
    return DiagnosticPagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}

class DiagnosticResponse extends Equatable {
  final List<DiagnosticItem> list;
  final DiagnosticPagination pagination;

  const DiagnosticResponse({required this.list, required this.pagination});

  factory DiagnosticResponse.fromJson(Map<String, dynamic> json) {
    return DiagnosticResponse(
      list: (json['list'] as List? ?? [])
          .map((i) => DiagnosticItem.fromJson(i))
          .toList(),
      pagination: DiagnosticPagination.fromJson(json['pagination'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [list, pagination];
}

class DiagnosticDropdownItem extends Equatable {
  final String id;
  final String name;
  final String? subcategoryId;
  final String? bodyPart;
  final String? isContrast;
  final String? reportsDuration;
  final List<String> files;

  const DiagnosticDropdownItem({
    required this.id,
    required this.name,
    this.subcategoryId,
    this.bodyPart,
    this.isContrast,
    this.reportsDuration,
    required this.files,
  });

  factory DiagnosticDropdownItem.fromJson(Map<String, dynamic> json) {
    String? subCatId;
    if (json['subcategory'] != null) {
      if (json['subcategory'] is String) {
        subCatId = json['subcategory'];
      } else if (json['subcategory'] is Map) {
        subCatId = json['subcategory']['_id'];
      }
    }
    return DiagnosticDropdownItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      subcategoryId: subCatId,
      bodyPart: json['bodypart'],
      isContrast: json['iscontrast'],
      reportsDuration: json['reportsDuration'],
      files: List<String>.from(json['files'] ?? []),
    );
  }

  @override
  List<Object?> get props =>
      [id, name, subcategoryId, bodyPart, isContrast, reportsDuration];
}
