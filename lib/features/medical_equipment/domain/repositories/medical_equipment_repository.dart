import '../entities/medical_equipment_entity.dart';

abstract class MedicalEquipmentRepository {
  Future<List<MedicalEquipmentCategory>> getCategories();
  Future<MedicalEquipmentResponse> getList({
    String? categoryId,
    String? search,
    int page = 1,
    int limit = 10,
  });
  Future<MedicalEquipmentItem> getDetails(String id);
  Future<List<MedicalEquipmentDropdownItem>> searchTablets(String query);
  Future<void> create(Map<String, dynamic> payload);
  Future<void> update(String id, Map<String, dynamic> payload);
  Future<void> delete(String id);
}
