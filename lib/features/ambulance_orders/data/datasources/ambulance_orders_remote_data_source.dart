import 'dart:convert';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
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
    final list = (data['AmbulanceData'] as List)
        .map((e) => _parseOrder(e))
        .toList();
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

  AmbulanceOrderEntity _parseOrder(Map<String, dynamic> e) {
    final pickup = e['pickupLocation'] as Map<String, dynamic>? ?? {};
    final dropoff = e['dropoffLocation'] as Map<String, dynamic>? ?? {};
    final pickupCoords = pickup['coordinates'] as List? ?? [];
    final dropoffCoords = dropoff['coordinates'] as List? ?? [];

    final usersList = (e['users'] as List? ?? []).map((u) {
      final files = (u['files'] as List? ?? []);
      return AmbulanceOrderUser(
        id: u['_id'] ?? '',
        firstName: u['first_name'] ?? '',
        lastName: u['last_name'] ?? '',
        phone: u['phone']?.toString() ?? '',
        email: u['email']?.toString() ?? '',
        profileImage: files.isNotEmpty ? files.first.toString() : null,
        age: u['age'] is int ? u['age'] : null,
        gender: u['gender']?.toString(),
        medicalConditions: u['medical_conditions']?.toString(),
      );
    }).toList();

    final productList =
        (e['productdetails'] as List? ?? []).map((p) {
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
        imageUrl:
            tabletFiles.isNotEmpty ? tabletFiles.first.toString() : null,
        businessName: biz['name']?.toString(),
        businessPhone: biz['mobile']?.toString(),
        businessEmail: biz['email']?.toString(),
        businessAddress: biz['address']?.toString(),
      );
    }).toList();

    return AmbulanceOrderEntity(
      id: e['_id']?.toString() ?? '',
      bookingId: e['bookingId']?.toString() ?? '',
      pickupLocation: AmbulanceOrderLocation(
        lat: pickupCoords.length > 1
            ? (pickupCoords[1] as num).toDouble()
            : 0,
        lng: pickupCoords.isNotEmpty
            ? (pickupCoords[0] as num).toDouble()
            : 0,
        address: pickup['address']?.toString() ?? '',
      ),
      dropoffLocation: AmbulanceOrderLocation(
        lat: dropoffCoords.length > 1
            ? (dropoffCoords[1] as num).toDouble()
            : 0,
        lng: dropoffCoords.isNotEmpty
            ? (dropoffCoords[0] as num).toDouble()
            : 0,
        address: dropoff['address']?.toString() ?? '',
      ),
      distance: (e['distance'] as num?)?.toDouble() ?? 0,
      fare: (e['fare'] as num?)?.toDouble() ?? 0,
      totalFare: (e['totalFare'] as num?)?.toDouble() ?? 0,
      gst: (e['gst'] as num?)?.toDouble() ?? 0,
      status: e['status']?.toString() ?? 'pending',
      bookingStatus: e['bookingStatus']?.toString() ?? 'pending',
      paymentMethod: e['paymentmethod']?.toString() ?? 'cod',
      paymentStatus: e['paymentStatus']?.toString() ?? 'unpaid',
      emergencyType: e['emergencyType']?.toString() ?? '',
      createdAt: e['createdAt'] != null
          ? DateTime.tryParse(e['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      users: usersList,
      productDetails: productList,
    );
  }
}
