import '../../../../core/error/failures.dart';
import '../repositories/employee_repository.dart';
import '../entities/employee_entity.dart';

class GetEmployeeDetailsUseCase {
  final EmployeeRepository repository;

  GetEmployeeDetailsUseCase(this.repository);

  Future<Either<Failure, EmployeeEntity>> call(String id) async {
    return await repository.getEmployeeDetails(id);
  }
}
