import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/entities/vendor_entity.dart';
import '../data_sources/vendor_profile_service.dart';
import '../../domain/repositories/vendor_profile_repository.dart';

class VendorProfileRepositoryImpl implements VendorProfileRepository {
  final VendorProfileService service;

  VendorProfileRepositoryImpl({required this.service});

  @override
  Future<VendorEntity> updateStepOne({
    required String token,
    required String proofType,
    required String idNumber,
    required XFile frontImage,
    required XFile backImage,
    required String residentialAddress,
  }) async {
    final responseModel = await service.updateStepOne(
      proofType: proofType,
      idNumber: idNumber,
      frontImage: frontImage,
      backImage: backImage,
      residentialAddress: residentialAddress,
    );

    if (responseModel.success &&
        responseModel.data != null &&
        responseModel.data!.user != null) {
      final newToken = responseModel.data!.token;
      return responseModel.data!.user!
          .toEntity(newToken.isEmpty ? token : newToken);
    } else {
      throw Exception(responseModel.message);
    }
  }

  @override
  Future<VendorEntity> updateStepTwo({
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
    final responseModel = await service.updateStepTwo(
      name: name,
      businessLegalName: businessLegalName,
      email: email,
      mobile: mobile,
      altMobile: altMobile,
      address: address,
      lat: lat,
      lng: lng,
      categoryIds: categoryIds,
    );

    if (responseModel.success &&
        responseModel.data != null &&
        responseModel.data!.user != null) {
      final newToken = responseModel.data!.token;
      return responseModel.data!.user!
          .toEntity(newToken.isEmpty ? token : newToken);
    } else {
      throw Exception(responseModel.message);
    }
  }
}
