import '../repositories/pincodes_repository.dart';

class DeletePincodeUseCase {
  final PincodesRepository repository;

  DeletePincodeUseCase({required this.repository});

  Future<void> call(String id) async {
    return await repository.deletePincode(id);
  }
}
