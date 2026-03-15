import '../../../auth/domain/entities/vendor_entity.dart';
import '../repositories/vendor_profile_repository.dart';

class UpdateStepTwoUseCase {
  final VendorProfileRepository repository;

  UpdateStepTwoUseCase(this.repository);

  Future<VendorEntity> call({
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
  }) {
    return repository.updateStepTwo(
      token: token,
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
  }
}
