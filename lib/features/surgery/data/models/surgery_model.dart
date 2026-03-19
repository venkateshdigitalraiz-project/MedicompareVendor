import 'package:equatable/equatable.dart';

class SurgeryCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String slug;
  final String status;

  const SurgeryCategory({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
    required this.status,
  });

  factory SurgeryCategory.fromJson(Map<String, dynamic> json) {
    return SurgeryCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      slug: json['slug'] ?? '',
      status: json['status'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, description, slug, status];
}

class SurgeryItem extends Equatable {
  final String id;
  final double price;
  final double discountPrice;
  final String status;
  final SurgeryDetails details;

  const SurgeryItem({
    required this.id,
    required this.price,
    required this.discountPrice,
    required this.status,
    required this.details,
  });

  factory SurgeryItem.fromJson(Map<String, dynamic> json) {
    return SurgeryItem(
      id: json['_id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountprice'] ?? 0).toDouble(),
      status: json['status'] ?? 'inactive',
      details: SurgeryDetails.fromJson(json['tablets'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [id, price, discountPrice, status, details];
}

class SurgeryDetails extends Equatable {
  final String id;
  final String name;
  final String? complexity;
  final String? duration;
  final String? recoveryTime;
  final String? procedureType;
  final String? description;
  final String? directionOfUse;
  final String? precaution;
  final String? sideEffects;
  final List<String> files;
  final SurgerySubcategory? subcategory;

  const SurgeryDetails({
    required this.id,
    required this.name,
    this.complexity,
    this.duration,
    this.recoveryTime,
    this.procedureType,
    this.description,
    this.directionOfUse,
    this.precaution,
    this.sideEffects,
    required this.files,
    this.subcategory,
  });

  factory SurgeryDetails.fromJson(Map<String, dynamic> json) {
    return SurgeryDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      complexity: json['complexity'],
      duration: json['duration'],
      recoveryTime: json['recoveryTime'],
      procedureType: json['procedureType'],
      description: json['description'],
      directionOfUse: json['directionofuse'],
      precaution: json['precaution'],
      sideEffects: json['sideeffects'],
      files: List<String>.from(json['files'] ?? []),
      subcategory: json['subcategory'] != null && json['subcategory'] is Map
          ? SurgerySubcategory.fromJson(json['subcategory']) 
          : (json['subcategorys'] != null && json['subcategorys'] is Map)
              ? SurgerySubcategory.fromJson(json['subcategorys'])
              : null,
    );
  }

  @override
  List<Object?> get props => [
    id, name, complexity, duration, recoveryTime, procedureType, 
    description, directionOfUse, precaution, sideEffects, files, subcategory
  ];
}

class SurgerySubcategory extends Equatable {
  final String id;
  final String name;
  final List<String> files;

  const SurgerySubcategory({required this.id, required this.name, required this.files});

  factory SurgerySubcategory.fromJson(Map<String, dynamic> json) {
    return SurgerySubcategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      files: List<String>.from(json['files'] ?? []),
    );
  }

  @override
  List<Object?> get props => [id, name, files];
}

class SurgeryPagination extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const SurgeryPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory SurgeryPagination.fromJson(Map<String, dynamic> json) {
    return SurgeryPagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}

class SurgeryResponse extends Equatable {
  final List<SurgeryItem> list;
  final SurgeryPagination pagination;

  const SurgeryResponse({required this.list, required this.pagination});

  factory SurgeryResponse.fromJson(Map<String, dynamic> json) {
    return SurgeryResponse(
      list: (json['list'] as List? ?? [])
          .map((i) => SurgeryItem.fromJson(i))
          .toList(),
      pagination: SurgeryPagination.fromJson(json['pagination'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [list, pagination];
}

class SurgeryDropdownItem extends Equatable {
  final String id;
  final String name;
  final String subcategoryId;
  final String? complexity;
  final String? duration;
  final String? description;

  const SurgeryDropdownItem({
    required this.id,
    required this.name,
    required this.subcategoryId,
    this.complexity,
    this.duration,
    this.description,
  });

  factory SurgeryDropdownItem.fromJson(Map<String, dynamic> json) {
    String subCatId = '';
    if (json['subcategory'] != null) {
      if (json['subcategory'] is String) {
        subCatId = json['subcategory'];
      } else if (json['subcategory'] is Map) {
        subCatId = json['subcategory']['_id'] ?? '';
      }
    } else if (json['subcategorys'] != null) {
      if (json['subcategorys'] is Map) {
        subCatId = json['subcategorys']['_id'] ?? '';
      }
    }

    return SurgeryDropdownItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      subcategoryId: subCatId,
      complexity: json['complexity'],
      duration: json['duration'],
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [id, name, subcategoryId, complexity, duration, description];
}
