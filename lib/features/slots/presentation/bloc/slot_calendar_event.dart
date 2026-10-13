import 'package:equatable/equatable.dart';
import '../../domain/entities/vendor_vacation_entity.dart';

abstract class SlotCalendarEvent extends Equatable {
  const SlotCalendarEvent();

  @override
  List<Object?> get props => [];
}

class SelectCalendarDateEvent extends SlotCalendarEvent {
  final DateTime date;

  const SelectCalendarDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

class ChangeCalendarMonthEvent extends SlotCalendarEvent {
  final DateTime month;

  const ChangeCalendarMonthEvent(this.month);

  @override
  List<Object?> get props => [month];
}

class NextCalendarMonthEvent extends SlotCalendarEvent {
  const NextCalendarMonthEvent();
}

class PreviousCalendarMonthEvent extends SlotCalendarEvent {
  const PreviousCalendarMonthEvent();
}

class JumpToTodayEvent extends SlotCalendarEvent {
  const JumpToTodayEvent();
}

class FetchVacationCalendarEvent extends SlotCalendarEvent {
  final int month;
  final int year;

  const FetchVacationCalendarEvent({
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [month, year];
}

class SaveVacationEvent extends SlotCalendarEvent {
  final VendorVacationEntity vacation;

  const SaveVacationEvent(this.vacation);

  @override
  List<Object?> get props => [vacation];
}

class DeleteVacationEvent extends SlotCalendarEvent {
  final String vacationId;
  final DateTime date;

  const DeleteVacationEvent({
    required this.vacationId,
    required this.date,
  });

  @override
  List<Object?> get props => [vacationId, date];
}
