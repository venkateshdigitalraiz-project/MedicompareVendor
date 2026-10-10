import '../../../../core/error/failures.dart';
import '../repositories/employee_repository.dart';

class UpdateEmployeeUseCase {
  final EmployeeRepository repository;

  UpdateEmployeeUseCase(this.repository);

  Future<Either<Failure, void>> call(
      String id, Map<String, dynamic> body) async {
    return await repository.updateEmployee(id, body);
  }
}
