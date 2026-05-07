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
  final String discountType;
  final String status;
  final MedicineDetails details;
  final bool isStock;
  final int stock;
  final String? returnDetails;
  final List<VariantDetail> variantDetails;

  const MedicineItem({
    required this.id,
    required this.price,
    required this.discountPrice,
    required this.discountType,
    required this.status,
    required this.details,
    this.isStock = true,
    this.stock = 0,
    this.returnDetails,
    this.variantDetails = const [],
  });

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      id: json['_id'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice:
          (json['discountprice'] ?? json['discount'] ?? 0).toDouble(),
      discountType: json['discountType'] ?? 'price',
      status: json['status'] ?? 'inactive',
      details: (json['tablets'] != null && json['tablets'] is Map)
          ? MedicineDetails.fromJson(json['tablets'])
          : MedicineDetails.fromJson({}),
      isStock: json['isStock'] ?? true,
      stock: json['stock'] ?? 0,
      returnDetails: json['returnDetails']?.toString(),
      variantDetails: (json['variantdetails'] as List? ??
              json['variantdetail'] as List? ??
              [])
          .where((i) => i is Map<String, dynamic>)
          .map((i) => VariantDetail.fromJson(i))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        price,
        discountPrice,
        discountType,
        status,
        details,
        isStock,
        stock,
        variantDetails
      ];
}

class MedicineDetails extends Equatable {
  final String id;
  final String name;
  final String? slug;
  final String? description;
  final String? form;
  final String? strength;
  final String? brand;
  final List<String> imageUrl;
  final String? tabletImageUrl;
  final String? composition;
  final MedicineSubcategory? subcategory;
  final Manufacture? manufacture;
  final bool prescriptionRequired;
  final List<TabletVariant> tabletVariants;
  final DateTime? createdAt;

  const MedicineDetails({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.form,
    this.strength,
    this.brand,
    required this.imageUrl,
    this.tabletImageUrl,
    this.composition,
    this.subcategory,
    this.manufacture,
    this.prescriptionRequired = false,
    this.tabletVariants = const [],
    this.createdAt,
  });

  factory MedicineDetails.fromJson(Map<String, dynamic> json) {
    return MedicineDetails(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      form: json['form'],
      strength: json['strength'],
      brand: json['brand'],
      imageUrl: List<String>.from(json['imageUrl'] ?? []),
      tabletImageUrl: json['tabletImage']?['url'],
      composition: json['compositions']?['name'],
      subcategory: (json['subcategory'] != null && json['subcategory'] is Map)
          ? MedicineSubcategory.fromJson(json['subcategory'])
          : (json['subcategorys'] != null && json['subcategorys'] is Map
              ? MedicineSubcategory.fromJson(json['subcategorys'])
              : null),
      manufacture: (json['manufacture'] != null && json['manufacture'] is Map)
          ? Manufacture.fromJson(json['manufacture'])
          : null,
      prescriptionRequired: json['prescriptionRequired'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      tabletVariants: (json['tabletvariants'] as List? ??
              json['tabletvariant'] as List? ??
              [])
          .where((i) => i is Map<String, dynamic>)
          .map((i) => TabletVariant.fromJson(i))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        form,
        strength,
        imageUrl,
        subcategory,
        createdAt
      ];
}

class MedicineSubcategory extends Equatable {
  final String id;
  final String name;
  final String? description;

  const MedicineSubcategory(
      {required this.id, required this.name, this.description});

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
  final List<TabletVariant> tabletVariants;

  const MedicineDropdownItem({
    required this.id,
    required this.name,
    required this.price,
    required this.subcategoryId,
    this.tabletVariants = const [],
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
      tabletVariants: (json['tabletvariants'] as List? ??
              json['tabletvariant'] as List? ??
              [])
          .map((i) => TabletVariant.fromJson(i))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, name, price, subcategoryId, tabletVariants];
}

class TabletVariant extends Equatable {
  final String id;
  final String tabletId;
  final String name;
  final double price;
  final String? pricePerUnit;
  final int? stock;
  final List<String> files;

  const TabletVariant({
    required this.id,
    required this.tabletId,
    required this.name,
    required this.price,
    this.pricePerUnit,
    this.stock,
    required this.files,
  });

  factory TabletVariant.fromJson(Map<String, dynamic> json) {
    return TabletVariant(
      id: json['_id'] ?? '',
      tabletId: json['tabletId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      pricePerUnit: json['pricePerUnit']?.toString(),
      stock: json['stock'] != null ? (int.tryParse(json['stock'].toString()) ?? 0) : null,
      files: List<String>.from(json['files'] ?? json['frontImage'] ?? []),
    );
  }

  @override
  List<Object?> get props => [id, tabletId, name, price, pricePerUnit, stock, files];
}

class VariantDetail extends Equatable {
  final String id;
  final String productId;
  final String variantId;
  final double price;
  final double discountPrice;
  final String discountType;
  final int stock;
  final bool isStock;
  final String status;
  final String? pricePerUnit;

  const VariantDetail({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.price,
    required this.discountPrice,
    required this.discountType,
    required this.stock,
    required this.isStock,
    required this.status,
    this.pricePerUnit,
  });

  factory VariantDetail.fromJson(Map<String, dynamic> json) {
    return VariantDetail(
      id: json['_id'] ?? '',
      productId: json['productId'] ?? '',
      variantId: json['variantId'] ?? json['varantId'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountprice'] ?? 0).toDouble(),
      discountType: json['discountType'] ?? 'price',
      stock: json['stock'] ?? 0,
      isStock: json['isStock'] ?? true,
      status: json['status'] ?? 'active',
      pricePerUnit: json['pricePerUnit']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        variantId,
        price,
        discountPrice,
        discountType,
        stock,
        isStock,
        status,
        pricePerUnit
      ];
}
