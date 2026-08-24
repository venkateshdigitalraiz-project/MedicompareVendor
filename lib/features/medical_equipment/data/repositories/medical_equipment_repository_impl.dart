import '../../domain/entities/medical_equipment_entity.dart';
import '../../domain/repositories/medical_equipment_repository.dart';
import '../data_sources/medical_equipment_service.dart';

class MedicalEquipmentRepositoryImpl implements MedicalEquipmentRepository {
  final MedicalEquipmentService remoteDataSource;

  MedicalEquipmentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<MedicalEquipmentCategory>> getCategories() async {
    return await remoteDataSource.getCategories();
  }

  @override
  Future<MedicalEquipmentResponse> getList({
    String? categoryId,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    return await remoteDataSource.getList(
      categoryId: categoryId,
      search: search,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<MedicalEquipmentItem> getDetails(String id) async {
    return await remoteDataSource.getDetails(id);
  }

  @override
  Future<List<MedicalEquipmentDropdownItem>> searchTablets(String query) async {
    return await remoteDataSource.searchTablets(query);
  }

  @override
  Future<void> create(Map<String, dynamic> payload) async {
    await remoteDataSource.create(payload);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> payload) async {
    await remoteDataSource.update(id, payload);
  }

  @override
  Future<void> delete(String id) async {
    await remoteDataSource.delete(id);
  }
}
