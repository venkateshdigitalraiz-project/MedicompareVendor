import '../../../../core/error/failures.dart';
import '../repositories/role_repository.dart';

class UpdateRoleUseCase {
  final RoleRepository repository;

  UpdateRoleUseCase(this.repository);

  Future<Either<Failure, void>> call(
      String id, Map<String, dynamic> body) async {
    return await repository.updateRole(id, body);
  }
}
