import '../entities/slot_timing_entity.dart';
import '../entities/vendor_vacation_entity.dart';

abstract class SlotsRepository {
  Future<List<SlotTimingEntity>> getSlotTimings();
  Future<SlotTimingEntity> updateSlotTimings(
      String id, SlotTimingEntity entity);
  Future<List<VendorVacationEntity>> getVacationCalendar({
    required int month,
    required int year,
  });
  Future<bool> saveVacation(VendorVacationEntity entity);
  Future<bool> deleteVacation(String id);
}
