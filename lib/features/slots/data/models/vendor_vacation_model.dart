import '../../domain/entities/vendor_vacation_entity.dart';

class VendorVacationModel extends VendorVacationEntity {
  const VendorVacationModel({
    required super.id,
    super.date,
    super.parsedDate,
    super.startDate,
    super.endDate,
    super.reason,
    super.status,
    super.type,
    super.isClosed,
    super.weekDay,
    super.vendorId,
    super.dates,
  });

  factory VendorVacationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseFlexibleDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      final str = value.toString().trim();
      if (str.isEmpty || str == 'null') return null;
      try {
        return DateTime.parse(str);
      } catch (_) {
        try {
          if (str.contains('-')) {
            final parts = str.split('-');
            if (parts.length == 3 && parts[2].length == 4) {
              return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            }
          } else if (str.contains('/')) {
            final parts = str.split('/');
            if (parts.length == 3 && parts[2].length == 4) {
              return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
            }
          }
        } catch (_) {}
        return null;
      }
    }

    final idRaw = json['_id'] ?? json['id'];
    final id = (idRaw == null || idRaw.toString().trim() == 'null')
        ? ''
        : idRaw.toString().trim();

    final dateStr = json['date']?.toString() ?? json['day']?.toString();
    final pDate = parseFlexibleDate(json['date'] ?? json['day']);
    final sDate = parseFlexibleDate(json['startDate'] ?? json['start_date']);
    final eDate = parseFlexibleDate(json['endDate'] ?? json['end_date']);

    // Check isClosed explicitly from API
    final isClosed = json['isClosed'] == true;
    final weekDay = json['weekDay']?.toString();
    final vendorId = (json['vendorId'] ?? '').toString().trim();

    // Check vacationReason FIRST (from the API: "vacationReason": "DASARA Holiday")
    final rawReason = json['vacationReason'] ??
        json['reason'] ??
        json['holidayName'] ??
        json['holiday'] ??
        json['note'] ??
        json['title'] ??
        json['description'] ??
        json['name'];

    String reason = '';
    if (rawReason != null &&
        rawReason.toString().trim().isNotEmpty &&
        rawReason.toString().trim() != 'null') {
      reason = rawReason.toString().trim();
    } else if (isClosed || id.isNotEmpty) {
      reason = 'Holiday';
    }

    final rawType = json['vacationType'] ?? json['type'] ?? json['holidayType'];
    final type = (rawType != null &&
            rawType.toString().trim().isNotEmpty &&
            rawType.toString().trim() != 'null')
        ? rawType.toString().trim()
        : '';

    List<String>? datesList;
    if (json['dates'] is List) {
      datesList = (json['dates'] as List).map((e) => e.toString()).toList();
    }

    return VendorVacationModel(
      id: id,
      date: dateStr,
      parsedDate: pDate,
      startDate: sDate,
      endDate: eDate,
      reason: reason,
      status: (json['status'] ?? 'active').toString(),
      type: type,
      isClosed: isClosed,
      weekDay: weekDay,
      vendorId: vendorId,
      dates: datesList,
    );
  }

  Map<String, dynamic> toJson({String? overrideVendorId}) {
    String formatDate(DateTime d) =>
        "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

    final sDateStr = startDate != null
        ? formatDate(startDate!)
        : (date != null && date!.length >= 10 ? date!.substring(0, 10) : (date ?? ''));

    final eDateStr = endDate != null
        ? formatDate(endDate!)
        : sDateStr;

    final actualVendorId = (overrideVendorId != null && overrideVendorId.isNotEmpty)
        ? overrideVendorId
        : vendorId;

    // 2. Group Holiday / Date Range
    if (type.toUpperCase() == 'GROUP' || type.toLowerCase() == 'group') {
      List<String> dateList;
      if (dates != null && dates!.isNotEmpty) {
        dateList = dates!;
      } else if (startDate != null && endDate != null) {
        dateList = [];
        DateTime cur = DateTime(startDate!.year, startDate!.month, startDate!.day);
        final stop = DateTime(endDate!.year, endDate!.month, endDate!.day);
        while (!cur.isAfter(stop)) {
          dateList.add(formatDate(cur));
          cur = DateTime(cur.year, cur.month, cur.day + 1);
        }
      } else {
        dateList = [sDateStr];
      }

      return {
        'name': reason,
        'type': 'GROUP',
        'dates': dateList,
      };
    }

    // 3. Working Day (Open for Booking)
    if (!isClosed || type.toLowerCase() == 'working') {
      return {
        'vendorId': actualVendorId,
        'startDate': sDateStr,
        'endDate': eDateStr,
        'isClosed': false,
        '_id': '',
      };
    }

    // 1. Single Day Holiday (Default)
    return {
      'vendorId': actualVendorId,
      'startDate': sDateStr,
      'endDate': eDateStr,
      'vacationReason': reason,
      'vacationType': 'single',
      'type': 'single',
      'holidayType': 'single',
      'isClosed': true,
      '_id': id,
    };
  }
}
