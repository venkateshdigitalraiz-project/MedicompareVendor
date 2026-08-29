import '../repositories/lab_test_repository.dart';
import '../../data/models/lab_test_model.dart';

class GetLabTestDetailsUseCase {
  final LabTestRepository repository;

  GetLabTestDetailsUseCase(this.repository);

  Future<LabTestItem> call(String productId) async {
    return await repository.getLabTestDetails(productId);
  }
}
