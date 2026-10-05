import '../entities/vendor_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<VendorEntity> call({
    required String email,
    required String password,
    String? otp,
    String? fcmToken,
  }) {
    return repository.login(
      email: email,
      password: password,
      otp: otp,
      fcmToken: fcmToken,
    );
  }
}
