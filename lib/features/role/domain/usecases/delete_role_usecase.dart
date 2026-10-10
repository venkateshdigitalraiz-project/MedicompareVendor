import '../../../../core/error/failures.dart';
import '../repositories/role_repository.dart';

class DeleteRoleUseCase {
  final RoleRepository repository;

  DeleteRoleUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteRole(id);
  }
}
