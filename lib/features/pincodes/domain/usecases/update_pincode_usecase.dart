import '../repositories/pincodes_repository.dart';

class UpdatePincodeUseCase {
  final PincodesRepository repository;

  UpdatePincodeUseCase({required this.repository});

  Future<void> call({
    required String id,
    required String pincode,
    required String estimatedDelivery,
    required String status,
  }) async {
    return await repository.updatePincode(
      id: id,
      pincode: pincode,
      estimatedDelivery: estimatedDelivery,
      status: status,
    );
  }
}
