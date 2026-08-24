import '../repositories/medical_equipment_repository.dart';

class DeleteMedicalEquipmentUseCase {
  final MedicalEquipmentRepository repository;

  DeleteMedicalEquipmentUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.delete(id);
  }
}
