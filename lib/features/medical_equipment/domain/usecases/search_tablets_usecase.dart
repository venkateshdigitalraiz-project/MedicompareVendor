import '../entities/medical_equipment_entity.dart';
import '../repositories/medical_equipment_repository.dart';

class SearchTabletsUseCase {
  final MedicalEquipmentRepository repository;

  SearchTabletsUseCase(this.repository);

  Future<List<MedicalEquipmentDropdownItem>> call(String query) async {
    return await repository.searchTablets(query);
  }
}
