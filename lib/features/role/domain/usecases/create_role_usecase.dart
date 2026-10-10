import '../../../../core/error/failures.dart';
import '../repositories/role_repository.dart';

class CreateRoleUseCase {
  final RoleRepository repository;

  CreateRoleUseCase(this.repository);

  Future<Either<Failure, void>> call(Map<String, dynamic> body) async {
    return await repository.createRole(body);
  }
}
