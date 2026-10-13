import '../../domain/entities/slot_timing_entity.dart';
import '../../domain/entities/vendor_vacation_entity.dart';
import '../../domain/repositories/slots_repository.dart';
import '../data_sources/slots_remote_data_source.dart';
import '../models/slot_timing_model.dart';

import '../models/vendor_vacation_model.dart';

class SlotsRepositoryImpl implements SlotsRepository {
  final SlotsRemoteDataSource remoteDataSource;

  SlotsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SlotTimingEntity>> getSlotTimings() async {
    return await remoteDataSource.getSlotTimings();
  }

  @override
  Future<SlotTimingEntity> updateSlotTimings(
      String id, SlotTimingEntity entity) async {
    // Convert entity to model
    final model = SlotTimingModel(
      id: entity.id,
      vendorId: entity.vendorId,
      availability: entity.availability,
      updatedAt: entity.updatedAt,
    );
    return await remoteDataSource.updateSlotTimings(id, model);
  }

  @override
  Future<List<VendorVacationEntity>> getVacationCalendar({
    required int month,
    required int year,
  }) async {
    return await remoteDataSource.getVacationCalendar(
      month: month,
      year: year,
    );
  }

  @override
  Future<bool> saveVacation(VendorVacationEntity entity) async {
    final model = VendorVacationModel(
      id: entity.id,
      date: entity.date,
      parsedDate: entity.parsedDate,
      startDate: entity.startDate,
      endDate: entity.endDate,
      reason: entity.reason,
      status: entity.status,
      type: entity.type,
      isClosed: entity.isClosed,
      weekDay: entity.weekDay,
      vendorId: entity.vendorId,
      dates: entity.dates,
    );
    return await remoteDataSource.saveVacation(model);
  }

  @override
  Future<bool> deleteVacation(String id) async {
    return await remoteDataSource.deleteVacation(id);
  }
}
