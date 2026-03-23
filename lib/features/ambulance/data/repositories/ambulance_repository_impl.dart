import '../../domain/entities/ambulance_entity.dart';
import '../../domain/repositories/ambulance_repository.dart';
import '../datasources/ambulance_remote_data_source.dart';

class AmbulanceRepositoryImpl implements AmbulanceRepository {
  final AmbulanceRemoteDataSource remoteDataSource;

  AmbulanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AmbulanceListEntity> getAmbulanceList({
    int page = 1,
    int limit = 10,
    String categoryId = '',
    String search = '',
  }) async {
    return await remoteDataSource.getAmbulanceList(
      page: page,
      limit: limit,
      categoryId: categoryId,
      search: search,
    );
  }

  @override
  Future<AmbulanceEntity> getAmbulanceDetails(String id) async {
    return await remoteDataSource.getAmbulanceDetails(id);
  }

  @override
  Future<List<AmbulanceCategoryEntity>> getAmbulanceCategories() async {
    return await remoteDataSource.getAmbulanceCategories();
  }

  @override
  Future<List<AmbulanceNameOptionEntity>> getAmbulanceNames(String query) async {
    return await remoteDataSource.getAmbulanceNames(query);
  }

  @override
  Future<List<AmbulanceFacilityEntity>> getFacilitiesList() async {
    return await remoteDataSource.getFacilitiesList();
  }

  @override
  Future<void> createAmbulance(Map<String, dynamic> payload) async {
    await remoteDataSource.createAmbulance(payload);
  }

  @override
  Future<void> updateAmbulance(String id, Map<String, dynamic> payload) async {
    await remoteDataSource.updateAmbulance(id, payload);
  }

  @override
  Future<void> deleteAmbulance(String id) async {
    await remoteDataSource.deleteAmbulance(id);
  }
}
