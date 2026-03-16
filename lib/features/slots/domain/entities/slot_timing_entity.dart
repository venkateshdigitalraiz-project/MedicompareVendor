class SlotTimingEntity {
  final String id;
  final String vendorId;
  final List<DayAvailabilityEntity> availability;
  final DateTime updatedAt;

  SlotTimingEntity({
    required this.id,
    required this.vendorId,
    required this.availability,
    required this.updatedAt,
  });
}

class DayAvailabilityEntity {
  final String day;
  final bool isOpen;
  final String startTime;
  final String endTime;
  final String id;

  DayAvailabilityEntity({
    required this.day,
    required this.isOpen,
    required this.startTime,
    required this.endTime,
    required this.id,
  });
}
