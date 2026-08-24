import '../entities/medical_equipment_entity.dart';
import '../repositories/medical_equipment_repository.dart';

class GetMedicalEquipmentCategoriesUseCase {
  final MedicalEquipmentRepository repository;

  GetMedicalEquipmentCategoriesUseCase(this.repository);

  Future<List<MedicalEquipmentCategory>> call() async {
    return await repository.getCategories();
  }
}
