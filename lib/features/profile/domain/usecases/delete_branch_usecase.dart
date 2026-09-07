import '../../domain/repositories/branch_repository.dart';

class DeleteBranchUseCase {
  final BranchRepository repository;

  DeleteBranchUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteBranch(id);
  }
}
