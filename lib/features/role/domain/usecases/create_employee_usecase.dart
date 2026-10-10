import '../../../../core/error/failures.dart';
import '../repositories/employee_repository.dart';

class CreateEmployeeUseCase {
  final EmployeeRepository repository;

  CreateEmployeeUseCase(this.repository);

  Future<Either<Failure, void>> call(Map<String, dynamic> body) async {
    return await repository.createEmployee(body);
  }
}
