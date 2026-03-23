import 'package:equatable/equatable.dart';

class NursingCareCategory extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String status;
  final List<String> files;

  const NursingCareCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    required this.files,
  });

  factory NursingCareCategory.fromJson(Map<String, dynamic> json) {
    return NursingCareCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      status: json['status'] ?? '',
      files: List<String>.from(json['files'] ?? []),
    );
  }

  @override
  List<Object?> get props => [id, name, slug, status, files];
}

class NursingCareItem extends Equatable {
  final String id;
  final double price;
  final double discountPrice;
  final String status;
  final NursingCareDetails details;

  const NursingCareItem({
    required this.id,
    required this.price,
    required this.discountPrice,
    required this.status,
    required this.details,
  });

  factory NursingCareItem.fromJson(Map<String, dynamic> json) {
    return NursingCareItem(
      id: json['_id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountprice'] ?? 0).toDouble(),
      status: json['status'] ?? 'inactive',
      details: NursingCareDetails.fromJson(json['tablets'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [id, price, discountPrice, status, details];
}

class NursingCareDetails extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? precaution;
  final String? sideEffects;
  final String? preparationInstructions;
  final String? duration;
  final String? nursecareType;
  final String? shiftType;
  final List<String> files;
  final NursingCareSubcategory? subcategory;

  const NursingCareDetails({
    required this.id,
    required this.name,
    this.description,
    this.precaution,
    this.sideEffects,
    this.preparationInstructions,
    this.duration,
    this.nursecareType,
    this.shiftType,
    required this.files,
    this.subcategory,
  });

  factory NursingCareDetails.fromJson(Map<String, dynamic> json) {
    return NursingCareDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      precaution: json['precaution'],
      sideEffects: json['sideeffects'],
      preparationInstructions: json['preparationInstructions'],
      duration: json['duration'],
      nursecareType: json['nursecareType'],
      shiftType: json['shiftType'],
      files: List<String>.from(json['files'] ?? []),
      subcategory: json['subcategory'] != null && json['subcategory'] is Map
          ? NursingCareSubcategory.fromJson(json['subcategory'])
          : (json['subcategorys'] != null && json['subcategorys'] is Map)
              ? NursingCareSubcategory.fromJson(json['subcategorys'])
              : null,
    );
  }

  @override
  List<Object?> get props => [
        id, name, description, precaution, sideEffects, preparationInstructions,
        duration, nursecareType, shiftType, files, subcategory
      ];
}

class NursingCareSubcategory extends Equatable {
  final String id;
  final String name;
  final String? description;

  const NursingCareSubcategory({required this.id, required this.name, this.description});

  factory NursingCareSubcategory.fromJson(Map<String, dynamic> json) {
    return NursingCareSubcategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [id, name, description];
}

class NursingCareResponse extends Equatable {
  final List<NursingCareItem> list;
  final NursingCarePagination pagination;

  const NursingCareResponse({required this.list, required this.pagination});

  factory NursingCareResponse.fromJson(Map<String, dynamic> json) {
    return NursingCareResponse(
      list: (json['list'] as List? ?? []).map((i) => NursingCareItem.fromJson(i)).toList(),
      pagination: NursingCarePagination.fromJson(json['pagination'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [list, pagination];
}

class NursingCarePagination extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const NursingCarePagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory NursingCarePagination.fromJson(Map<String, dynamic> json) {
    return NursingCarePagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}

class NursingCareDropdownItem extends Equatable {
  final String id;
  final String name;
  final String? duration;
  final String? nursecareType;
  final String? shiftType;
  final List<String> files;
  final NursingCareSubcategory? subcategory;
  final String? description;

  const NursingCareDropdownItem({
    required this.id,
    required this.name,
    this.duration,
    this.nursecareType,
    this.shiftType,
    required this.files,
    this.subcategory,
    this.description,
  });

  factory NursingCareDropdownItem.fromJson(Map<String, dynamic> json) {
    return NursingCareDropdownItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      duration: json['duration'],
      nursecareType: json['nursecareType'],
      shiftType: json['shiftType'],
      files: List<String>.from(json['files'] ?? []),
      subcategory: json['subcategory'] != null && json['subcategory'] is Map
          ? NursingCareSubcategory.fromJson(json['subcategory'])
          : null,
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [id, name, duration, nursecareType, shiftType, files, subcategory, description];
}
