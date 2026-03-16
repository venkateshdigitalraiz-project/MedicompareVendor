import '../../domain/entities/slot_timing_entity.dart';
import '../../domain/repositories/slots_repository.dart';
import '../data_sources/slots_remote_data_source.dart';

class SlotsRepositoryImpl implements SlotsRepository {
  final SlotsRemoteDataSource remoteDataSource;

  SlotsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SlotTimingEntity>> getSlotTimings() async {
    return await remoteDataSource.getSlotTimings();
  }
}
