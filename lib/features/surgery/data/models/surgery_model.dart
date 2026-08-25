import 'package:equatable/equatable.dart';

double _parsePrice(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  final parsed = double.tryParse(value.toString());
  return parsed ?? 0.0;
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value == 'true' || value == '1';
  return false;
}

class AllMixVariant extends Equatable {
  final String id;
  final String name;
  final double? price; // nullable — API can send null price
  final double? discountPrice;
  final String? discountType;

  const AllMixVariant({
    required this.id,
    required this.name,
    this.price,
    this.discountPrice,
    this.discountType,
  });

  factory AllMixVariant.fromJson(Map<String, dynamic> json) {
    return AllMixVariant(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: json['price'] == null ? 0.0 : _parsePrice(json['price']),
      discountPrice: json['discountprice'] == null
          ? null
          : _parsePrice(json['discountprice']),
      discountType: json['discountType'],
    );
  }

  @override
  List<Object?> get props => [id, name, price, discountPrice, discountType];
}

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
  final String? discountType;
  final List<SurgeryVariantDetail> variantDetails;
  final bool isVariant;
  final List<AllMixVariant> allMixVariants; // list of mix variants from API

  const SurgeryItem({
    required this.id,
    required this.price,
    required this.discountPrice,
    required this.status,
    required this.details,
    this.discountType,
    this.variantDetails = const [],
    this.isVariant = false,
    this.allMixVariants = const [],
  });

  // Returns the effective display price based on is_variant flag.
  // When isVariant=true, takes the first non-null price from allMixVariants.
  // NEVER falls back to product.price when isVariant=true.
  double get effectivePrice {
    if (isVariant) {
      for (final v in allMixVariants) {
        if (v.price != null && v.price! > 0) return v.price!;
      }
      return 0.0; // all variants have null/0 price
    }
    return price;
  }

  // When isVariant=true, takes the first valid discount from allMixVariants.
  double get effectiveDiscountPrice {
    if (isVariant) {
      for (final v in allMixVariants) {
        if (v.price != null && v.price! > 0) {
          return v.discountPrice ?? 0.0;
        }
      }
      return 0.0;
    }
    return discountPrice;
  }

  // When isVariant=true, takes the first valid discount type from allMixVariants.
  String? get effectiveDiscountType {
    if (isVariant) {
      for (final v in allMixVariants) {
        if (v.price != null && v.price! > 0) {
          return v.discountType;
        }
      }
      return null;
    }
    return discountType;
  }

  factory SurgeryItem.fromJson(Map<String, dynamic> json) {
    // is_variant lives inside the tablets sub-object
    final tabletsJson = json['tablets'] as Map<String, dynamic>? ?? {};
    final isVariant = _parseBool(tabletsJson['is_variant']);

    // allmixvariant is a List at the product root level
    final rawMixVariants = json['allmixvariant'];
    final allMixVariants = (rawMixVariants is List)
        ? rawMixVariants
            .whereType<Map<String, dynamic>>()
            .map((i) => AllMixVariant.fromJson(i))
            .toList()
        : <AllMixVariant>[];

    return SurgeryItem(
      id: json['_id'] ?? '',
      price: _parsePrice(json['price']),
      discountPrice: _parsePrice(json['discountprice']),
      discountType: json['discountType'],
      status: json['status'] ?? 'inactive',
      details: SurgeryDetails.fromJson(tabletsJson),
      variantDetails: (json['variantdetails'] as List? ??
              json['variantdetail'] as List? ??
              [])
          .where((i) => i is Map<String, dynamic>)
          .map((i) => SurgeryVariantDetail.fromJson(i as Map<String, dynamic>))
          .toList(),
      isVariant: isVariant,
      allMixVariants: allMixVariants,
    );
  }

  @override
  List<Object?> get props => [
        id,
        price,
        discountPrice,
        status,
        details,
        variantDetails,
        isVariant,
        allMixVariants
      ];
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
  final String? status;
  final List<String> files;
  final SurgerySubcategory? subcategory;

  final List<SurgeryTabletVariant> tabletVariants;

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
    this.tabletVariants = const [],
    this.status,
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
      status: json['status'],
      files: List<String>.from(json['files'] ?? []),
      subcategory: json['subcategory'] != null && json['subcategory'] is Map
          ? SurgerySubcategory.fromJson(json['subcategory'])
          : (json['subcategorys'] != null && json['subcategorys'] is Map)
              ? SurgerySubcategory.fromJson(json['subcategorys'])
              : null,
      tabletVariants: (json['tabletvariants'] as List? ??
              json['tabletvariant'] as List? ??
              [])
          .where((i) => i is Map<String, dynamic>)
          .map((i) => SurgeryTabletVariant.fromJson(i))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        complexity,
        duration,
        recoveryTime,
        procedureType,
        description,
        directionOfUse,
        precaution,
        sideEffects,
        files,
        subcategory
      ];
}

class SurgerySubcategory extends Equatable {
  final String id;
  final String name;
  final List<String> files;

  const SurgerySubcategory(
      {required this.id, required this.name, required this.files});

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

class SurgeryVariantDetail extends Equatable {
  final String id;
  final String productId;
  final String variantId;
  final double price;
  final double discountPrice;
  final String discountType;
  final int stock;
  final String status;

  const SurgeryVariantDetail({
    required this.id,
    required this.productId,
    required this.variantId,
    required this.price,
    required this.discountPrice,
    required this.discountType,
    required this.stock,
    required this.status,
  });

  factory SurgeryVariantDetail.fromJson(Map<String, dynamic> json) {
    return SurgeryVariantDetail(
      id: json['_id'] ?? '',
      productId: json['productId'] ?? '',
      variantId: json['variantId'] ?? json['varantId'] ?? '',
      price: _parsePrice(json['price']),
      discountPrice: _parsePrice(json['discountprice']),
      discountType: json['discountType'] ?? 'price',
      stock: json['stock'] ?? 0,
      status: json['status'] ?? 'inactive',
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
        status
      ];
}

class SurgeryTabletVariant extends Equatable {
  final String id;
  final String tabletId;
  final String name;
  final double price;
  final List<String> files;

  const SurgeryTabletVariant({
    required this.id,
    required this.tabletId,
    required this.name,
    required this.price,
    required this.files,
  });

  factory SurgeryTabletVariant.fromJson(Map<String, dynamic> json) {
    return SurgeryTabletVariant(
      id: json['_id'] ?? '',
      tabletId: json['tabletId'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      files: List<String>.from(json['files'] ?? []),
    );
  }

  @override
  List<Object?> get props => [id, tabletId, name, price, files];
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
  List<Object?> get props =>
      [id, name, subcategoryId, complexity, duration, description];
}
