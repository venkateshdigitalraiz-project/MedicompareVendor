import '../entities/medical_equipment_entity.dart';
import '../repositories/medical_equipment_repository.dart';

class GetMedicalEquipmentListUseCase {
  final MedicalEquipmentRepository repository;

  GetMedicalEquipmentListUseCase(this.repository);

  Future<MedicalEquipmentResponse> call({
    String? categoryId,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getList(
      categoryId: categoryId,
      search: search,
      page: page,
      limit: limit,
    );
  }
}
