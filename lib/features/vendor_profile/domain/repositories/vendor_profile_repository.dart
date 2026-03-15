import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/entities/vendor_entity.dart';

abstract class VendorProfileRepository {
  Future<VendorEntity> updateStepOne({
    required String token,
    required String proofType,
    required String idNumber,
    required XFile frontImage,
    required XFile backImage,
    required String residentialAddress,
  });

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
  });
}
