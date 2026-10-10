import '../../../../core/error/failures.dart';
import '../entities/employee_entity.dart';
import '../repositories/employee_repository.dart';

class GetEmployeeListUseCase {
  final EmployeeRepository repository;

  GetEmployeeListUseCase(this.repository);

  Future<Either<Failure, List<EmployeeEntity>>> call() {
    return repository.getEmployeeList();
  }
}
