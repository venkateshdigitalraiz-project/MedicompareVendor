import '../../domain/repositories/lab_test_repository.dart';
import '../data_sources/lab_test_remote_data_source.dart';
import '../models/lab_test_model.dart';

class LabTestRepositoryImpl implements LabTestRepository {
  final LabTestRemoteDataSource remoteDataSource;

  LabTestRepositoryImpl(this.remoteDataSource);

  @override
  Future<LabTestItem> getLabTestDetails(String productId) async {
    return await remoteDataSource.getLabTestDetails(productId);
  }

  @override
  Future<void> updateLabTest(String id, Map<String, dynamic> data) async {
    return await remoteDataSource.updateLabTest(id, data);
  }

  @override
  Future<List<LabTestDetails>> searchLabTests(String query) async {
    return await remoteDataSource.searchLabTests(query);
  }
}
