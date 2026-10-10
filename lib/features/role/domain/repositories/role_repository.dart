import '../../../../core/error/failures.dart';
import '../entities/role_entity.dart';

import '../entities/medical_category_entity.dart';

abstract class RoleRepository {
  Future<Either<Failure, List<RoleEntity>>> getRolesList({String? status});
  Future<Either<Failure, List<MedicalCategoryEntity>>> getMedicalCategories();
  Future<Either<Failure, void>> createRole(Map<String, dynamic> body);
  Future<Either<Failure, void>> updateRole(String id, Map<String, dynamic> body);
  Future<Either<Failure, void>> deleteRole(String id);
}
