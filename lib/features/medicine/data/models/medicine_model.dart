import 'package:equatable/equatable.dart';

class MedicineCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String slug;
  final String? status;

  const MedicineCategory({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
    this.status,
  });

  factory MedicineCategory.fromJson(Map<String, dynamic> json) {
    return MedicineCategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      slug: json['slug'] ?? '',
      status: json['status'],
    );
  }

  @override
  List<Object?> get props => [id, name, description, slug, status];
}

class MedicineResponse extends Equatable {
  final List<MedicineItem> list;
  final Pagination pagination;

  const MedicineResponse({required this.list, required this.pagination});

  factory MedicineResponse.fromJson(Map<String, dynamic> json) {
    return MedicineResponse(
      list: (json['list'] as List? ?? [])
          .map((i) => MedicineItem.fromJson(i))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [list, pagination];
}

class MedicineItem extends Equatable {
  final String id;
  final double price;
  final double discountPrice;
  final String status;
  final MedicineDetails details;

  const MedicineItem({
    required this.id,
    required this.price,
    required this.discountPrice,
    required this.status,
    required this.details,
  });

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      id: json['_id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountprice'] ?? 0).toDouble(),
      status: json['status'] ?? 'inactive',
      details: MedicineDetails.fromJson(json['tablets'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [id, price, discountPrice, status, details];
}

class MedicineDetails extends Equatable {
  final String id;
  final String name;
  final String? slug;
  final String? description;
  final String? form;
  final String? brand;
  final List<String> imageUrl;
  final String? tabletImageUrl;
  final String? composition;
  final MedicineSubcategory? subcategory;
  final Manufacture? manufacture;
  final bool prescriptionRequired;
  final DateTime? createdAt;

  const MedicineDetails({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.form,
    this.brand,
    required this.imageUrl,
    this.tabletImageUrl,
    this.composition,
    this.subcategory,
    this.manufacture,
    this.prescriptionRequired = false,
    this.createdAt,
  });

  factory MedicineDetails.fromJson(Map<String, dynamic> json) {
    return MedicineDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      form: json['form'],
      brand: json['brand'],
      imageUrl: List<String>.from(json['imageUrl'] ?? []),
      tabletImageUrl: json['tabletImage']?['url'],
      composition: json['compositions']?['name'],
      subcategory: json['subcategory'] != null 
          ? MedicineSubcategory.fromJson(json['subcategory']) 
          : (json['subcategorys'] != null ? MedicineSubcategory.fromJson(json['subcategorys']) : null),
      manufacture: json['manufacture'] != null
          ? Manufacture.fromJson(json['manufacture'])
          : null,
      prescriptionRequired: json['prescriptionRequired'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  @override
  List<Object?> get props => [id, name, slug, description, form, imageUrl, subcategory, createdAt];
}

class MedicineSubcategory extends Equatable {
  final String id;
  final String name;
  final String? description;

  const MedicineSubcategory({required this.id, required this.name, this.description});

  factory MedicineSubcategory.fromJson(Map<String, dynamic> json) {
    return MedicineSubcategory(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [id, name, description];
}

class Manufacture extends Equatable {
  final String id;
  final String name;

  const Manufacture({required this.id, required this.name});

  factory Manufacture.fromJson(Map<String, dynamic> json) {
    return Manufacture(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name];
}

class Pagination extends Equatable {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const Pagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [total, page, limit, totalPages];
}

class MedicineDropdownItem extends Equatable {
  final String id;
  final String name;
  final double price;
  final String subcategoryId;

  const MedicineDropdownItem({
    required this.id,
    required this.name,
    required this.price,
    required this.subcategoryId,
  });

  factory MedicineDropdownItem.fromJson(Map<String, dynamic> json) {
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

    return MedicineDropdownItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      subcategoryId: subCatId,
    );
  }

  @override
  List<Object?> get props => [id, name, price, subcategoryId];
}
