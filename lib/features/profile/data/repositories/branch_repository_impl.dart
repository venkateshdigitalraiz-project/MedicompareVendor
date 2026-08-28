import 'dart:io';
import '../../domain/repositories/branch_repository.dart';
import '../data_sources/branch_service.dart';
import '../models/branch_model.dart';

class BranchRepositoryImpl implements BranchRepository {
  final BranchService branchService;

  BranchRepositoryImpl({required this.branchService});

  @override
  Future<BranchListResponse> getBranchList({
    int page = 1,
    int limit = 100,
    String search = '',
  }) async {
    return await branchService.getBranchList(
      page: page,
      limit: limit,
      search: search,
    );
  }

  @override
  Future<BranchDetailsResponse> getBranchDetails(String id) async {
    return await branchService.getBranchDetails(id);
  }

  @override
  Future<void> createBranch(Map<String, dynamic> data, {File? image}) async {
    return await branchService.createBranch(data, image: image);
  }

  @override
  Future<void> updateBranch(String id, Map<String, dynamic> data, {File? image}) async {
    return await branchService.updateBranch(id, data, image: image);
  }
}
