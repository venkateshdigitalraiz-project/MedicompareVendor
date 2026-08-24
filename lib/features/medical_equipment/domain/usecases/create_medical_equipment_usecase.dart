import '../repositories/medical_equipment_repository.dart';

class CreateMedicalEquipmentUseCase {
  final MedicalEquipmentRepository repository;

  CreateMedicalEquipmentUseCase(this.repository);

  Future<void> call(Map<String, dynamic> payload) async {
    return await repository.create(payload);
  }
}
