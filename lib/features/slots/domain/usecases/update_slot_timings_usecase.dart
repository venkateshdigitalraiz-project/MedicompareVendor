import '../entities/slot_timing_entity.dart';
import '../repositories/slots_repository.dart';

class UpdateSlotTimingsUseCase {
  final SlotsRepository repository;

  UpdateSlotTimingsUseCase({required this.repository});

  Future<SlotTimingEntity> call(String id, SlotTimingEntity entity) async {
    return await repository.updateSlotTimings(id, entity);
  }
}
