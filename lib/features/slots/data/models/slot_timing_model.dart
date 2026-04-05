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
      id: json['_id'] ?? '',
      vendorId: json['vendorId'] ?? '',
      availability: (json['availability'] as List)
          .map((e) => DayAvailabilityModel.fromJson(e))
          .toList(),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'availability': availability
          .map((e) => {
                'day': e.day,
                'isOpen': e.isOpen,
                'startTime': e.startTime,
                'endTime': e.endTime,
              })
          .toList(),
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
  });

  factory DayAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return DayAvailabilityModel(
      day: json['day'] ?? '',
      isOpen: json['isOpen'] ?? false,
      startTime: json['startTime'] ?? '09:00',
      endTime: json['endTime'] ?? '17:00',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'isOpen': isOpen,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
