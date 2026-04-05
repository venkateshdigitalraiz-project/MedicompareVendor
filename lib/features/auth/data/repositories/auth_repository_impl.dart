import '../../domain/entities/vendor_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<VendorEntity> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    required String password,
  }) async {
    final responseModel = await remoteDataSource.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      mobile: mobile,
      password: password,
    );

    if (responseModel.success &&
        responseModel.data != null &&
        responseModel.data!.user != null) {
      return responseModel.data!.user!.toEntity(responseModel.data!.token);
    } else {
      throw Exception(responseModel.message);
    }
  }

  @override
  Future<VendorEntity> login({
    required String email,
    required String password,
  }) async {
    final responseModel = await remoteDataSource.login(
      email: email,
      password: password,
    );

    if (responseModel.success &&
        responseModel.data != null &&
        responseModel.data!.user != null) {
      return responseModel.data!.user!.toEntity(responseModel.data!.token);
    } else {
      throw Exception(responseModel.message);
    }
  }
}
