import 'package:equatable/equatable.dart';

class HomeCareCategory extends Equatable {
  final String id;
  final String name;
  final String slug;
  final String status;
  final List<String> files;

  const HomeCareCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    required this.files,
  });

  factory HomeCareCategory.fromJson(Map<String, dynamic> json) {
    return HomeCareCategory(
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

class HomeCareItem extends Equatable {
  final String id;
  final double price;
  final double discountPrice;
  final String status;
  final HomeCareDetails details;

  const HomeCareItem({
    required this.id,
    required this.price,
    required this.discountPrice,
    required this.status,
    required this.details,
  });

  factory HomeCareItem.fromJson(Map<String, dynamic> json) {
    return HomeCareItem(
      id: json['_id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountprice'] ?? 0).toDouble(),
      status: json['status'] ?? 'inactive',
      details: HomeCareDetails.fromJson(json['tablets'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [id, price, discountPrice, status, details];
}

class HomeCareDetails extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? precaution;
  final String? sideEffects;
  final String? preparationInstructions;
  final String? duration;
  final List<String> files;
  final HomeCareSubcategory? subcategory;

  const HomeCareDetails({
    required this.id,
    required this.name,
    this.description,
    this.precaution,
    this.sideEffects,
    this.preparationInstructions,
    this.duration,
    required this.files,
    this.subcategory,
  });

  factory HomeCareDetails.fromJson(Map<String, dynamic> json) {
    return HomeCareDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      precaution: json['precaution'],
      sideEffects: json['sideeffects'],
      preparationInstructions: json['preparationInstructions'],
      duration: json['duration'],
      files: List<String>.from(json['files'] ?? []),
      subcategory: json['subcategory'] != null && json['subcategory'] is Map
          ? HomeCareSubcategory.fromJson(json['subcategory'])
          : (json['subcategorys'] != null && json['subcategorys'] is Map)
              ? HomeCareSubcategory.fromJson(json['subcategorys'])
              : null,
    );
  }

  @override
  List<Object?> get props => [
        id, name, description, precaution, sideEffects, preparationInstructions,
        duration, files, subcategory
      ];
}

class HomeCareSubcategory extends Equatable {
  final String id;
  final String name;
  final String? description;

  const HomeCareSubcategory({required this.id, required this.name, this.description});

  factory HomeCareSubcategory.fromJson(Map<String, dynamic> json) {
    return HomeCareSubcategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [id, name, description];
}

class HomeCareResponse extends Equatable {
  final List<HomeCareItem> list;
  final HomeCarePagination pagination;

  const HomeCareResponse({required this.list, required this.pagination});

  factory HomeCareResponse.fromJson(Map<String, dynamic> json) {
    return HomeCareResponse(
      list: (json['list'] as List? ?? []).map((i) => HomeCareItem.fromJson(i)).toList(),
      pagination: HomeCarePagination.fromJson(json['pagination'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [list, pagination];
}

class HomeCarePagination extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const HomeCarePagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory HomeCarePagination.fromJson(Map<String, dynamic> json) {
    return HomeCarePagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}

class HomeCareDropdownItem extends Equatable {
  final String id;
  final String name;
  final String? duration;
  final List<String> files;
  final HomeCareSubcategory? subcategory;
  final String? description;

  const HomeCareDropdownItem({
    required this.id,
    required this.name,
    this.duration,
    required this.files,
    this.subcategory,
    this.description,
  });

  factory HomeCareDropdownItem.fromJson(Map<String, dynamic> json) {
    return HomeCareDropdownItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      duration: json['duration'],
      files: List<String>.from(json['files'] ?? []),
      subcategory: json['subcategory'] != null && json['subcategory'] is Map
          ? HomeCareSubcategory.fromJson(json['subcategory'])
          : null,
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [id, name, duration, files, subcategory, description];
}
