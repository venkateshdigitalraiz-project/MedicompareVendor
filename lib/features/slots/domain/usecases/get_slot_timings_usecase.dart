import '../entities/slot_timing_entity.dart';
import '../repositories/slots_repository.dart';

class GetSlotTimingsUseCase {
  final SlotsRepository repository;

  GetSlotTimingsUseCase({required this.repository});

  Future<List<SlotTimingEntity>> call() async {
    return await repository.getSlotTimings();
  }
}
