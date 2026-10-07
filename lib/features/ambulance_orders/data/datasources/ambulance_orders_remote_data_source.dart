import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../../../appointment/data/models/delivery_partner_model.dart';
import '../../../appointment/domain/entities/delivery_partner_entity.dart';
import '../../domain/entities/ambulance_order_entity.dart';

class AmbulanceOrdersRemoteDataSource {
  final ApiServiceRepository apiService;
  AmbulanceOrdersRemoteDataSource({required this.apiService});

  Future<AmbulanceOrdersListEntity> getBookingList({
    int page = 1,
    int limit = 10,
    String status = '',
    String search = '',
  }) async {
    final response = await apiService.get(
      ApiEndpoints.ambulanceBookingList,
      queryParameters: {
        'page': page,
        'limit': limit,
        'status': status,
        'search': search,
      },
    );
    final decoded = json.decode(response.body);
    final data = decoded['data'];
    final pagination = data['pagination'] as Map<String, dynamic>;
    final list =
        (data['AmbulanceData'] as List).map((e) => _parseOrder(e)).toList();
    return AmbulanceOrdersListEntity(
      orders: list,
      total: pagination['total'] ?? 0,
      page: pagination['page'] ?? page,
      limit: pagination['limit'] ?? limit,
      totalPages: pagination['totalPages'] ?? 1,
    );
  }

  Future<AmbulanceOrderEntity> getBookingDetails(String id) async {
    final response =
        await apiService.get(ApiEndpoints.ambulanceBookingSingle(id));
    final decoded = json.decode(response.body);
    final list = decoded['data'] as List;
    return _parseOrder(list.first);
  }

  Future<void> updateBookingStatus({
    required String orderId,
    required String bookingStatus,
    String? reason,
  }) async {
    final Map<String, dynamic> body = {
      'bookingStatus': bookingStatus,
      'status': bookingStatus,
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    };

    final path = ApiEndpoints.ambulanceBookingUpdateStatus(orderId);

    // Call PUT as requested by user ("put api end points"), falling back to POST if needed
    http.Response response;
    try {
      response = await apiService.put(path, body: body);
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await apiService.post(path, body: body);
      }
    } catch (_) {
      response = await apiService.post(path, body: body);
    }

    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map &&
          (decoded['status'] == false || decoded['success'] == false)) {
        throw Exception(decoded['message'] ?? 'Failed to update booking status');
      }
      return;
    } else {
      final message = decoded != null && decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Failed to update booking status';
      throw Exception(message);
    }
  }

  Future<DeliveryPartnersResultEntity> getDeliveryPartners({
    String deliveryManType = 'admin',
    int page = 1,
    int limit = 10,
    String status = 'active',
    String search = '',
  }) async {
    final queryParams = <String, dynamic>{
      'deliveryManType': deliveryManType,
      'page': page,
      'limit': limit,
      'status': status,
    };
    if (search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final response = await apiService.get(
      ApiEndpoints.deliverymanAdminList,
      queryParameters: queryParams,
    );

    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded == null) return const DeliveryPartnersResultModel();

      List<dynamic> items = [];
      DeliveryPartnerModel? ownUser;

      if (decoded is List) {
        items = decoded;
      } else if (decoded is Map) {
        if (decoded['users'] is Map) {
          ownUser = DeliveryPartnerModel.fromUserJson(
              Map<String, dynamic>.from(decoded['users'] as Map));
        } else if (decoded['user'] is Map) {
          ownUser = DeliveryPartnerModel.fromUserJson(
              Map<String, dynamic>.from(decoded['user'] as Map));
        }

        if (decoded['data'] is Map) {
          final dataMap = decoded['data'] as Map;
          for (final key in [
            'deliveryMans',
            'deliverymen',
            'deliveryMen',
            'deliveryMan',
            'adminList',
            'adminlist',
            'list',
            'partners',
            'deliveryPartners',
            'items',
            'docs',
            'users',
          ]) {
            if (dataMap[key] is List) {
              items = dataMap[key] as List;
              break;
            }
          }
        } else if (decoded['data'] is List) {
          items = decoded['data'] as List;
        }

        if (items.isEmpty) {
          for (final key in [
            'deliveryMans',
            'deliverymen',
            'deliveryMen',
            'deliveryMan',
            'adminList',
            'adminlist',
            'list',
            'partners',
            'deliveryPartners',
            'items',
            'docs',
            'users',
          ]) {
            if (decoded[key] is List) {
              items = decoded[key] as List;
              break;
            }
          }
        }
      }

      final deliveryMans = items
          .where((e) => e != null && e is Map)
          .map((e) => DeliveryPartnerModel.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList();

      return DeliveryPartnersResultModel(
        deliveryMans: deliveryMans,
        ownDeliveryUser: ownUser,
      );
    } else {
      final message = decoded != null && decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Failed to load delivery partners';
      throw Exception(message);
    }
  }

  Future<void> assignDeliveryPartner({
    required String orderId,
    required String deliveryPartnerId,
    String deliveryManType = 'admin',
    String deliveryPartner = 'medicompares',
    String? readyTime,
  }) async {
    final body = <String, dynamic>{
      'bookingStatus': 'assigned',
      'deliveryManType': deliveryManType,
      'deliveryPartner': deliveryPartner,
      'deliveryPartnerId': deliveryPartnerId,
      'readyTime': (readyTime != null && readyTime.isNotEmpty) ? readyTime : '30',
      'status': 'assigned',
    };

    final path = ApiEndpoints.ambulanceBookingUpdateStatus(orderId);

    http.Response response;
    try {
      response = await apiService.put(path, body: body);
      if (response.statusCode == 404 || response.statusCode == 405) {
        response = await apiService.post(path, body: body);
      }
    } catch (_) {
      response = await apiService.post(path, body: body);
    }

    final decoded = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decoded is Map &&
          (decoded['status'] == false || decoded['success'] == false)) {
        throw Exception(decoded['message'] ?? 'Failed to assign delivery partner');
      }
      return;
    } else {
      final message = decoded != null && decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Failed to assign delivery partner';
      throw Exception(message);
    }
  }

  AmbulanceOrderEntity _parseOrder(Map<String, dynamic> e) {
    final pickup = e['pickupLocation'] as Map<String, dynamic>? ?? {};
    final dropoff = e['dropoffLocation'] as Map<String, dynamic>? ?? {};
    final pickupCoords = pickup['coordinates'] as List? ?? [];
    final dropoffCoords = dropoff['coordinates'] as List? ?? [];

    final usersList = (e['users'] as List? ?? []).map((u) {
      final files = (u['files'] as List? ?? []);
      return AmbulanceOrderUser(
        id: u['_id'] ?? '',
        firstName: u['firstName'] ?? u['first_name'] ?? '',
        lastName: u['lastName'] ?? u['last_name'] ?? '',
        phone: u['mobile']?.toString() ?? u['phone']?.toString() ?? '',
        email: u['email']?.toString() ?? '',
        profileImage: files.isNotEmpty ? files.first.toString() : null,
        age: u['age'] is int ? u['age'] : int.tryParse(u['age']?.toString() ?? ''),
        gender: u['gender']?.toString(),
        medicalConditions: (u['medical_conditions'] ?? u['medicalConditions'])?.toString(),
      );
    }).toList();

    final productList = (e['productdetails'] as List? ?? []).map((p) {
      final tablets = (p['tabletdetails'] as List? ?? []);
      final tablet =
          tablets.isNotEmpty ? tablets.first as Map<String, dynamic> : {};
      final tabletFiles = (tablet['files'] as List? ?? []);
      final business = (p['bussinessDetails'] as List? ?? []);
      final biz =
          business.isNotEmpty ? business.first as Map<String, dynamic> : {};
      return AmbulanceOrderProductDetail(
        id: p['_id']?.toString() ?? '',
        serviceName: tablet['name']?.toString() ?? 'N/A',
        ambulanceType: tablet['ambulancetype']?.toString(),
        price: (p['price'] as num?)?.toDouble() ?? 0,
        discountPrice: (p['discountprice'] as num?)?.toDouble() ?? 0,
        imageUrl: tabletFiles.isNotEmpty ? tabletFiles.first.toString() : null,
        businessName: biz['name']?.toString(),
        businessPhone: biz['mobile']?.toString(),
        businessEmail: biz['email']?.toString(),
        businessAddress: biz['address']?.toString(),
      );
    }).toList();

    AmbulanceDriverEntity? driver;
    final driverMap = e['driverDetails'] ?? e['driver'] ?? e['assignedDriver'] ?? e['deliveryman'];
    if (driverMap is Map<String, dynamic>) {
      driver = AmbulanceDriverEntity(
        id: driverMap['_id']?.toString() ?? '',
        name: driverMap['name']?.toString() ?? driverMap['fullName']?.toString() ?? 'Delivery Driver',
        phone: driverMap['phone']?.toString() ?? driverMap['mobile']?.toString() ?? 'N/A',
        email: driverMap['email']?.toString() ?? 'N/A',
        vehicleNumber: driverMap['vehicleNumber']?.toString() ?? driverMap['vehicle_number']?.toString() ?? 'N/A',
        profileImage: driverMap['profileImage']?.toString() ?? driverMap['image']?.toString(),
        otp: e['deliveryOtp']?.toString() ?? e['otp']?.toString() ?? driverMap['otp']?.toString() ?? 'N/A',
        assignedAt: e['driverAssignedAt'] != null || e['assignedAt'] != null
            ? DateTime.tryParse((e['driverAssignedAt'] ?? e['assignedAt']).toString())
            : null,
      );
    } else if (e['deliveries'] is List && (e['deliveries'] as List).isNotEmpty) {
      final del = (e['deliveries'] as List).first;
      if (del is Map<String, dynamic>) {
        final dPartner = del['deliveryPartnerDetails'] ?? del['deliveryPartner'];
        final dpMap = dPartner is Map<String, dynamic> ? dPartner : {};
        driver = AmbulanceDriverEntity(
          id: dpMap['_id']?.toString() ?? del['deliveryPartnerId']?.toString() ?? '',
          name: dpMap['name']?.toString() ?? 'Delivery Driver',
          phone: dpMap['phone']?.toString() ?? dpMap['mobile']?.toString() ?? 'N/A',
          email: dpMap['email']?.toString() ?? 'N/A',
          vehicleNumber: dpMap['vehicleNumber']?.toString() ?? 'N/A',
          profileImage: dpMap['profileImage']?.toString(),
          otp: del['deliveryOtp']?.toString() ?? 'N/A',
          assignedAt: del['deliveryAssignedAt'] != null
              ? DateTime.tryParse(del['deliveryAssignedAt'].toString())
              : null,
        );
      }
    }

    final billing = e['billingSummary'] is Map
        ? (e['billingSummary'] as Map<String, dynamic>)
        : (e['billing'] is Map ? (e['billing'] as Map<String, dynamic>) : null);

    final double fare = (() {
      if (e['fare'] != null) {
        final val = (e['fare'] as num?)?.toDouble() ??
            double.tryParse(e['fare'].toString());
        if (val != null) return val;
      }
      if (billing != null) {
        if (billing['subtotal'] != null) {
          final val = (billing['subtotal'] as num?)?.toDouble() ??
              double.tryParse(billing['subtotal'].toString());
          if (val != null) return val;
        }
        if (billing['fare'] != null) {
          final val = (billing['fare'] as num?)?.toDouble() ??
              double.tryParse(billing['fare'].toString());
          if (val != null) return val;
        }
        if (billing['price'] != null) {
          final val = (billing['price'] as num?)?.toDouble() ??
              double.tryParse(billing['price'].toString());
          if (val != null) return val;
        }
      }
      if (e['price'] != null) {
        final val = (e['price'] as num?)?.toDouble() ??
            double.tryParse(e['price'].toString());
        if (val != null) return val;
      }
      if (e['subtotal'] != null) {
        final val = (e['subtotal'] as num?)?.toDouble() ??
            double.tryParse(e['subtotal'].toString());
        if (val != null) return val;
      }
      if (productList.isNotEmpty && productList.first.price >= 0) {
        return productList.first.price;
      }
      if (billing != null && billing['total'] != null) {
        final val = (billing['total'] as num?)?.toDouble() ??
            double.tryParse(billing['total'].toString());
        if (val != null) return val;
      }
      return 0.0;
    })();

    final double couponAmount = (() {
      if (billing != null) {
        for (final k in ['couponAmount', 'couponamount', 'discount', 'couponDiscount']) {
          if (billing[k] != null) {
            final val = (billing[k] as num?)?.toDouble() ??
                double.tryParse(billing[k].toString());
            if (val != null) return val;
          }
        }
      }
      for (final k in ['couponAmount', 'couponamount', 'discount', 'couponDiscount']) {
        if (e[k] != null) {
          final val = (e[k] as num?)?.toDouble() ??
              double.tryParse(e[k].toString());
          if (val != null) return val;
        }
      }
      return 0.0;
    })();

    final String couponType = (() {
      if (billing != null) {
        final val = billing['coupontype'] ?? billing['couponType'] ?? billing['createdType'] ?? billing['createdtype'];
        if (val != null && val.toString().isNotEmpty) return val.toString();
      }
      if (e['couponDetails'] is Map) {
        final cd = e['couponDetails'] as Map;
        final val = cd['createdType'] ?? cd['createdtype'] ?? cd['coupontype'] ?? cd['couponType'] ?? cd['type'];
        if (val != null && val.toString().isNotEmpty) return val.toString();
      }
      final val = e['coupontype'] ?? e['couponType'];
      if (val != null && val.toString().isNotEmpty) return val.toString();
      return '';
    })();

    final String couponCode = (() {
      if (billing != null) {
        final val = billing['couponCode'] ?? billing['couponcode'] ?? billing['code'];
        if (val != null && val.toString().isNotEmpty) return val.toString();
      }
      if (e['couponDetails'] is Map) {
        final cd = e['couponDetails'] as Map;
        final val = cd['couponCode'] ?? cd['code'] ?? cd['couponcode'] ?? cd['title'] ?? cd['name'];
        if (val != null && val.toString().isNotEmpty) return val.toString();
      }
      final val = e['couponCode'] ?? e['couponcode'] ?? e['coupon'] ?? e['code'];
      if (val != null && val.toString().isNotEmpty) return val.toString();
      return 'DIGIHidden';
    })();

    final double gst = (() {
      if (e['gst'] != null) {
        final val = (e['gst'] as num?)?.toDouble() ?? double.tryParse(e['gst'].toString());
        if (val != null) return val;
      }
      if (billing != null) {
        for (final k in ['tax', 'gst', 'totalGst', 'totalgst']) {
          if (billing[k] != null) {
            final val = (billing[k] as num?)?.toDouble() ?? double.tryParse(billing[k].toString());
            if (val != null) return val;
          }
        }
      }
      return 0.0;
    })();

    final double adminCommission = (() {
      final possibleKeys = [
        'vendorCommissionAmount',
        'vendorcommissionamount',
        'adminCommission',
        'admincommission',
        'adminCommissionAmount',
        'admincommissionamount',
        'vendorCommission',
        'commission',
        'commissionAmount',
      ];
      if (billing != null) {
        for (final k in possibleKeys) {
          if (billing[k] != null) {
            final val = (billing[k] as num?)?.toDouble() ?? double.tryParse(billing[k].toString());
            if (val != null) return val;
          }
        }
      }
      for (final k in possibleKeys) {
        if (e[k] != null) {
          final val = (e[k] as num?)?.toDouble() ?? double.tryParse(e[k].toString());
          if (val != null) return val;
        }
      }
      return 0.0;
    })();

    final double totalFare = (() {
      final isVendorCoupon = couponType.trim().toLowerCase() == 'vendor';
      final discount = isVendorCoupon ? couponAmount : 0.0;
      final calculated = fare - adminCommission - discount;
      return calculated < 0.0 ? 0.0 : calculated;
    })();

    return AmbulanceOrderEntity(
      id: e['_id']?.toString() ?? '',
      bookingId: e['bookingId']?.toString() ?? '',
      pickupLocation: AmbulanceOrderLocation(
        lat: pickupCoords.length > 1 ? (num.tryParse(pickupCoords[1]?.toString() ?? '0')?.toDouble() ?? 0) : 0,
        lng: pickupCoords.isNotEmpty ? (num.tryParse(pickupCoords[0]?.toString() ?? '0')?.toDouble() ?? 0) : 0,
        address: pickup['address']?.toString() ?? '',
      ),
      dropoffLocation: AmbulanceOrderLocation(
        lat: dropoffCoords.length > 1 ? (num.tryParse(dropoffCoords[1]?.toString() ?? '0')?.toDouble() ?? 0) : 0,
        lng: dropoffCoords.isNotEmpty ? (num.tryParse(dropoffCoords[0]?.toString() ?? '0')?.toDouble() ?? 0) : 0,
        address: dropoff['address']?.toString() ?? '',
      ),
      distance: (e['distance'] as num?)?.toDouble() ?? 0,
      subtotal: (billing != null && billing['subtotal'] != null)
          ? ((billing['subtotal'] as num?)?.toDouble() ??
              double.tryParse(billing['subtotal'].toString()) ??
              fare)
          : fare,
      fare: fare,
      totalFare: totalFare,
      gst: gst,
      adminCommission: adminCommission,
      couponAmount: couponAmount,
      couponType: couponType,
      couponCode: couponCode,
      status: e['status']?.toString() ?? 'pending',
      bookingStatus: e['bookingStatus']?.toString() ?? 'pending',
      paymentMethod: e['paymentMethod']?.toString() ?? e['paymentmethod']?.toString() ?? 'cod',
      paymentStatus: e['paymentStatus']?.toString() ?? e['paymentstatus']?.toString() ?? 'unpaid',
      emergencyType: e['emergencyType']?.toString() ?? '',
      bookingDateTime: e['bookingDateTime'] != null
          ? DateTime.tryParse(e['bookingDateTime'].toString())
          : null,
      createdAt: e['createdAt'] != null
          ? DateTime.tryParse(e['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      users: usersList,
      productDetails: productList,
      driver: driver,
    );
  }
}
