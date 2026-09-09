import '../../domain/entities/deliveryman_entity.dart';

class DeliverymanModel extends DeliverymanEntity {
  const DeliverymanModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phone,
    required super.vehicleType,
    required super.vehicleNumber,
    required super.status,
    required super.totalDeliveries,
    super.profileImage,
    super.rating = 0.0,
    super.createdAt,
  });

  factory DeliverymanModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    Map<String, dynamic>? userMap;
    if (json['user'] is Map) {
      userMap = Map<String, dynamic>.from(json['user'] as Map);
    } else if (json['userDetails'] is Map) {
      userMap = Map<String, dynamic>.from(json['userDetails'] as Map);
    } else if (json['deliveryMan'] is Map) {
      userMap = Map<String, dynamic>.from(json['deliveryMan'] as Map);
    } else if (json['deliveryman'] is Map) {
      userMap = Map<String, dynamic>.from(json['deliveryman'] as Map);
    }

    // Name
    String fullName = json['fullName']?.toString() ??
        json['name']?.toString() ??
        userMap?['fullName']?.toString() ??
        userMap?['name']?.toString() ??
        '';
    if (fullName.isEmpty &&
        (json['firstName'] != null || json['lastName'] != null)) {
      fullName = '${json['firstName'] ?? ''} ${json['lastName'] ?? ''}'.trim();
    }
    if (fullName.isEmpty &&
        userMap != null &&
        (userMap['firstName'] != null || userMap['lastName'] != null)) {
      fullName =
          '${userMap['firstName'] ?? ''} ${userMap['lastName'] ?? ''}'.trim();
    }
    if (fullName.isEmpty) {
      fullName = json['userName']?.toString() ??
          json['username']?.toString() ??
          userMap?['username']?.toString() ??
          'Delivery Partner';
    }

    // Email
    final email =
        json['email']?.toString() ?? userMap?['email']?.toString() ?? '';

    // Phone
    final phone = json['phone']?.toString() ??
        json['mobile']?.toString() ??
        json['phoneNumber']?.toString() ??
        json['contactNumber']?.toString() ??
        userMap?['phone']?.toString() ??
        userMap?['mobile']?.toString() ??
        '';

    // Vehicle Type
    String vehicleType = json['vehicleType']?.toString() ??
        json['vehicle_type']?.toString() ??
        userMap?['vehicleType']?.toString() ??
        'Bike';
    if (vehicleType.isEmpty) vehicleType = 'Bike';

    // Vehicle Number
    String vehicleNumber = json['vehicleNumber']?.toString() ??
        json['vehicleNo']?.toString() ??
        json['vehicle_no']?.toString() ??
        userMap?['vehicleNumber']?.toString() ??
        userMap?['vehicleNo']?.toString() ??
        '';
    if (vehicleNumber.isEmpty && json['vehicleDetails'] is Map) {
      final vMap = json['vehicleDetails'] as Map;
      vehicleNumber = vMap['vehicleNumber']?.toString() ??
          vMap['vehicleNo']?.toString() ??
          '';
      if (vehicleType == 'Bike' && vMap['vehicleType'] != null) {
        vehicleType = vMap['vehicleType'].toString();
      }
    }

    // Status
    final status = json['status']?.toString() ??
        userMap?['status']?.toString() ??
        'active';

    // Total / Completed Deliveries
    int totalDeliveries = 0;
    if (json['totalDeliveries'] != null) {
      totalDeliveries = int.tryParse(json['totalDeliveries'].toString()) ?? 0;
    } else if (json['completedDeliveries'] != null) {
      totalDeliveries =
          int.tryParse(json['completedDeliveries'].toString()) ?? 0;
    } else if (json['deliveriesCount'] != null) {
      totalDeliveries = int.tryParse(json['deliveriesCount'].toString()) ?? 0;
    } else if (json['ordersCount'] != null) {
      totalDeliveries = int.tryParse(json['ordersCount'].toString()) ?? 0;
    }

    // Profile Image
    String? profileImage = json['profileImage']?.toString() ??
        json['image']?.toString() ??
        json['avatar']?.toString() ??
        userMap?['profileImage']?.toString() ??
        userMap?['image']?.toString();

    // Rating
    double rating = 0.0;
    if (json['rating'] != null) {
      rating = double.tryParse(json['rating'].toString()) ?? 0.0;
    } else if (json['avgRating'] != null) {
      rating = double.tryParse(json['avgRating'].toString()) ?? 0.0;
    }

    // Created At
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      createdAt = DateTime.tryParse(json['createdAt'].toString());
    }

    return DeliverymanModel(
      id: rawId,
      fullName: fullName,
      email: email,
      phone: phone,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      status: status,
      totalDeliveries: totalDeliveries,
      profileImage: profileImage,
      rating: rating,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'vehicleType': vehicleType,
      'vehicleNumber': vehicleNumber,
      'status': status,
      'totalDeliveries': totalDeliveries,
      'profileImage': profileImage,
      'rating': rating,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }
}

class DeliverymanPaginationModel extends DeliverymanPaginationEntity {
  const DeliverymanPaginationModel({
    super.total = 0,
    super.page = 1,
    super.limit = 10,
    super.totalPages = 1,
  });

  factory DeliverymanPaginationModel.fromJson(Map<String, dynamic> json) {
    return DeliverymanPaginationModel(
      total: int.tryParse(json['total']?.toString() ?? '') ??
          int.tryParse(json['totalDocs']?.toString() ?? '') ??
          int.tryParse(json['count']?.toString() ?? '') ??
          0,
      page: int.tryParse(json['page']?.toString() ?? '') ??
          int.tryParse(json['currentPage']?.toString() ?? '') ??
          1,
      limit: int.tryParse(json['limit']?.toString() ?? '') ??
          int.tryParse(json['perPage']?.toString() ?? '') ??
          10,
      totalPages: int.tryParse(json['totalPages']?.toString() ?? '') ??
          int.tryParse(json['pageCount']?.toString() ?? '') ??
          1,
    );
  }
}

class DeliverymanSummaryModel extends DeliverymanSummaryEntity {
  const DeliverymanSummaryModel({
    super.totalPersonnel = 0,
    super.activePartners = 0,
    super.inactivePartners = 0,
    super.completedDeliveries = 0,
  });

  factory DeliverymanSummaryModel.fromJson(Map<String, dynamic> json) {
    return DeliverymanSummaryModel(
      totalPersonnel: int.tryParse(json['totalPersonnel']?.toString() ?? '') ??
          int.tryParse(json['total']?.toString() ?? '') ??
          0,
      activePartners: int.tryParse(json['activePartners']?.toString() ?? '') ??
          int.tryParse(json['active']?.toString() ?? '') ??
          0,
      inactivePartners:
          int.tryParse(json['inactivePartners']?.toString() ?? '') ??
              int.tryParse(json['inactive']?.toString() ?? '') ??
              0,
      completedDeliveries:
          int.tryParse(json['completedDeliveries']?.toString() ?? '') ??
              int.tryParse(json['deliveries']?.toString() ?? '') ??
              0,
    );
  }
}

class DeliverymanListResponseModel extends DeliverymanListResponseEntity {
  const DeliverymanListResponseModel({
    super.list = const [],
    super.pagination = const DeliverymanPaginationModel(),
    super.summary = const DeliverymanSummaryModel(),
  });

  factory DeliverymanListResponseModel.fromJson(dynamic json) {
    if (json == null) {
      return const DeliverymanListResponseModel();
    }

    List<DeliverymanModel> items = [];
    DeliverymanPaginationModel pagination = const DeliverymanPaginationModel();
    DeliverymanSummaryModel? summary;

    if (json is List) {
      items = json
          .map((item) =>
              DeliverymanModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      pagination = DeliverymanPaginationModel(
        total: items.length,
        page: 1,
        limit: items.isEmpty ? 10 : items.length,
        totalPages: 1,
      );
    } else if (json is Map) {
      final map = Map<String, dynamic>.from(json);

      // Check for summary or stats object
      if (map['summary'] is Map) {
        summary = DeliverymanSummaryModel.fromJson(
            Map<String, dynamic>.from(map['summary'] as Map));
      } else if (map['stats'] is Map) {
        summary = DeliverymanSummaryModel.fromJson(
            Map<String, dynamic>.from(map['stats'] as Map));
      }

      // Check for items list under common keys
      dynamic listData;
      for (final key in [
        'deliveryMans',
        'deliverymen',
        'deliveryMen',
        'deliveryMan',
        'list',
        'items',
        'docs',
        'partners',
        'data'
      ]) {
        if (map[key] is List) {
          listData = map[key];
          break;
        }
      }

      if (listData is List) {
        items = listData
            .map((item) => DeliverymanModel.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList();
      }

      // Pagination
      if (map['pagination'] is Map) {
        pagination = DeliverymanPaginationModel.fromJson(
            Map<String, dynamic>.from(map['pagination'] as Map));
      } else {
        final total = int.tryParse(map['total']?.toString() ?? '') ??
            int.tryParse(map['totalDocs']?.toString() ?? '') ??
            items.length;
        final page = int.tryParse(map['page']?.toString() ?? '') ?? 1;
        final limit = int.tryParse(map['limit']?.toString() ?? '') ?? 10;
        final totalPages = (total / limit).ceil() == 0 ? 1 : (total / limit).ceil();
        pagination = DeliverymanPaginationModel(
          total: total,
          page: page,
          limit: limit,
          totalPages: totalPages,
        );
      }
    }

    // If summary wasn't provided directly in the API, compute from items
    if (summary == null) {
      int active = 0;
      int inactive = 0;
      int completed = 0;
      for (final d in items) {
        if (d.isActive) {
          active++;
        } else {
          inactive++;
        }
        completed += d.totalDeliveries;
      }
      summary = DeliverymanSummaryModel(
        totalPersonnel: pagination.total > 0 ? pagination.total : items.length,
        activePartners: active,
        inactivePartners: inactive,
        completedDeliveries: completed,
      );
    }

    return DeliverymanListResponseModel(
      list: items,
      pagination: pagination,
      summary: summary,
    );
  }
}
