import '../../core/utils/core_injection.dart';
import 'data/data_sources/vendor_profile_service.dart';
import 'data/repositories/vendor_profile_repository_impl.dart';
import 'domain/repositories/vendor_profile_repository.dart';
import 'domain/usecases/update_step_one_usecase.dart';
import 'domain/usecases/update_step_two_usecase.dart';

class VendorProfileInjection {
  static final VendorProfileService _service = VendorProfileService(
    apiService: CoreInjection.provideApiService(),
  );
  static final VendorProfileRepository _repository =
      VendorProfileRepositoryImpl(service: _service);

  static UpdateStepOneUseCase provideUpdateStepOneUseCase() {
    return UpdateStepOneUseCase(_repository);
  }

  static UpdateStepTwoUseCase provideUpdateStepTwoUseCase() {
    return UpdateStepTwoUseCase(_repository);
  }
}
