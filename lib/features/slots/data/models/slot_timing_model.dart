import '../../domain/entities/slot_timing_entity.dart';

class SlotTimingModel extends SlotTimingEntity {
  SlotTimingModel({
    required super.id,
    required super.vendorId,
    required super.availability,
    required super.updatedAt,
  });

  factory SlotTimingModel.fromJson(Map<String, dynamic> json) {
    return SlotTimingModel(
      id: json['_id'] ?? json['id'] ?? '',
      vendorId: json['vendorId'] ?? '',
      availability: (json['availability'] as List? ?? [])
          .map((e) => DayAvailabilityModel.fromJson(e))
          .toList(),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorId': vendorId,
      'availability': availability.map((e) {
        if (e is DayAvailabilityModel) {
          return e.toJson();
        }
        return {
          'day': e.day,
          'isOpen': e.isOpen,
          if (e.id.isNotEmpty) '_id': e.id,
          'shifts': e.shifts.map((s) {
            return {
              'shiftType': s.shiftType,
              'shiftName': s.shiftName,
              'isOpen': s.isOpen,
              'startTime': s.isOpen ? s.startTime : null,
              'endTime': s.isOpen ? s.endTime : null,
              'slotInterval': s.slotInterval,
              'capacity': s.capacity,
              'slots': s.isOpen
                  ? s.slots.map((slot) {
                      final map = {
                        'slot': slot.slot,
                        'startTime': slot.startTime,
                        'endTime': slot.endTime,
                        'allottedSlots': slot.allottedSlots,
                        'bookedSlots': slot.bookedSlots,
                        'isAvailable': slot.isAvailable,
                      };
                      if (slot.id.isNotEmpty) {
                        map['_id'] = slot.id;
                      }
                      return map;
                    }).toList()
                  : [],
              if (s.id.isNotEmpty) '_id': s.id,
            };
          }).toList(),
        };
      }).toList(),
    };
  }
}

class DayShiftSlotModel extends DayShiftSlotEntity {
  DayShiftSlotModel({
    super.id,
    required super.slot,
    required super.startTime,
    required super.endTime,
    required super.allottedSlots,
    super.bookedSlots,
    super.isAvailable,
  });

  factory DayShiftSlotModel.fromJson(Map<String, dynamic> json) {
    return DayShiftSlotModel(
      id: json['_id'] ?? json['id'] ?? '',
      slot: json['slot'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      allottedSlots: json['allottedSlots'] ?? 5,
      bookedSlots: json['bookedSlots'] ?? 0,
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slot': slot,
      'startTime': startTime,
      'endTime': endTime,
      'allottedSlots': allottedSlots,
      'bookedSlots': bookedSlots,
      'isAvailable': isAvailable,
      if (id.isNotEmpty) '_id': id,
    };
  }
}

class DayShiftModel extends DayShiftEntity {
  DayShiftModel({
    super.id,
    required super.shiftType,
    required super.shiftName,
    required super.isOpen,
    super.startTime,
    super.endTime,
    super.slotInterval,
    super.capacity,
    super.slots,
  });

  factory DayShiftModel.fromJson(Map<String, dynamic> json) {
    final sType = (json['shiftType'] ?? json['type'] ?? 'morning').toString();
    String defaultTitle;
    switch (sType.toLowerCase()) {
      case 'afternoon':
        defaultTitle = 'Afternoon Shift';
        break;
      case 'evening':
        defaultTitle = 'Evening Shift';
        break;
      case 'night':
        defaultTitle = 'Night Shift';
        break;
      case 'morning':
      default:
        defaultTitle = 'Morning Shift';
        break;
    }

    final sName = (json['shiftName'] != null && json['shiftName'].toString().isNotEmpty)
        ? json['shiftName'].toString()
        : (json['title'] != null && json['title'].toString().isNotEmpty)
            ? json['title'].toString()
            : defaultTitle;

    final open = json['isOpen'] ?? json['isEnabled'] ?? json['active'] ?? false;
    final start = json['startTime'];
    final end = json['endTime'];
    final interval = json['slotInterval'] ?? json['intervalMinutes'] ?? 60;
    final cap = json['capacity'] ?? json['capacityPerSlot'] ?? 5;

    List<DayShiftSlotEntity>? parsedSlots;
    if (json['slots'] != null && json['slots'] is List) {
      parsedSlots = (json['slots'] as List)
          .map((e) => DayShiftSlotModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return DayShiftModel(
      id: json['_id'] ?? json['id'] ?? '',
      shiftType: sType,
      shiftName: sName,
      isOpen: open,
      startTime: start,
      endTime: end,
      slotInterval: interval,
      capacity: cap,
      slots: parsedSlots,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiftType': shiftType,
      'shiftName': shiftName,
      'isOpen': isOpen,
      'startTime': isOpen ? startTime : null,
      'endTime': isOpen ? endTime : null,
      'slotInterval': slotInterval,
      'capacity': capacity,
      'slots': isOpen
          ? slots.map((s) {
              if (s is DayShiftSlotModel) {
                return s.toJson();
              }
              final map = {
                'slot': s.slot,
                'startTime': s.startTime,
                'endTime': s.endTime,
                'allottedSlots': s.allottedSlots,
                'bookedSlots': s.bookedSlots,
                'isAvailable': s.isAvailable,
              };
              if (s.id.isNotEmpty) map['_id'] = s.id;
              return map;
            }).toList()
          : [],
      if (id.isNotEmpty) '_id': id,
    };
  }
}

class DayAvailabilityModel extends DayAvailabilityEntity {
  DayAvailabilityModel({
    required super.day,
    required super.isOpen,
    required super.startTime,
    required super.endTime,
    required super.id,
    super.shifts,
  });

  factory DayAvailabilityModel.fromJson(Map<String, dynamic> json) {
    List<DayShiftEntity>? parsedShifts;
    if (json['shifts'] != null && json['shifts'] is List && (json['shifts'] as List).isNotEmpty) {
      parsedShifts = (json['shifts'] as List)
          .map((e) => DayShiftModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    final day = json['day'] ?? '';
    final isOpen = json['isOpen'] ?? true;
    final startTime = json['startTime'] ?? '09:00';
    final endTime = json['endTime'] ?? '17:00';

    return DayAvailabilityModel(
      day: day,
      isOpen: isOpen,
      startTime: startTime,
      endTime: endTime,
      id: json['_id'] ?? json['id'] ?? '',
      shifts: (parsedShifts != null && parsedShifts.isNotEmpty)
          ? parsedShifts
          : DayAvailabilityEntity.defaultShiftsForDay(day, startTime, endTime, isOpen),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'isOpen': isOpen,
      if (id.isNotEmpty) '_id': id,
      'shifts': shifts.map((s) {
        if (s is DayShiftModel) {
          return s.toJson();
        }
        return {
          'shiftType': s.shiftType,
          'shiftName': s.shiftName,
          'isOpen': s.isOpen,
          'startTime': s.isOpen ? s.startTime : null,
          'endTime': s.isOpen ? s.endTime : null,
          'slotInterval': s.slotInterval,
          'capacity': s.capacity,
          'slots': s.isOpen
              ? s.slots.map((slot) {
                  final map = {
                    'slot': slot.slot,
                    'startTime': slot.startTime,
                    'endTime': slot.endTime,
                    'allottedSlots': slot.allottedSlots,
                    'bookedSlots': slot.bookedSlots,
                    'isAvailable': slot.isAvailable,
                  };
                  if (slot.id.isNotEmpty) map['_id'] = slot.id;
                  return map;
                }).toList()
              : [],
          if (s.id.isNotEmpty) '_id': s.id,
        };
      }).toList(),
    };
  }
}


