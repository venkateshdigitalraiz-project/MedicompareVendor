import '../entities/slot_timing_entity.dart';

abstract class SlotsRepository {
  Future<List<SlotTimingEntity>> getSlotTimings();
}
