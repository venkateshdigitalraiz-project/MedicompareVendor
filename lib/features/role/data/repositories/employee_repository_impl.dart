import '../../../../core/error/failures.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_datasource.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource remoteDataSource;

  EmployeeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<EmployeeEntity>>> getEmployeeList() async {
    try {
      final result = await remoteDataSource.getEmployeeList();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createEmployee(Map<String, dynamic> body) async {
    try {
      await remoteDataSource.createEmployee(body);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EmployeeEntity>> getEmployeeDetails(String id) async {
    try {
      final result = await remoteDataSource.getEmployeeDetails(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateEmployee(String id, Map<String, dynamic> body) async {
    try {
      await remoteDataSource.updateEmployee(id, body);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
