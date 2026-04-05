class BranchListResponse {
  final bool success;
  final String message;
  final BranchData data;

  BranchListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BranchListResponse.fromJson(Map<String, dynamic> json) {
    return BranchListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: BranchData.fromJson(json['data'] ?? {}),
    );
  }
}

class BranchData {
  final List<Branch> list;
  final Pagination pagination;

  BranchData({
    required this.list,
    required this.pagination,
  });

  factory BranchData.fromJson(Map<String, dynamic> json) {
    return BranchData(
      list: (json['list'] as List? ?? [])
          .map((item) => Branch.fromJson(item))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class Branch {
  final String id;
  final String name;
  final String email;
  final String mobile;
  final String type;
  final String address;
  final String state;
  final String vendorId;
  final String roleId;
  final String status;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  Branch({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.type,
    required this.address,
    required this.state,
    required this.vendorId,
    required this.roleId,
    required this.status,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      type: json['type'] ?? '',
      address: json['address'] ?? '',
      state: json['state'] ?? '',
      vendorId: json['vendorId'] ?? '',
      roleId: json['roleId'] ?? '',
      status: json['status'] ?? '',
      images: List<String>.from(json['image'] ?? []),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final int limit;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalRecords: json['totalRecords'] ?? 0,
      limit: json['limit'] ?? 10,
    );
  }
}

class BranchDetailsResponse {
  final bool success;
  final String message;
  final Branch branch;

  BranchDetailsResponse({
    required this.success,
    required this.message,
    required this.branch,
  });

  factory BranchDetailsResponse.fromJson(Map<String, dynamic> json) {
    return BranchDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      branch: Branch.fromJson(json['data']?['list'] ?? {}),
    );
  }
}
