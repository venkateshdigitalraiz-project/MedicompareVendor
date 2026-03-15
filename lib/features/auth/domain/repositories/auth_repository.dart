import '../entities/vendor_entity.dart';

abstract class AuthRepository {
  Future<VendorEntity> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
  });

  Future<VendorEntity> login({
    required String email,
    required String password,
  });
}
