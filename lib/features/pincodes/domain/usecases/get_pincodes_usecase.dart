import '../entities/pincode_entity.dart';
import '../repositories/pincodes_repository.dart';

class GetPincodesUseCase {
  final PincodesRepository repository;

  GetPincodesUseCase({required this.repository});

  Future<List<PincodeDataEntity>> call() async {
    return await repository.getPincodes();
  }
}
