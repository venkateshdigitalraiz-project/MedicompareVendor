import '../../../../core/error/failures.dart';
import '../entities/employee_entity.dart';

abstract class EmployeeRepository {
  Future<Either<Failure, List<EmployeeEntity>>> getEmployeeList();
  Future<Either<Failure, void>> createEmployee(Map<String, dynamic> body);
  Future<Either<Failure, EmployeeEntity>> getEmployeeDetails(String id);
  Future<Either<Failure, void>> updateEmployee(String id, Map<String, dynamic> body);
}
