import '../entities/medical_equipment_entity.dart';
import '../repositories/medical_equipment_repository.dart';

class GetMedicalEquipmentDetailsUseCase {
  final MedicalEquipmentRepository repository;

  GetMedicalEquipmentDetailsUseCase(this.repository);

  Future<MedicalEquipmentItem> call(String id) async {
    return await repository.getDetails(id);
  }
}
