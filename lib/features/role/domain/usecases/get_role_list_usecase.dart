import '../../../../core/error/failures.dart';
import '../entities/role_entity.dart';
import '../repositories/role_repository.dart';

class GetRoleListUseCase {
  final RoleRepository repository;

  GetRoleListUseCase(this.repository);

  Future<Either<Failure, List<RoleEntity>>> call({String? status}) {
    return repository.getRolesList(status: status);
  }
}
