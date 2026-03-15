import '../entities/vendor_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<VendorEntity> call({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
  }) {
    return repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      mobile: mobile,
      password: password,
    );
  }
}
