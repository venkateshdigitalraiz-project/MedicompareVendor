import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../../auth/data/models/vendor_response_model.dart';

class VendorProfileService {
  final http.Client client;

  VendorProfileService({required this.client});

  Future<VendorResponseModel> updateStepOne({
    required String token,
    required String proofType,
    required String idNumber,
    required XFile frontImage,
    required XFile backImage,
    required String residentialAddress,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(ApiEndpoints.stepOneUpdate));
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['proofType'] = proofType;
    request.fields['adharnumber'] = idNumber; // Based on API response keys
    request.fields['residentaladdress'] = residentialAddress;

    final frontBytes = await frontImage.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'adhaarfrontimage',
      frontBytes,
      filename: frontImage.name,
    ));

    final backBytes = await backImage.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'adhaarbackimage',
      backBytes,
      filename: backImage.name,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return VendorResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update step one: ${response.body}');
    }
  }

  Future<VendorResponseModel> updateStepTwo({
    required String token,
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
    final response = await client.post(
      Uri.parse(ApiEndpoints.stepTwoUpdate),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'bussinesslegalname': businessLegalName,
        'email': email,
        'mobile': mobile,
        'alt_mobile': altMobile,
        'address': address,
        'location': {
          'type': 'Point',
          'coordinates': [lng, lat], // [longitude, latitude] as per requirements
          'address': address,
        },
        'categoryIds': categoryIds,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return VendorResponseModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update step two: ${response.body}');
    }
  }
}
