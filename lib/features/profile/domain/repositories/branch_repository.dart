import 'dart:io';
import '../../data/models/branch_model.dart';

abstract class BranchRepository {
  Future<BranchListResponse> getBranchList({
    int page = 1,
    int limit = 100,
    String search = '',
  });
  Future<BranchDetailsResponse> getBranchDetails(String id);
  Future<void> createBranch(Map<String, dynamic> data, {File? image});
  Future<void> updateBranch(String id, Map<String, dynamic> data, {File? image});
}
