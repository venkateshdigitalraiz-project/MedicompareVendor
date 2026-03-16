import '../../domain/entities/slot_timing_entity.dart';

abstract class SlotsEvent {}

class GetSlotTimingsEvent extends SlotsEvent {}

class UpdateSlotTimingsEvent extends SlotsEvent {
  final String id;
  final SlotTimingEntity entity;

  UpdateSlotTimingsEvent({required this.id, required this.entity});
}
