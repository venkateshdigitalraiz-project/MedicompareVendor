import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/api_service_repository.dart';
import '../../../auth/data/models/vendor_response_model.dart';

class VendorProfileService {
  final ApiServiceRepository apiService;

  VendorProfileService({required this.apiService});

  Future<VendorResponseModel> updateStepOne({
    required String proofType,
    required String idNumber,
    required XFile frontImage,
    required XFile backImage,
    required String residentialAddress,
  }) async {
    final response = await apiService.post(
      ApiEndpoints.stepOneUpdate,
      fields: {
        'proofType': proofType,
        'adharnumber': idNumber,
        'residentaladdress': residentialAddress,
      },
      files: {
        'adhaarfrontimage': File(frontImage.path),
        'adhaarbackimage': File(backImage.path),
      },
    );

    return VendorResponseModel.fromJson(jsonDecode(response.body));
  }

  Future<VendorResponseModel> updateStepTwo({
    required String name,
    required String businessLegalName,
    required String email,
    required String mobile,
    String? altMobile,
    required String address,
    required double lat,
    required double lng,
    required List<String> categoryIds,
  }) async {
    final response = await apiService.post(
      ApiEndpoints.stepTwoUpdate,
      body: {
        'name': name,
        'bussinesslegalname': businessLegalName,
        'email': email,
        'mobile': mobile,
        'alt_mobile': altMobile,
        'address': address,
        'location': {
          'type': 'Point',
          'coordinates': [lng, lat],
          'address': address,
        },
        'categoryIds': categoryIds,
      },
    );

    return VendorResponseModel.fromJson(jsonDecode(response.body));
  }
}
