import '../../domain/entities/appointment_entity.dart';

class AppointmentsListModel extends AppointmentsListEntity {
  const AppointmentsListModel({
    required super.appointmentItems,
    required super.pagination,
  });

  factory AppointmentsListModel.fromJson(Map<String, dynamic> json) {
    final listKey = json['orders'] != null ? 'orders' : 'docs';
    return AppointmentsListModel(
      appointmentItems: json[listKey] != null && json[listKey] is List
          ? List<AppointmentItemModel>.from(
              (json[listKey] as List).map((x) => AppointmentItemModel.fromJson(x)))
          : [],
      pagination: AppointmentPaginationModel.fromJson(json),
    );
  }
}

class AppointmentPaginationModel extends AppointmentPaginationEntity {
  const AppointmentPaginationModel({
    required super.total,
    required super.page,
    required super.limit,
    required super.totalPages,
  });

  factory AppointmentPaginationModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> pageData = json['pagination'] != null && json['pagination'] is Map 
        ? json['pagination'] as Map<String, dynamic> 
        : json;
    
    final int total = pageData['total'] ?? pageData['totalDocs'] ?? 0;
    final int limit = pageData['limit'] ?? 10;
    int totalPages = pageData['totalPages'] ?? 1;

    // Calculate totalPages if the API omits it but provides total and limit
    if (pageData['totalPages'] == null && total > 0 && limit > 0) {
      totalPages = (total / limit).ceil();
    }

    return AppointmentPaginationModel(
      total: total,
      page: pageData['page'] ?? 1,
      limit: limit,
      totalPages: totalPages,
    );
  }
}

class AppointmentItemModel extends AppointmentItemEntity {
  const AppointmentItemModel({
    required super.id,
    required super.orderItemId,
    required super.orderStatus,
    required super.type,
    required super.quantity,
    required super.totalPrice,
    required super.createdAt,
    required super.productDetails,
    super.userDetails,
    super.appointmentDate,
  });

  factory AppointmentItemModel.fromJson(Map<String, dynamic> json) {
    DateTime? getAppointmentDate() {
      if (json['selectedDate'] != null) {
        return DateTime.tryParse(json['selectedDate'].toString());
      }
      final orderDetails = json['orderDetails'];
      if (orderDetails != null && orderDetails is Map) {
        final startDate = orderDetails['startDate'] ?? orderDetails['startdate'];
        if (startDate != null) {
          return DateTime.tryParse(startDate.toString());
        }
      }
      return null;
    }

    return AppointmentItemModel(
      id: json['_id']?.toString() ?? '',
      orderItemId: json['orderId']?.toString() ?? json['orderItemId']?.toString() ?? json['_id']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? 'pending',
      type: (() {
        final billing = json['billingSummary'] ?? json['billingsummary'];
        if (billing != null && billing is Map) {
            if (billing['vendorBilling'] != null && billing['vendorBilling'] is List && (billing['vendorBilling'] as List).isNotEmpty) {
                final vb = (billing['vendorBilling'] as List).first;
                if (vb is Map && vb['servicefixedTypes'] != null) {
                    return vb['servicefixedTypes'].toString();
                }
            }
        }
        return json['orderType']?.toString() ?? json['bookingType']?.toString() ?? json['type']?.toString() ?? '';
      })(),
      quantity: (() {
        final isGroup = json['isGroup'] == true || json['isGroup'] == 'true';
        if (isGroup) {
          if (json['groupDetails'] != null && json['groupDetails'] is List) {
            return (json['groupDetails'] as List).length;
          }
          return 0;
        } else {
          if (json['items'] != null && json['items'] is List) {
            return (json['items'] as List).length;
          }
          return 0;
        }
      })(),
      totalPrice: (() {
        if (json['totalPrice'] != null) return double.tryParse(json['totalPrice'].toString()) ?? 0.0;
        if (json['totalprice'] != null) return double.tryParse(json['totalprice'].toString()) ?? 0.0;
        if (json['total'] != null && double.tryParse(json['total'].toString()) != null && double.tryParse(json['total'].toString())! > 0) {
            return double.tryParse(json['total'].toString()) ?? 0.0;
        }
        final billing = json['billingSummary'] ?? json['billingsummary'];
        if (billing != null && billing is Map) {
            if (billing['finalAmount'] != null) return double.tryParse(billing['finalAmount'].toString()) ?? 0.0;
            if (billing['subtotal'] != null) return double.tryParse(billing['subtotal'].toString()) ?? 0.0;
            if (billing['unitPrice'] != null) return double.tryParse(billing['unitPrice'].toString()) ?? 0.0;
        }
        return 0.0;
      })(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      productDetails: (() {
        if (json['items'] != null && json['items'] is List && (json['items'] as List).isNotEmpty) {
           for (var item in (json['items'] as List)) {
               if (item is Map && item['productSnapshot'] != null && item['productSnapshot'] is Map) {
                   return AppointmentProductDetailsModel.fromJson(item['productSnapshot'] as Map<String, dynamic>);
               }
           }
        }
        if (json['groups'] != null && json['groups'] is List && (json['groups'] as List).isNotEmpty) {
           for (var group in (json['groups'] as List)) {
               if (group is Map && group['items'] != null && group['items'] is List && (group['items'] as List).isNotEmpty) {
                   for (var item in (group['items'] as List)) {
                       if (item is Map && item['productSnapshot'] != null && item['productSnapshot'] is Map) {
                           return AppointmentProductDetailsModel.fromJson(item['productSnapshot'] as Map<String, dynamic>);
                       }
                   }
               }
           }
        }
        if (json['groupDetails'] != null && json['groupDetails'] is List && (json['groupDetails'] as List).isNotEmpty) {
           for (var groupItem in (json['groupDetails'] as List)) {
               if (groupItem is Map) {
                   if (groupItem['productSnapshot'] != null && groupItem['productSnapshot'] is Map) {
                       return AppointmentProductDetailsModel.fromJson(groupItem['productSnapshot'] as Map<String, dynamic>);
                   }
                   if (groupItem['items'] != null && groupItem['items'] is List && (groupItem['items'] as List).isNotEmpty) {
                       for (var item in (groupItem['items'] as List)) {
                           if (item is Map && item['productSnapshot'] != null && item['productSnapshot'] is Map) {
                               return AppointmentProductDetailsModel.fromJson(item['productSnapshot'] as Map<String, dynamic>);
                           }
                       }
                   }
               }
           }
        }
        if (json['productSnapshot'] != null && json['productSnapshot'] is Map) {
           return AppointmentProductDetailsModel.fromJson(json['productSnapshot'] as Map<String, dynamic>);
        }
        if (json['productDetails'] != null && json['productDetails'] is Map) {
          return AppointmentProductDetailsModel.fromJson(json['productDetails'] as Map<String, dynamic>);
        }
        return const AppointmentProductDetailsModel(name: '', files: []);
      })(),
      userDetails: json['userDetails'] != null && json['userDetails'] is Map
          ? AppointmentUserDetailsModel.fromJson(json['userDetails'] as Map<String, dynamic>)
          : null,
      appointmentDate: getAppointmentDate(),
    );
  }
}

class AppointmentProductDetailsModel extends AppointmentProductDetailsEntity {
  const AppointmentProductDetailsModel({
    required super.name,
    required super.files,
  });

  factory AppointmentProductDetailsModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedFiles = [];
    if (json['files'] != null) {
      if (json['files'] is List) {
        parsedFiles.addAll((json['files'] as List).map((e) => e.toString()));
      } else if (json['files'] is String) {
        parsedFiles.add(json['files'].toString());
      }
    }
    if (json['imageUrl'] != null) {
      if (json['imageUrl'] is List) {
        parsedFiles.addAll((json['imageUrl'] as List).map((e) => e.toString()));
      } else if (json['imageUrl'] is String) {
        parsedFiles.add(json['imageUrl'].toString());
      }
    }
    
    // Check tabletdetails for name if name is missing at root
    String parsedName = json['name']?.toString() ?? '';
    if (parsedName.isEmpty && json['tabletdetails'] != null && json['tabletdetails'] is Map) {
      parsedName = json['tabletdetails']['name']?.toString() ?? '';
    }
    if (parsedName.isEmpty && json['tabletDetails'] != null && json['tabletDetails'] is Map) {
      parsedName = json['tabletDetails']['name']?.toString() ?? '';
    }

    return AppointmentProductDetailsModel(
      name: parsedName,
      files: parsedFiles,
    );
  }
}

class AppointmentUserDetailsModel extends AppointmentUserDetailsEntity {
  const AppointmentUserDetailsModel({
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phone,
  });

  factory AppointmentUserDetailsModel.fromJson(Map<String, dynamic> json) {
    String firstName = json['first_name']?.toString() ?? json['firstName']?.toString() ?? '';
    if (firstName.isEmpty) {
        firstName = json['name']?.toString() ?? '';
    }
    return AppointmentUserDetailsModel(
      firstName: firstName,
      lastName: json['last_name']?.toString() ?? json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString() ?? json['mobile']?.toString() ?? '',
    );
  }
}
