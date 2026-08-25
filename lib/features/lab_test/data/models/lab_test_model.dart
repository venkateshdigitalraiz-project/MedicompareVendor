import 'package:equatable/equatable.dart';

class LabTestCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String slug;
  final String status;
  final List<String> files;
  final String? categoryId;
  final int? priority;
  final bool? itsrisk;
  final double? gst;
  final String? gstType;
  final double? igst;
  final double? cgst;
  final double? sgst;
  final String? commission;
  final String? createdAt;
  final String? updatedAt;

  const LabTestCategory({
    required this.id,
    required this.name,
    this.description,
    required this.slug,
    required this.status,
    required this.files,
    this.categoryId,
    this.priority,
    this.itsrisk,
    this.gst,
    this.gstType,
    this.igst,
    this.cgst,
    this.sgst,
    this.commission,
    this.createdAt,
    this.updatedAt,
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
      categoryId: json['categoryId']?.toString(),
      priority: json['priority'] is int ? json['priority'] : int.tryParse(json['priority']?.toString() ?? ''),
      itsrisk: json['itsrisk'] is bool ? json['itsrisk'] : (json['itsrisk']?.toString() == 'true'),
      gst: (json['gst'] ?? 0).toDouble(),
      gstType: json['gstType']?.toString(),
      igst: (json['igst'] ?? 0).toDouble(),
      cgst: (json['cgst'] ?? 0).toDouble(),
      sgst: (json['sgst'] ?? 0).toDouble(),
      commission: json['commission']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        slug,
        status,
        files,
        categoryId,
        priority,
        itsrisk,
        gst,
        gstType,
        igst,
        cgst,
        sgst,
        commission,
        createdAt,
        updatedAt,
      ];
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
  final List<LabTestParameter> detailedParameters;
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
    required this.detailedParameters,
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
      parameters: (json['parameters'] as List? ?? [])
          .where((i) => i is Map<String, dynamic>)
          .map((i) => LabTestParameter.fromJson(i as Map<String, dynamic>))
          .toList(),
      detailedParameters: (json['parameterss'] as List? ?? [])
          .where((i) => i is Map<String, dynamic>)
          .map((i) => LabTestParameter.fromJson(i as Map<String, dynamic>))
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
        detailedParameters,
        subcategory
      ];
}

class LabTestParameter extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? normalRange;
  final String? childnormalRange;
  final String? adultMaleRange;
  final String? adultFemaleRange;
  final String? units;
  final String? status;

  const LabTestParameter({
    required this.id,
    required this.name,
    this.description,
    this.normalRange,
    this.childnormalRange,
    this.adultMaleRange,
    this.adultFemaleRange,
    this.units,
    this.status,
  });

  factory LabTestParameter.fromJson(Map<String, dynamic> json) {
    return LabTestParameter(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      normalRange: json['normalRange'],
      childnormalRange: json['childnormalRange'],
      adultMaleRange: json['AdultMaleRange'],
      adultFemaleRange: json['AdultFemaleRange'],
      units: json['units'],
      status: json['status'],
    );
  }

  @override
  List<Object?> get props => [id, name, description, normalRange, childnormalRange, adultMaleRange, adultFemaleRange, units, status];
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
