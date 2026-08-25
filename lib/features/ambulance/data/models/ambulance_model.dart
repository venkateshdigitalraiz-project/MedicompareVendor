import '../../domain/entities/ambulance_entity.dart';

class AmbulanceModel extends AmbulanceEntity {
  const AmbulanceModel({
    required super.id,
    required super.tabletId,
    required super.name,
    required super.ambulanceType,
    required super.price,
    required super.discountPrice,
    required super.status,
    required super.facilities,
    required super.files,
  });

  factory AmbulanceModel.fromJson(Map<String, dynamic> json) {
    // In case the entire response or 'data' object is passed instead of 'product'
    final Map<String, dynamic> dataObj = (json['product'] as Map<String, dynamic>?) ?? json;

    String parsedName = 'Unknown';
    String parsedAmbulanceType = 'Unknown';
    String parsedTabletId = '';
    List<String> files = [];

    if (dataObj['tablets'] is Map<String, dynamic>) {
      parsedName = dataObj['tablets']['name'] ?? 'Unknown';
      parsedAmbulanceType = dataObj['tablets']['ambulancetype'] ?? 'Unknown';
      parsedTabletId = dataObj['tablets']['_id'] ?? '';
      files = (dataObj['tablets']['files'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
    } else if (dataObj['tablets'] is List &&
        (dataObj['tablets'] as List).isNotEmpty) {
      final tList = dataObj['tablets'] as List;
      if (tList[0] is Map) {
        parsedName = tList[0]['name'] ?? 'Unknown';
        parsedAmbulanceType = tList[0]['ambulancetype'] ?? 'Unknown';
        parsedTabletId = tList[0]['_id'] ?? '';
        files = (tList[0]['files'] as List?)?.map((e) => e.toString()).toList() ??
            [];
      }
    }

    List<AmbulanceFacilityEntity> facilitiesList = [];

    List<dynamic>? rawFacilitiesList;

    // Prioritize checking inside tablets first
    if (dataObj['tablets'] is Map<String, dynamic>) {
      rawFacilitiesList = (dataObj['tablets']['facilitiesDetails'] as List?) ?? (dataObj['tablets']['facilities'] as List?);
    } else if (dataObj['tablets'] is List && (dataObj['tablets'] as List).isNotEmpty) {
      final tList = dataObj['tablets'] as List;
      if (tList[0] is Map) {
        rawFacilitiesList = (tList[0]['facilitiesDetails'] as List?) ?? (tList[0]['facilities'] as List?);
      }
    }

    // Fallback to root level if not found in tablets
    if (rawFacilitiesList == null || rawFacilitiesList.isEmpty) {
      rawFacilitiesList = (dataObj['facilitiesDetails'] as List?) ?? (dataObj['facilities'] as List?);
    }

    if (rawFacilitiesList != null) {
      facilitiesList = rawFacilitiesList.map((e) {
        if (e is Map<String, dynamic>) {
          return AmbulanceFacilityModel.fromJson(e);
        }
        return AmbulanceFacilityModel(id: e.toString(), name: 'Facility');
      }).toList();
    }

    return AmbulanceModel(
      id: dataObj['_id'] ?? '',
      tabletId: parsedTabletId,
      name: parsedName,
      ambulanceType: parsedAmbulanceType,
      price: (dataObj['price'] ?? 0).toDouble(),
      discountPrice: (dataObj['discount'] ?? dataObj['discountprice'] ?? dataObj['discountPrice'] ?? 0).toDouble(),
      status: dataObj['status'] ?? 'pending',
      facilities: facilitiesList,
      files: files,
    );
  }
}

class AmbulanceFacilityModel extends AmbulanceFacilityEntity {
  const AmbulanceFacilityModel({
    required super.id,
    required super.name,
  });

  factory AmbulanceFacilityModel.fromJson(Map<String, dynamic> json) {
    return AmbulanceFacilityModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class AmbulanceCategoryModel extends AmbulanceCategoryEntity {
  const AmbulanceCategoryModel({
    required super.id,
    required super.name,
  });

  factory AmbulanceCategoryModel.fromJson(Map<String, dynamic> json) {
    return AmbulanceCategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class AmbulanceNameOptionModel extends AmbulanceNameOptionEntity {
  const AmbulanceNameOptionModel({
    required super.id,
    required super.name,
    required super.categoryId,
  });

  factory AmbulanceNameOptionModel.fromJson(Map<String, dynamic> json) {
    return AmbulanceNameOptionModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['category'] ?? '',
    );
  }
}

class AmbulanceListModel extends AmbulanceListEntity {
  const AmbulanceListModel({
    required super.items,
    required super.pagination,
  });

  factory AmbulanceListModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> listJson = json['list'] ?? [];
    return AmbulanceListModel(
      items: listJson.map((item) => AmbulanceModel.fromJson(item)).toList(),
      pagination: AmbulancePaginationModel.fromJson(json['pagination'] ?? {}),
    );
  }
}

class AmbulancePaginationModel extends AmbulancePaginationEntity {
  const AmbulancePaginationModel({
    required super.total,
    required super.page,
    required super.limit,
    required super.totalPages,
  });

  factory AmbulancePaginationModel.fromJson(Map<String, dynamic> json) {
    return AmbulancePaginationModel(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}
