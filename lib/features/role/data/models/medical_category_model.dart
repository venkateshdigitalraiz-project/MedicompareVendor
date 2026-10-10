import '../../domain/entities/medical_category_entity.dart';

class MedicalCategoryModel extends MedicalCategoryEntity {
  const MedicalCategoryModel({
    required super.id,
    required super.name,
  });

  factory MedicalCategoryModel.fromJson(Map<String, dynamic> json) {
    return MedicalCategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
