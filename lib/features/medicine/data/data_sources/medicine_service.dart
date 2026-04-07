import 'package:flutter/foundation.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../../../../core/error/exceptions.dart';
import '../models/medicine_model.dart';
import 'dart:convert';

class MedicineService {
  final ApiServiceRepository _apiService;

  MedicineService(this._apiService);

  Future<List<MedicineCategory>> getCategories() async {
    try {
      final response = await _apiService.get(ApiEndpoints.medicineCategories);
      return compute(_parseCategories, response.body);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  static List<MedicineCategory> _parseCategories(String body) {
    final decoded = jsonDecode(body);
    if (decoded['success'] == true) {
      final List categories = decoded['data']['allcategory'] ?? [];
      return categories.map((c) => MedicineCategory.fromJson(c)).toList();
    } else {
      throw ServerException(decoded['message'] ?? 'Failed to fetch categories');
    }
  }

  Future<MedicineResponse> getMedicineList({
    int page = 1,
    int limit = 10,
    String categoryId = '',
    String search = '',
  }) async {
    try {
      final String endpoint =
          "${ApiEndpoints.medicineList}?page=$page&limit=$limit&categoryId=$categoryId&search=$search";
      final response = await _apiService.get(endpoint);
      return compute(_parseMedicineResponse, response.body);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  static MedicineResponse _parseMedicineResponse(String body) {
    final decoded = jsonDecode(body);
    if (decoded['success'] == true) {
      return MedicineResponse.fromJson(decoded['data']);
    } else {
      throw ServerException(
          decoded['message'] ?? 'Failed to fetch medicine list');
    }
  }

  Future<List<MedicineDropdownItem>> searchMedicineDropdown(
      String query) async {
    try {
      final response = await _apiService.get(
          "${ApiEndpoints.medicineDropdownSearch}?search=$query&type=medicine");
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List tablets = body['data']['tablets'] ?? [];
        return tablets.map((t) => MedicineDropdownItem.fromJson(t)).toList();
      } else {
        throw ServerException(body['message'] ?? 'Failed to search medicines');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<MedicineDropdownItem> getMedicineDetails(String id) async {
    try {
      final response =
          await _apiService.get("${ApiEndpoints.medicineDropdownSearch}/$id");
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return MedicineDropdownItem.fromJson(body['data']['tablets']);
      } else {
        throw ServerException(
            body['message'] ?? 'Failed to get medicine details');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> addMedicine(Map<String, dynamic> payload) async {
    try {
      final response =
          await _apiService.post(ApiEndpoints.createMedicine, body: payload);
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to add medicine');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<Map<String, dynamic>> getVendorMedicineDetails(String id) async {
    try {
      final response =
          await _apiService.post(ApiEndpoints.vendorMedicineDetails(id));
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return body['data']['product'];
      } else {
        throw ServerException(
            body['message'] ?? 'Failed to get medicine details');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> updateMedicine(String id, Map<String, dynamic> payload) async {
    try {
      final response = await _apiService.post(ApiEndpoints.updateMedicine(id),
          body: payload);
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to update medicine');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> deleteMedicine(String id) async {
    try {
      final response = await _apiService.post(ApiEndpoints.deleteMedicine(id));
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to delete medicine');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
