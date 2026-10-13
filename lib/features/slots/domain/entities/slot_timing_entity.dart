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

  SlotTimingEntity copyWith({
    String? id,
    String? vendorId,
    List<DayAvailabilityEntity>? availability,
    DateTime? updatedAt,
  }) {
    return SlotTimingEntity(
      id: id ?? this.id,
      vendorId: vendorId ?? this.vendorId,
      availability: availability ?? this.availability,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  DayAvailabilityEntity? getAvailabilityForDate(DateTime date) {
    const dayNames = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    final target = dayNames[date.weekday - 1];
    for (final a in availability) {
      final dayLower = a.day.trim().toLowerCase();
      if (dayLower == target || dayLower.startsWith(target.substring(0, 3))) {
        return a;
      }
    }
    return DayAvailabilityEntity(
      day: target[0].toUpperCase() + target.substring(1),
      isOpen: false,
      startTime: '',
      endTime: '',
      id: '',
      shifts: const [],
    );
  }
}

class DayShiftSlotEntity {
  final String id;
  final String slot; // e.g. "09:00 - 10:00"
  final String startTime;
  final String endTime;
  final int allottedSlots;
  final int bookedSlots;
  final bool isAvailable;

  DayShiftSlotEntity({
    this.id = '',
    required this.slot,
    required this.startTime,
    required this.endTime,
    required this.allottedSlots,
    this.bookedSlots = 0,
    this.isAvailable = true,
  });

  DayShiftSlotEntity copyWith({
    String? id,
    String? slot,
    String? startTime,
    String? endTime,
    int? allottedSlots,
    int? bookedSlots,
    bool? isAvailable,
  }) {
    return DayShiftSlotEntity(
      id: id ?? this.id,
      slot: slot ?? this.slot,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      allottedSlots: allottedSlots ?? this.allottedSlots,
      bookedSlots: bookedSlots ?? this.bookedSlots,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class DayShiftEntity {
  final String id;
  final String shiftType; // 'morning', 'afternoon', 'evening', 'night'
  final String shiftName;
  final bool isOpen;
  final String? startTime;
  final String? endTime;
  final int slotInterval;
  final int capacity;
  final List<DayShiftSlotEntity> slots;

  DayShiftEntity({
    this.id = '',
    required this.shiftType,
    required this.shiftName,
    required this.isOpen,
    this.startTime,
    this.endTime,
    this.slotInterval = 60,
    this.capacity = 5,
    List<DayShiftSlotEntity>? slots,
  }) : slots = slots ??
            (isOpen && startTime != null && endTime != null
                ? generateSlots(startTime, endTime, slotInterval, capacity)
                : const []);

  // Backwards compatibility getters
  String get type => shiftType;
  String get title => shiftName;
  bool get isEnabled => isOpen;
  int get intervalMinutes => slotInterval;

  DayShiftEntity copyWith({
    String? id,
    String? shiftType,
    String? shiftName,
    bool? isOpen,
    bool? isEnabled,
    String? startTime,
    String? endTime,
    int? slotInterval,
    int? intervalMinutes,
    int? capacity,
    List<DayShiftSlotEntity>? slots,
    bool clearTimes = false,
  }) {
    final newIsOpen = isOpen ?? isEnabled ?? this.isOpen;
    final newStart = clearTimes ? null : (startTime ?? this.startTime);
    final newEnd = clearTimes ? null : (endTime ?? this.endTime);
    final newInterval = slotInterval ?? intervalMinutes ?? this.slotInterval;
    final newCap = capacity ?? this.capacity;

    return DayShiftEntity(
      id: id ?? this.id,
      shiftType: shiftType ?? this.shiftType,
      shiftName: shiftName ?? this.shiftName,
      isOpen: newIsOpen,
      startTime: newStart,
      endTime: newEnd,
      slotInterval: newInterval,
      capacity: newCap,
      slots: slots ??
          (newIsOpen && newStart != null && newEnd != null
              ? generateSlots(newStart, newEnd, newInterval, newCap,
                  existingSlots: this.slots)
              : const []),
    );
  }

  static List<DayShiftSlotEntity> generateSlots(
    String startStr,
    String endStr,
    int intervalMinutes,
    int capacity, {
    List<DayShiftSlotEntity>? existingSlots,
  }) {
    if (intervalMinutes <= 0) return [];
    try {
      final sParts =
          startStr.replaceAll('AM', '').replaceAll('PM', '').trim().split(':');
      final eParts =
          endStr.replaceAll('AM', '').replaceAll('PM', '').trim().split(':');
      int startMin = int.parse(sParts[0]) * 60 + int.parse(sParts[1]);
      int endMin = int.parse(eParts[0]) * 60 + int.parse(eParts[1]);

      if (endMin <= startMin) {
        endMin += 24 * 60;
      }

      final List<DayShiftSlotEntity> list = [];
      int current = startMin;
      while (current + intervalMinutes <= endMin) {
        final sH = ((current ~/ 60) % 24).toString().padLeft(2, '0');
        final sM = (current % 60).toString().padLeft(2, '0');
        final next = current + intervalMinutes;
        final eH = ((next ~/ 60) % 24).toString().padLeft(2, '0');
        final eM = (next % 60).toString().padLeft(2, '0');
        final sTime = "$sH:$sM";
        final eTime = "$eH:$eM";
        final slotLabel = "$sTime - $eTime";

        String existingId = '';
        int booked = 0;
        if (existingSlots != null && existingSlots.isNotEmpty) {
          final found = existingSlots.firstWhere(
            (e) =>
                e.slot == slotLabel ||
                (e.startTime == sTime && e.endTime == eTime),
            orElse: () => DayShiftSlotEntity(
              slot: '',
              startTime: '',
              endTime: '',
              allottedSlots: capacity,
            ),
          );
          if (found.id.isNotEmpty) {
            existingId = found.id;
          }
          booked = found.bookedSlots;
        }

        list.add(DayShiftSlotEntity(
          id: existingId,
          slot: slotLabel,
          startTime: sTime,
          endTime: eTime,
          allottedSlots: capacity,
          bookedSlots: booked,
          isAvailable: true,
        ));
        current += intervalMinutes;
      }
      return list;
    } catch (_) {
      return [];
    }
  }
}

class DayAvailabilityEntity {
  final String day;
  final bool isOpen;
  final String startTime;
  final String endTime;
  final String id;
  final List<DayShiftEntity> shifts;

  DayAvailabilityEntity({
    required this.day,
    required this.isOpen,
    required this.startTime,
    required this.endTime,
    required this.id,
    List<DayShiftEntity>? shifts,
  }) : shifts = shifts ?? defaultShiftsForDay(day, startTime, endTime, isOpen);

  int get activeShiftsCount => shifts.where((s) => s.isOpen).length;

  int get totalSlots {
    int total = 0;
    for (final s in shifts.where((s) => s.isOpen)) {
      final slotsList = s.slots.isNotEmpty
          ? s.slots
          : (s.startTime != null && s.endTime != null
              ? DayShiftEntity.generateSlots(
                  s.startTime!, s.endTime!, s.slotInterval, s.capacity)
              : <DayShiftSlotEntity>[]);
      total += slotsList.length;
    }
    return total;
  }

  int get totalCapacity {
    int capacity = 0;
    for (final s in shifts.where((s) => s.isOpen)) {
      final slotsList = s.slots.isNotEmpty
          ? s.slots
          : (s.startTime != null && s.endTime != null
              ? DayShiftEntity.generateSlots(
                  s.startTime!, s.endTime!, s.slotInterval, s.capacity)
              : <DayShiftSlotEntity>[]);
      capacity +=
          slotsList.fold<int>(0, (sum, slot) => sum + slot.allottedSlots);
    }
    return capacity;
  }

  DayAvailabilityEntity copyWith({
    String? day,
    bool? isOpen,
    String? startTime,
    String? endTime,
    String? id,
    List<DayShiftEntity>? shifts,
  }) {
    return DayAvailabilityEntity(
      day: day ?? this.day,
      isOpen: isOpen ?? this.isOpen,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      id: id ?? this.id,
      shifts: shifts ?? this.shifts.map((s) => s.copyWith()).toList(),
    );
  }

  static List<DayShiftEntity> defaultShiftsForDay(
    String day,
    String startTime,
    String endTime,
    bool isOpen,
  ) {
    return [
      DayShiftEntity(
        shiftType: 'morning',
        shiftName: 'Morning Shift',
        isOpen: true,
        startTime: '09:00',
        endTime: '13:00',
        slotInterval: 60,
        capacity: 5,
      ),
      DayShiftEntity(
        shiftType: 'afternoon',
        shiftName: 'Afternoon Shift',
        isOpen: true,
        startTime: '13:00',
        endTime: '14:00',
        slotInterval: 60,
        capacity: 5,
      ),
      DayShiftEntity(
        shiftType: 'evening',
        shiftName: 'Evening Shift',
        isOpen: false,
        startTime: null,
        endTime: null,
        slotInterval: 60,
        capacity: 5,
      ),
      DayShiftEntity(
        shiftType: 'night',
        shiftName: 'Night Shift',
        isOpen: false,
        startTime: null,
        endTime: null,
        slotInterval: 60,
        capacity: 5,
      ),
    ];
  }
}



