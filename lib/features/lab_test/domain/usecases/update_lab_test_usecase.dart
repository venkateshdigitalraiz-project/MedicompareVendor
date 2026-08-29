import '../repositories/lab_test_repository.dart';

class UpdateLabTestUseCase {
  final LabTestRepository repository;

  UpdateLabTestUseCase(this.repository);

  Future<void> call(String id, Map<String, dynamic> data) async {
    return await repository.updateLabTest(id, data);
  }
}
