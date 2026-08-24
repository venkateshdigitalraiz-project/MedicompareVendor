import '../repositories/medical_equipment_repository.dart';

class UpdateMedicalEquipmentUseCase {
  final MedicalEquipmentRepository repository;

  UpdateMedicalEquipmentUseCase(this.repository);

  Future<void> call(String id, Map<String, dynamic> payload) async {
    return await repository.update(id, payload);
  }
}
