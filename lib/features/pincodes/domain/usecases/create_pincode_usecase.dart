import '../repositories/pincodes_repository.dart';

class CreatePincodeUseCase {
  final PincodesRepository repository;

  CreatePincodeUseCase({required this.repository});

  Future<void> call({
    required String pincode,
    required String estimatedDelivery,
    required String status,
  }) async {
    return await repository.createPincode(
      pincode: pincode,
      estimatedDelivery: estimatedDelivery,
      status: status,
    );
  }
}
