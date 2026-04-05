import 'dart:convert';
import 'dart:io';
import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/api/api_service_repository.dart';
import 'package:MediCompare/core/error/exceptions.dart';
import 'package:MediCompare/features/lab_test/data/models/lab_test_model.dart';
import 'package:MediCompare/features/lab_test/data/models/lab_test_package_model.dart';

class LabTestService {
  final ApiServiceRepository _apiService;

  LabTestService(this._apiService);

  Future<List<LabTestCategory>> getCategories() async {
    try {
      final response = await _apiService.get(ApiEndpoints.labTestsCategories);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List categoriesJson = body['data']['allcategory'] ?? [];
        return categoriesJson
            .map((json) => LabTestCategory.fromJson(json))
            .toList();
      }
      throw ServerException(body['message'] ?? 'Failed to fetch categories');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<LabTestResponse> getLabTestList({
    int page = 1,
    String categoryId = '',
    String search = '',
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'categoryId': categoryId,
        'search': search,
      };

      final response = await _apiService.get(ApiEndpoints.labTestsList,
          queryParameters: queryParams);
      final body = jsonDecode(response.body);

      if (body['success'] == true) {
        return LabTestResponse.fromJson(body['data']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch lab tests');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<LabTestItem> getLabTestDetails(String id) async {
    try {
      final response =
          await _apiService.post(ApiEndpoints.labTestDetails(id), body: {});
      final body = jsonDecode(response.body);

      if (body['success'] == true) {
        return LabTestItem.fromJson(body['data']['product']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch details');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<List<LabTestDetails>> searchLabTests(String query) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.labTestsSearchTablets,
        queryParameters: {'search': query, 'type': 'labtests'},
      );
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List lists = body['data']['tablets'] ?? [];
        return lists.map((e) => LabTestDetails.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<List<LabTestDetails>> getAllLabTestTablets() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.labTestsSearchTablets,
        queryParameters: {'type': 'labtests'},
      );
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final List lists = body['data']['tablets'] ?? [];
        return lists.map((e) => LabTestDetails.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<LabTestDetails> getLabTestTabletDetails(String id) async {
    try {
      final response = await _apiService.get(ApiEndpoints.getTabletDetails(id));
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return LabTestDetails.fromJson(body['data']['tablets']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch details');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> createLabTest(Map<String, dynamic> data) async {
    try {
      final response =
          await _apiService.post(ApiEndpoints.createLabTest, body: data);
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to create lab test');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> updateLabTest(String id, Map<String, dynamic> data) async {
    try {
      final response =
          await _apiService.post(ApiEndpoints.updateLabTest(id), body: data);
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to update lab test');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> deleteLabTest(String id) async {
    try {
      final response = await _apiService.post(ApiEndpoints.deleteLabTest(id));
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to delete lab test');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // --- Packages ---

  Future<LabTestPackageResponse> getPackageList({
    int page = 1,
    int limit = 10,
    String search = '',
    String labTestId = '',
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'search': search,
        'labTest': labTestId,
      };

      final response = await _apiService.get(ApiEndpoints.packageList,
          queryParameters: queryParams);
      final body = jsonDecode(response.body);

      if (body['success'] == true) {
        return LabTestPackageResponse.fromJson(body['data']);
      }
      throw ServerException(body['message'] ?? 'Failed to fetch packages');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<LabTestPackageItem> getPackageDetails(String id) async {
    try {
      // Step 1: Find the package from the list
      final listResp =
          await _apiService.get(ApiEndpoints.packageList, queryParameters: {
        'page': '1',
        'limit': '100',
        'search': '',
      });
      final listBody = jsonDecode(listResp.body);

      if (listBody['success'] != true) {
        throw ServerException(
            listBody['message'] ?? 'Failed to fetch packages');
      }

      final List items = listBody['data']['list'] ?? [];
      final matchJson = items.firstWhere(
        (item) => item['_id'] == id,
        orElse: () => null,
      );

      if (matchJson == null) throw ServerException('Package not found');

      LabTestPackageItem pkg = LabTestPackageItem.fromJson(matchJson);

      // Step 2: If tabletsdetails is not already populated, enrich using the
      // all-tablets API (type=labtests) by matching products IDs
      if (pkg.tabletsDetails.isEmpty && pkg.products.isNotEmpty) {
        final allTests = await getAllLabTestTablets();
        final matched =
            allTests.where((t) => pkg.products.contains(t.id)).toList();
        pkg = LabTestPackageItem(
          id: pkg.id,
          name: pkg.name,
          description: pkg.description,
          price: pkg.price,
          discountPrice: pkg.discountPrice,
          status: pkg.status,
          files: pkg.files,
          products: pkg.products,
          tabletsDetails: matched,
          createdAt: pkg.createdAt,
          updatedAt: pkg.updatedAt,
        );
      }

      return pkg;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  Future<void> createPackage(Map<String, dynamic> data, {File? image}) async {
    try {
      if (image != null) {
        final fields = <String, String>{};
        data.forEach((key, value) {
          if (key == 'products' && value is List) {
            for (int i = 0; i < value.length; i++) {
              fields['products[$i]'] = value[i].toString();
            }
          } else {
            fields[key] = value.toString();
          }
        });

        final response = await _apiService.post(
          ApiEndpoints.createPackage,
          fields: fields,
          files: {'image': image},
        );
        final body = jsonDecode(response.body);
        if (body['success'] != true) {
          throw ServerException(body['message'] ?? 'Failed to create package');
        }
      } else {
        final response =
            await _apiService.post(ApiEndpoints.createPackage, body: data);
        final body = jsonDecode(response.body);
        if (body['success'] != true) {
          throw ServerException(body['message'] ?? 'Failed to create package');
        }
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> updatePackage(String id, Map<String, dynamic> data,
      {File? image}) async {
    try {
      if (image != null) {
        final fields = <String, String>{};
        data.forEach((key, value) {
          if (key == 'products' && value is List) {
            for (int i = 0; i < value.length; i++) {
              fields['products[$i]'] = value[i].toString();
            }
          } else {
            fields[key] = value.toString();
          }
        });

        final response = await _apiService.post(
          ApiEndpoints.updatePackage(id),
          fields: fields,
          files: {'image': image},
        );
        final body = jsonDecode(response.body);
        if (body['success'] != true) {
          throw ServerException(body['message'] ?? 'Failed to update package');
        }
      } else {
        final response =
            await _apiService.post(ApiEndpoints.updatePackage(id), body: data);
        final body = jsonDecode(response.body);
        if (body['success'] != true) {
          throw ServerException(body['message'] ?? 'Failed to update package');
        }
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<LabTestPackageResponse> getAdminPackageList() async {
    try {
      final response = await _apiService.get(ApiEndpoints.adminPackageList,
          queryParameters: {'page': '1', 'limit': '100'});
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return LabTestPackageResponse.fromJson(body['data']);
      }
      throw ServerException(
          body['message'] ?? 'Failed to fetch admin packages');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  Future<void> deletePackage(String id) async {
    try {
      final response = await _apiService.post(ApiEndpoints.deletePackage(id));
      final body = jsonDecode(response.body);
      if (body['success'] != true) {
        throw ServerException(body['message'] ?? 'Failed to delete package');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
