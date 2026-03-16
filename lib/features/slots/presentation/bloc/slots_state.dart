import '../../domain/entities/slot_timing_entity.dart';

abstract class SlotsState {}

class SlotsInitial extends SlotsState {}

class SlotsLoading extends SlotsState {}

class SlotsLoaded extends SlotsState {
  final List<SlotTimingEntity> timings;

  SlotsLoaded({required this.timings});
}

class SlotsUpdated extends SlotsState {
  final SlotTimingEntity timing;

  SlotsUpdated({required this.timing});
}

class SlotsError extends SlotsState {
  final String message;

  SlotsError({required this.message});
}
