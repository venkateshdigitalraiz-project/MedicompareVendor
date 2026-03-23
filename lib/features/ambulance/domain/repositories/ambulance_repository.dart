import '../entities/ambulance_entity.dart';

abstract class AmbulanceRepository {
  Future<AmbulanceListEntity> getAmbulanceList({
    int page = 1,
    int limit = 10,
    String categoryId = '',
    String search = '',
  });

  Future<AmbulanceEntity> getAmbulanceDetails(String id);

  Future<List<AmbulanceCategoryEntity>> getAmbulanceCategories();

  Future<List<AmbulanceNameOptionEntity>> getAmbulanceNames(String query);

  Future<List<AmbulanceFacilityEntity>> getFacilitiesList();

  Future<void> createAmbulance(Map<String, dynamic> payload);

  Future<void> updateAmbulance(String id, Map<String, dynamic> payload);

  Future<void> deleteAmbulance(String id);
}
