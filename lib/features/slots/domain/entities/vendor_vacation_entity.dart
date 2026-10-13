import 'package:equatable/equatable.dart';

class VendorVacationEntity extends Equatable {
  final String id;
  final String? date;
  final DateTime? parsedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String reason;
  final String status;
  final String type;
  final bool isClosed;
  final String? weekDay;
  final String vendorId;
  final List<String>? dates;

  const VendorVacationEntity({
    required this.id,
    this.date,
    this.parsedDate,
    this.startDate,
    this.endDate,
    this.reason = 'Vacation',
    this.status = 'active',
    this.type = 'vacation',
    this.isClosed = false,
    this.weekDay,
    this.vendorId = '',
    this.dates,
  });

  /// Indicates if this entry represents an actual holiday / vacation
  bool get isVacation {
    if (type.toLowerCase() == 'working') return false;
    return isClosed ||
        type.toUpperCase() == 'GROUP' ||
        (reason.isNotEmpty && reason != 'null') ||
        (type.isNotEmpty && type != 'null' && type != 'vacation');
  }

  /// Checks if a given date matches this vacation/holiday entry
  bool matchesDate(DateTime targetDate) {
    final targetStr =
        "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";

    if (dates != null && dates!.isNotEmpty) {
      if (dates!.contains(targetStr)) return true;
    }

    if (parsedDate != null) {
      if (parsedDate!.year == targetDate.year &&
          parsedDate!.month == targetDate.month &&
          parsedDate!.day == targetDate.day) {
        return true;
      }
    }

    if (startDate != null && endDate != null) {
      final check = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final s = DateTime(startDate!.year, startDate!.month, startDate!.day);
      final e = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if ((check.isAtSameMomentAs(s) || check.isAfter(s)) &&
          (check.isAtSameMomentAs(e) || check.isBefore(e))) {
        return true;
      }
    } else if (startDate != null) {
      if (startDate!.year == targetDate.year &&
          startDate!.month == targetDate.month &&
          startDate!.day == targetDate.day) {
        return true;
      }
    } else if (endDate != null) {
      if (endDate!.year == targetDate.year &&
          endDate!.month == targetDate.month &&
          endDate!.day == targetDate.day) {
        return true;
      }
    }

    if (date != null && date!.isNotEmpty) {
      if (date!.contains(targetStr)) return true;

      final dayInt = int.tryParse(date!);
      if (dayInt != null && dayInt == targetDate.day) return true;
    }

    return false;
  }

  @override
  List<Object?> get props => [
        id,
        date,
        parsedDate,
        startDate,
        endDate,
        reason,
        status,
        type,
        isClosed,
        weekDay,
        vendorId,
        dates,
      ];
}
