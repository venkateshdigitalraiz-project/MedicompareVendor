import '../../domain/entities/delivery_order_entity.dart';

class DeliveryOrderModel extends DeliveryOrderEntity {
  const DeliveryOrderModel({
    required super.id,
    required super.orderItemId,
    required super.orderId,
    required super.customerName,
    required super.customerPhone,
    required super.deliveryAddress,
    required super.assignedPersonnelName,
    required super.assignedPersonnelPhone,
    required super.status,
    super.orderDate,
    super.totalAmount = 0.0,
    super.itemName,
  });

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['_id']?.toString() ?? json['id']?.toString() ?? '';

    // Order Item ID / Display ID
    final orderItemId = json['orderItemId']?.toString() ??
        json['order_item_id']?.toString() ??
        json['customId']?.toString() ??
        json['displayId']?.toString() ??
        (rawId.isNotEmpty
            ? (rawId.length > 8 ? rawId.substring(rawId.length - 8).toUpperCase() : rawId)
            : 'N/A');

    final orderId = json['orderId']?.toString() ??
        json['order_id']?.toString() ??
        json['order']?['_id']?.toString() ??
        orderItemId;

    // Customer
    Map<String, dynamic>? customerMap;
    if (json['customer'] is Map) {
      customerMap = Map<String, dynamic>.from(json['customer'] as Map);
    } else if (json['user'] is Map) {
      customerMap = Map<String, dynamic>.from(json['user'] as Map);
    } else if (json['customerDetails'] is Map) {
      customerMap = Map<String, dynamic>.from(json['customerDetails'] as Map);
    } else if (json['shippingAddress'] is Map) {
      customerMap = Map<String, dynamic>.from(json['shippingAddress'] as Map);
    }

    String customerName = json['customerName']?.toString() ??
        customerMap?['name']?.toString() ??
        customerMap?['fullName']?.toString() ??
        '';
    if (customerName.isEmpty && customerMap != null) {
      customerName =
          '${customerMap['firstName'] ?? ''} ${customerMap['lastName'] ?? ''}'.trim();
    }
    if (customerName.isEmpty) customerName = 'Customer';

    final customerPhone = json['customerPhone']?.toString() ??
        customerMap?['phone']?.toString() ??
        customerMap?['mobile']?.toString() ??
        customerMap?['phoneNumber']?.toString() ??
        '';

    // Address
    String address = json['deliveryAddress']?.toString() ??
        json['address']?.toString() ??
        '';
    if (address.isEmpty && json['shippingAddress'] is Map) {
      final sMap = json['shippingAddress'] as Map;
      final parts = [
        sMap['addressLine1'] ?? sMap['address'] ?? '',
        sMap['city'] ?? '',
        sMap['pincode'] ?? sMap['postalCode'] ?? ''
      ].where((e) => e.toString().trim().isNotEmpty).toList();
      address = parts.join(', ');
    }
    if (address.isEmpty && json['addressDetails'] is Map) {
      final aMap = json['addressDetails'] as Map;
      final parts = [
        aMap['addressLine1'] ?? aMap['address'] ?? '',
        aMap['city'] ?? '',
        aMap['pincode'] ?? ''
      ].where((e) => e.toString().trim().isNotEmpty).toList();
      address = parts.join(', ');
    }
    if (address.isEmpty) address = 'Address not specified';

    // Assigned Personnel
    Map<String, dynamic>? partnerMap;
    if (json['assignedPersonnel'] is Map) {
      partnerMap = Map<String, dynamic>.from(json['assignedPersonnel'] as Map);
    } else if (json['deliveryMan'] is Map) {
      partnerMap = Map<String, dynamic>.from(json['deliveryMan'] as Map);
    } else if (json['deliveryPartner'] is Map) {
      partnerMap = Map<String, dynamic>.from(json['deliveryPartner'] as Map);
    } else if (json['deliveryman'] is Map) {
      partnerMap = Map<String, dynamic>.from(json['deliveryman'] as Map);
    }

    String assignedName = json['assignedPersonnelName']?.toString() ??
        partnerMap?['fullName']?.toString() ??
        partnerMap?['name']?.toString() ??
        '';
    if (assignedName.isEmpty && partnerMap != null) {
      assignedName =
          '${partnerMap['firstName'] ?? ''} ${partnerMap['lastName'] ?? ''}'.trim();
    }
    if (assignedName.isEmpty) {
      assignedName = partnerMap != null ? 'Assigned' : 'Unassigned';
    }

    final assignedPhone = json['assignedPersonnelPhone']?.toString() ??
        partnerMap?['phone']?.toString() ??
        partnerMap?['mobile']?.toString() ??
        '';

    // Status
    final status = json['status']?.toString() ??
        json['orderStatus']?.toString() ??
        json['deliveryStatus']?.toString() ??
        'pending';

    // Date
    DateTime? orderDate;
    if (json['orderDate'] != null) {
      orderDate = DateTime.tryParse(json['orderDate'].toString());
    } else if (json['createdAt'] != null) {
      orderDate = DateTime.tryParse(json['createdAt'].toString());
    }

    // Amount
    double amount = 0.0;
    if (json['totalAmount'] != null) {
      amount = double.tryParse(json['totalAmount'].toString()) ?? 0.0;
    } else if (json['amount'] != null) {
      amount = double.tryParse(json['amount'].toString()) ?? 0.0;
    } else if (json['price'] != null) {
      amount = double.tryParse(json['price'].toString()) ?? 0.0;
    }

    final itemName = json['itemName']?.toString() ?? json['productName']?.toString();

    return DeliveryOrderModel(
      id: rawId,
      orderItemId: orderItemId,
      orderId: orderId,
      customerName: customerName,
      customerPhone: customerPhone,
      deliveryAddress: address,
      assignedPersonnelName: assignedName,
      assignedPersonnelPhone: assignedPhone,
      status: status,
      orderDate: orderDate,
      totalAmount: amount,
      itemName: itemName,
    );
  }
}

class DeliveryOrdersSummaryModel extends DeliveryOrdersSummaryEntity {
  const DeliveryOrdersSummaryModel({
    super.totalOrders = 0,
    super.delivered = 0,
    super.inTransit = 0,
    super.assignedPending = 0,
  });

  factory DeliveryOrdersSummaryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOrdersSummaryModel(
      totalOrders: int.tryParse(json['totalOrders']?.toString() ?? '') ??
          int.tryParse(json['total']?.toString() ?? '') ??
          0,
      delivered: int.tryParse(json['delivered']?.toString() ?? '') ??
          int.tryParse(json['completed']?.toString() ?? '') ??
          0,
      inTransit: int.tryParse(json['inTransit']?.toString() ?? '') ??
          int.tryParse(json['in_transit']?.toString() ?? '') ??
          int.tryParse(json['outForDelivery']?.toString() ?? '') ??
          0,
      assignedPending:
          int.tryParse(json['assignedPending']?.toString() ?? '') ??
              int.tryParse(json['pending']?.toString() ?? '') ??
              int.tryParse(json['assigned']?.toString() ?? '') ??
              0,
    );
  }
}

class DeliveryOrdersPaginationModel extends DeliveryOrdersPaginationEntity {
  const DeliveryOrdersPaginationModel({
    super.total = 0,
    super.page = 1,
    super.limit = 10,
    super.totalPages = 1,
  });

  factory DeliveryOrdersPaginationModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOrdersPaginationModel(
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

class DeliveryOrdersResponseModel extends DeliveryOrdersResponseEntity {
  const DeliveryOrdersResponseModel({
    super.list = const [],
    super.pagination = const DeliveryOrdersPaginationModel(),
    super.summary = const DeliveryOrdersSummaryModel(),
  });

  factory DeliveryOrdersResponseModel.fromJson(dynamic json) {
    if (json == null) {
      return const DeliveryOrdersResponseModel();
    }

    List<DeliveryOrderModel> items = [];
    DeliveryOrdersPaginationModel pagination = const DeliveryOrdersPaginationModel();
    DeliveryOrdersSummaryModel? summary;

    if (json is List) {
      items = json
          .map((item) =>
              DeliveryOrderModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      pagination = DeliveryOrdersPaginationModel(
        total: items.length,
        page: 1,
        limit: items.isEmpty ? 10 : items.length,
        totalPages: 1,
      );
    } else if (json is Map) {
      final map = Map<String, dynamic>.from(json);

      if (map['summary'] is Map) {
        summary = DeliveryOrdersSummaryModel.fromJson(
            Map<String, dynamic>.from(map['summary'] as Map));
      } else if (map['stats'] is Map) {
        summary = DeliveryOrdersSummaryModel.fromJson(
            Map<String, dynamic>.from(map['stats'] as Map));
      }

      dynamic listData;
      for (final key in [
        'orders',
        'deliveryOrders',
        'allOrders',
        'list',
        'items',
        'docs',
        'data'
      ]) {
        if (map[key] is List) {
          listData = map[key];
          break;
        }
      }

      if (listData is List) {
        items = listData
            .map((item) => DeliveryOrderModel.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList();
      }

      if (map['pagination'] is Map) {
        pagination = DeliveryOrdersPaginationModel.fromJson(
            Map<String, dynamic>.from(map['pagination'] as Map));
      } else {
        final total = int.tryParse(map['total']?.toString() ?? '') ??
            int.tryParse(map['totalDocs']?.toString() ?? '') ??
            items.length;
        final page = int.tryParse(map['page']?.toString() ?? '') ?? 1;
        final limit = int.tryParse(map['limit']?.toString() ?? '') ?? 10;
        final totalPages = (total / limit).ceil() == 0 ? 1 : (total / limit).ceil();
        pagination = DeliveryOrdersPaginationModel(
          total: total,
          page: page,
          limit: limit,
          totalPages: totalPages,
        );
      }
    }

    if (summary == null) {
      int delivered = 0;
      int inTransit = 0;
      int assignedPending = 0;

      for (final o in items) {
        final st = o.status.toLowerCase().replaceAll('-', '_');
        if (st == 'delivered') {
          delivered++;
        } else if (st == 'in_transit' || st == 'out_for_delivery') {
          inTransit++;
        } else if (st == 'pending' || st == 'assigned') {
          assignedPending++;
        }
      }

      summary = DeliveryOrdersSummaryModel(
        totalOrders: pagination.total > 0 ? pagination.total : items.length,
        delivered: delivered,
        inTransit: inTransit,
        assignedPending: assignedPending,
      );
    }

    return DeliveryOrdersResponseModel(
      list: items,
      pagination: pagination,
      summary: summary,
    );
  }
}
