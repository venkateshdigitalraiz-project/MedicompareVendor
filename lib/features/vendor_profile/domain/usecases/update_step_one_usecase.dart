import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/entities/vendor_entity.dart';
import '../repositories/vendor_profile_repository.dart';

class UpdateStepOneUseCase {
  final VendorProfileRepository repository;

  UpdateStepOneUseCase(this.repository);

  Future<VendorEntity> call({
    required String token,
    required String proofType,
    required String idNumber,
    required XFile frontImage,
    required XFile backImage,
    required String residentialAddress,
  }) {
    return repository.updateStepOne(
      token: token,
      proofType: proofType,
      idNumber: idNumber,
      frontImage: frontImage,
      backImage: backImage,
      residentialAddress: residentialAddress,
    );
  }
}
