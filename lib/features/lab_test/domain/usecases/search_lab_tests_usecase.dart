import '../repositories/lab_test_repository.dart';
import '../../data/models/lab_test_model.dart';

class SearchLabTestsUseCase {
  final LabTestRepository repository;

  SearchLabTestsUseCase(this.repository);

  Future<List<LabTestDetails>> call(String query) async {
    return await repository.searchLabTests(query);
  }
}
