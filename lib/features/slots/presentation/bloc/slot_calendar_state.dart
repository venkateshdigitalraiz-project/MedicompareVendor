import 'package:equatable/equatable.dart';
import '../../domain/entities/vendor_vacation_entity.dart';

class SlotCalendarState extends Equatable {
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final List<VendorVacationEntity> vacations;
  final bool isLoadingVacations;
  final String? vacationsError;

  const SlotCalendarState({
    required this.selectedDate,
    required this.focusedMonth,
    this.vacations = const [],
    this.isLoadingVacations = false,
    this.vacationsError,
  });

  SlotCalendarState copyWith({
    DateTime? selectedDate,
    DateTime? focusedMonth,
    List<VendorVacationEntity>? vacations,
    bool? isLoadingVacations,
    String? vacationsError,
  }) {
    return SlotCalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      focusedMonth: focusedMonth ?? this.focusedMonth,
      vacations: vacations ?? this.vacations,
      isLoadingVacations: isLoadingVacations ?? this.isLoadingVacations,
      vacationsError: vacationsError ?? this.vacationsError,
    );
  }

  @override
  List<Object?> get props => [
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        focusedMonth.year,
        focusedMonth.month,
        vacations,
        isLoadingVacations,
        vacationsError,
      ];
}
