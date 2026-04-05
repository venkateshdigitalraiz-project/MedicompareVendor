import '../../domain/entities/slot_timing_entity.dart';
import '../../domain/repositories/slots_repository.dart';
import '../data_sources/slots_remote_data_source.dart';
import '../models/slot_timing_model.dart';

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
}
