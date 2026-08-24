class MedicalEquipmentCategory {
  final String id;
  final String name;
  final String? slug;

  const MedicalEquipmentCategory({
    required this.id,
    required this.name,
    this.slug,
  });
}

class MedicalEquipmentItem {
  final String id;
  final double price;
  final double discountPrice;
  final String status;
  final double? fixedDeposit;
  final double? returnCharge;
  final double? serviceCharges;
  final double? interest;
  final double? perDayRent;
  final MedicalEquipmentDetails details;

  const MedicalEquipmentItem({
    required this.id,
    required this.price,
    required this.discountPrice,
    required this.status,
    this.fixedDeposit,
    this.returnCharge,
    this.serviceCharges,
    this.interest,
    this.perDayRent,
    required this.details,
  });
}

class MedicalEquipmentDetails {
  final String id;
  final String name;
  final String description;
  final String? machineType;
  final String? model;
  final String? condition;
  final List<String> files;
  final MedicalEquipmentSubcategory? subcategory;

  const MedicalEquipmentDetails({
    required this.id,
    required this.name,
    required this.description,
    this.machineType,
    this.model,
    this.condition,
    required this.files,
    this.subcategory,
  });
}

class MedicalEquipmentSubcategory {
  final String id;
  final String name;
  final String? description;

  const MedicalEquipmentSubcategory({
    required this.id,
    required this.name,
    this.description,
  });
}

class MedicalEquipmentResponse {
  final List<MedicalEquipmentItem> list;
  final MedicalEquipmentPagination pagination;

  const MedicalEquipmentResponse({
    required this.list,
    required this.pagination,
  });
}

class MedicalEquipmentPagination {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const MedicalEquipmentPagination({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}

class MedicalEquipmentDropdownItem {
  final String id;
  final String name;
  final String? description;
  final String? model;
  final String? brand;
  final MedicalEquipmentSubcategory? subcategory;

  const MedicalEquipmentDropdownItem({
    required this.id,
    required this.name,
    this.description,
    this.model,
    this.brand,
    this.subcategory,
  });
}
