import '../../../../core/error/failures.dart';
import '../../domain/entities/role_entity.dart';
import '../../domain/entities/medical_category_entity.dart';
import '../../domain/repositories/role_repository.dart';
import '../datasources/role_remote_datasource.dart';

class RoleRepositoryImpl implements RoleRepository {
  final RoleRemoteDataSource remoteDataSource;

  RoleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RoleEntity>>> getRolesList({String? status}) async {
    try {
      final result = await remoteDataSource.getRolesList(status: status);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MedicalCategoryEntity>>> getMedicalCategories() async {
    try {
      final result = await remoteDataSource.getMedicalCategories();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createRole(Map<String, dynamic> body) async {
    try {
      await remoteDataSource.createRole(body);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateRole(String id, Map<String, dynamic> body) async {
    try {
      await remoteDataSource.updateRole(id, body);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRole(String id) async {
    try {
      await remoteDataSource.deleteRole(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
