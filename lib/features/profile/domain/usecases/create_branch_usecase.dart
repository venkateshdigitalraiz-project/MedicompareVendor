import 'dart:io';
import '../repositories/branch_repository.dart';

class CreateBranchUseCase {
  final BranchRepository repository;

  CreateBranchUseCase(this.repository);

  Future<void> call(Map<String, dynamic> data, {File? image}) async {
    return await repository.createBranch(data, image: image);
  }
}
