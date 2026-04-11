import 'package:equatable/equatable.dart';
import 'lab_test_model.dart';

class LabTestPackageItem extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double price;
  final double discountPrice;
  final String status;
  final List<String> files;
  final List<String> products;
  final List<LabTestDetails> tabletsDetails;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const LabTestPackageItem({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.discountPrice,
    required this.status,
    required this.files,
    required this.products,
    required this.tabletsDetails,
    this.createdAt,
    this.updatedAt,
  });

  factory LabTestPackageItem.fromJson(Map<String, dynamic> json) {
    return LabTestPackageItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: (json['discountprice'] ?? 0).toDouble(),
      status: json['status'] ?? 'inactive',
      files: (json['files'] != null && (json['files'] as List).isNotEmpty)
          ? List<String>.from(json['files'])
          : List<String>.from(json['imageUrl'] ?? []),
      products: List<String>.from(json['products'] ?? []),
      tabletsDetails: (json['tabletsdetails'] as List? ?? [])
          .map((i) => LabTestDetails.fromJson(i))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        discountPrice,
        status,
        files,
        products,
        tabletsDetails,
        createdAt,
        updatedAt
      ];
}

class LabTestPackageResponse extends Equatable {
  final List<LabTestPackageItem> list;
  final LabTestPagination pagination;

  const LabTestPackageResponse({required this.list, required this.pagination});

  factory LabTestPackageResponse.fromJson(Map<String, dynamic> json) {
    return LabTestPackageResponse(
      list: (json['list'] as List? ?? [])
          .map((i) => LabTestPackageItem.fromJson(i))
          .toList(),
      pagination: LabTestPagination.fromJson(json['pagination'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [list, pagination];

  LabTestPackageResponse copyWith({
    List<LabTestPackageItem>? list,
    LabTestPagination? pagination,
  }) {
    return LabTestPackageResponse(
      list: list ?? this.list,
      pagination: pagination ?? this.pagination,
    );
  }
}
