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
    super.branchName,
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
        if (json['servicefixedTypes'] != null && json['servicefixedTypes'].toString().isNotEmpty) {
            return json['servicefixedTypes'].toString();
        }
        if (json['orderDetails'] != null && json['orderDetails'] is Map && json['orderDetails']['servicefixedTypes'] != null) {
            return json['orderDetails']['servicefixedTypes'].toString();
        }
        final billing = json['billingSummary'] ?? json['billingsummary'];
        if (billing != null && billing is Map) {
            if (billing['vendorBilling'] != null && billing['vendorBilling'] is List && (billing['vendorBilling'] as List).isNotEmpty) {
                final vb = (billing['vendorBilling'] as List).first;
                if (vb is Map && vb['servicefixedTypes'] != null && vb['servicefixedTypes'].toString().isNotEmpty) {
                    return vb['servicefixedTypes'].toString();
                }
            }
        }
        return json['orderType']?.toString() ?? json['bookingType']?.toString() ?? json['type']?.toString() ?? '';
      })(),
      quantity: (() {
        if (json['groupDetails'] != null && json['groupDetails'] is List) {
          final list = json['groupDetails'] as List;
          if (list.isNotEmpty) {
            int totalQty = 0;
            for (var item in list) {
              if (item is Map) {
                if (item['items'] != null && item['items'] is List) {
                  for (var sub in (item['items'] as List)) {
                    if (sub is Map) {
                      final subQty = sub['qty'] ?? sub['quantity'];
                      if (subQty != null && int.tryParse(subQty.toString()) != null) {
                        totalQty += int.tryParse(subQty.toString())!;
                      } else {
                        totalQty += 1;
                      }
                    } else {
                      totalQty += 1;
                    }
                  }
                } else {
                  final rawQty = item['qty'] ?? item['quantity'];
                  if (rawQty != null && int.tryParse(rawQty.toString()) != null) {
                    totalQty += int.tryParse(rawQty.toString())!;
                  } else {
                    totalQty += 1;
                  }
                }
              } else {
                totalQty += 1;
              }
            }
            return totalQty;
          }
        }

        if (json['groups'] != null && json['groups'] is List) {
          final list = json['groups'] as List;
          if (list.isNotEmpty) {
            int totalQty = 0;
            for (var item in list) {
              if (item is Map) {
                if (item['items'] != null && item['items'] is List) {
                  for (var sub in (item['items'] as List)) {
                    if (sub is Map) {
                      final subQty = sub['qty'] ?? sub['quantity'];
                      if (subQty != null && int.tryParse(subQty.toString()) != null) {
                        totalQty += int.tryParse(subQty.toString())!;
                      } else {
                        totalQty += 1;
                      }
                    } else {
                      totalQty += 1;
                    }
                  }
                } else {
                  final rawQty = item['qty'] ?? item['quantity'];
                  if (rawQty != null && int.tryParse(rawQty.toString()) != null) {
                    totalQty += int.tryParse(rawQty.toString())!;
                  } else {
                    totalQty += 1;
                  }
                }
              } else {
                totalQty += 1;
              }
            }
            return totalQty;
          }
        }

        if (json['items'] != null && json['items'] is List) {
          final list = json['items'] as List;
          if (list.isEmpty) return 0;
          int totalQty = 0;
          for (var item in list) {
            if (item is Map) {
              final rawQty = item['qty'] ?? item['quantity'];
              if (rawQty != null && int.tryParse(rawQty.toString()) != null) {
                totalQty += int.tryParse(rawQty.toString())!;
              } else {
                totalQty += 1;
              }
            } else {
              totalQty += 1;
            }
          }
          return totalQty;
        }

        final rootQty = json['qty'] ?? json['quantity'] ?? json['totalQuantity'] ?? json['totalQty'];
        if (rootQty != null && int.tryParse(rootQty.toString()) != null) {
          return int.tryParse(rootQty.toString())!;
        }

        return 0;
      })(),
      totalPrice: (() {
        final billing = json['billingSummary'] ?? json['billingsummary'] ?? json['billing_summary'];
        if (billing != null && billing is Map) {
          final finalAmount = billing['finalAmount'] ?? billing['finalamount'] ?? billing['final_amount'];
          if (finalAmount != null && double.tryParse(finalAmount.toString()) != null) {
            return double.tryParse(finalAmount.toString())!;
          }
          final subtotal = billing['subtotal'] ?? billing['subTotal'] ?? billing['sub_total'];
          if (subtotal != null && double.tryParse(subtotal.toString()) != null) {
            return double.tryParse(subtotal.toString())!;
          }
          final unitPrice = billing['unitPrice'] ?? billing['unitprice'] ?? billing['unit_price'];
          if (unitPrice != null && double.tryParse(unitPrice.toString()) != null) {
            return double.tryParse(unitPrice.toString())!;
          }
        }
        final finalAmount = json['finalAmount'] ?? json['finalamount'] ?? json['final_amount'];
        if (finalAmount != null && double.tryParse(finalAmount.toString()) != null) {
          return double.tryParse(finalAmount.toString())!;
        }
        if (json['totalPrice'] != null) return double.tryParse(json['totalPrice'].toString()) ?? 0.0;
        if (json['totalprice'] != null) return double.tryParse(json['totalprice'].toString()) ?? 0.0;
        if (json['total'] != null && double.tryParse(json['total'].toString()) != null && double.tryParse(json['total'].toString())! > 0) {
            return double.tryParse(json['total'].toString()) ?? 0.0;
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
      branchName: (json['branchDetails'] is Map && json['branchDetails']['name'] != null)
          ? json['branchDetails']['name'].toString()
          : (json['orderDetails'] != null && json['orderDetails'] is Map && json['orderDetails']['branchDetails'] is Map && json['orderDetails']['branchDetails']['name'] != null)
              ? json['orderDetails']['branchDetails']['name'].toString()
              : null,
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
    if (json['imageurl'] != null) {
      if (json['imageurl'] is List) {
        parsedFiles.addAll((json['imageurl'] as List).map((e) => e.toString()));
      } else if (json['imageurl'] is String) {
        parsedFiles.add(json['imageurl'].toString());
      }
    }
    if (json['images'] != null) {
      if (json['images'] is List) {
        parsedFiles.addAll((json['images'] as List).map((e) => e.toString()));
      } else if (json['images'] is String) {
        parsedFiles.add(json['images'].toString());
      }
    }
    if (json['image'] != null) {
      if (json['image'] is List) {
        parsedFiles.addAll((json['image'] as List).map((e) => e.toString()));
      } else if (json['image'] is String) {
        parsedFiles.add(json['image'].toString());
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
