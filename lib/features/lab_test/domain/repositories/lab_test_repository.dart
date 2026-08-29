import '../../data/models/lab_test_model.dart';

abstract class LabTestRepository {
  Future<LabTestItem> getLabTestDetails(String productId);
  Future<void> updateLabTest(String id, Map<String, dynamic> data);
  Future<List<LabTestDetails>> searchLabTests(String query);
}
