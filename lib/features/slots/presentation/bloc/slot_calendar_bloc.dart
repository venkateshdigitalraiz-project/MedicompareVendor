import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/vendor_vacation_entity.dart';
import '../../domain/usecases/get_vacation_calendar_usecase.dart';
import '../../domain/usecases/save_vacation_usecase.dart';
import '../../domain/usecases/delete_vacation_usecase.dart';
import 'slot_calendar_event.dart';
import 'slot_calendar_state.dart';

class SlotCalendarBloc extends Bloc<SlotCalendarEvent, SlotCalendarState> {
  final GetVacationCalendarUseCase? getVacationCalendarUseCase;
  final SaveVacationUseCase? saveVacationUseCase;
  final DeleteVacationUseCase? deleteVacationUseCase;

  SlotCalendarBloc({
    this.getVacationCalendarUseCase,
    this.saveVacationUseCase,
    this.deleteVacationUseCase,
    DateTime? initialDate,
  }) : super(SlotCalendarState(
          selectedDate: initialDate ?? DateTime.now(),
          focusedMonth: DateTime(
            (initialDate ?? DateTime.now()).year,
            (initialDate ?? DateTime.now()).month,
            1,
          ),
        )) {
    on<SelectCalendarDateEvent>(_onSelectDate);
    on<ChangeCalendarMonthEvent>(_onChangeMonth);
    on<NextCalendarMonthEvent>(_onNextMonth);
    on<PreviousCalendarMonthEvent>(_onPreviousMonth);
    on<JumpToTodayEvent>(_onJumpToToday);
    on<FetchVacationCalendarEvent>(_onFetchVacationCalendar);
    on<SaveVacationEvent>(_onSaveVacation);
    on<DeleteVacationEvent>(_onDeleteVacation);
  }

  void _onSelectDate(
    SelectCalendarDateEvent event,
    Emitter<SlotCalendarState> emit,
  ) {
    final newMonth = DateTime(event.date.year, event.date.month, 1);
    final monthChanged = newMonth.year != state.focusedMonth.year ||
        newMonth.month != state.focusedMonth.month;

    emit(state.copyWith(
      selectedDate: event.date,
      focusedMonth: newMonth,
    ));

    if (monthChanged) {
      add(FetchVacationCalendarEvent(
        month: newMonth.month,
        year: newMonth.year,
      ));
    }
  }

  void _onChangeMonth(
    ChangeCalendarMonthEvent event,
    Emitter<SlotCalendarState> emit,
  ) {
    final newMonth = DateTime(event.month.year, event.month.month, 1);
    emit(state.copyWith(
      focusedMonth: newMonth,
    ));
    add(FetchVacationCalendarEvent(
      month: newMonth.month,
      year: newMonth.year,
    ));
  }

  void _onNextMonth(
    NextCalendarMonthEvent event,
    Emitter<SlotCalendarState> emit,
  ) {
    final current = state.focusedMonth;
    final nextMonth = DateTime(current.year, current.month + 1, 1);
    emit(state.copyWith(focusedMonth: nextMonth));
    add(FetchVacationCalendarEvent(
      month: nextMonth.month,
      year: nextMonth.year,
    ));
  }

  void _onPreviousMonth(
    PreviousCalendarMonthEvent event,
    Emitter<SlotCalendarState> emit,
  ) {
    final current = state.focusedMonth;
    final prevMonth = DateTime(current.year, current.month - 1, 1);
    emit(state.copyWith(focusedMonth: prevMonth));
    add(FetchVacationCalendarEvent(
      month: prevMonth.month,
      year: prevMonth.year,
    ));
  }

  void _onJumpToToday(
    JumpToTodayEvent event,
    Emitter<SlotCalendarState> emit,
  ) {
    final now = DateTime.now();
    final todayMonth = DateTime(now.year, now.month, 1);
    emit(state.copyWith(
      selectedDate: now,
      focusedMonth: todayMonth,
    ));
    add(FetchVacationCalendarEvent(
      month: todayMonth.month,
      year: todayMonth.year,
    ));
  }

  Future<void> _onFetchVacationCalendar(
    FetchVacationCalendarEvent event,
    Emitter<SlotCalendarState> emit,
  ) async {
    if (getVacationCalendarUseCase == null) return;
    emit(state.copyWith(isLoadingVacations: true, vacationsError: null));
    try {
      final vacations = await getVacationCalendarUseCase!(
        month: event.month,
        year: event.year,
      );
      emit(state.copyWith(
        vacations: vacations,
        isLoadingVacations: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingVacations: false,
        vacationsError: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> _onSaveVacation(
    SaveVacationEvent event,
    Emitter<SlotCalendarState> emit,
  ) async {
    // 1. Optimistic state update: Replace or add vacation
    final currentList = List<VendorVacationEntity>.from(state.vacations);
    currentList.removeWhere((v) {
      if (event.vacation.parsedDate != null &&
          v.matchesDate(event.vacation.parsedDate!)) {
        return true;
      }
      if (event.vacation.startDate != null &&
          v.matchesDate(event.vacation.startDate!)) {
        return true;
      }
      return false;
    });
    if (event.vacation.isClosed ||
        event.vacation.type.toUpperCase() == 'GROUP') {
      currentList.add(event.vacation);
    }
    emit(state.copyWith(vacations: currentList));

    // 2. Perform remote save and refresh calendar from server upon success
    if (saveVacationUseCase != null) {
      try {
        final success = await saveVacationUseCase!(event.vacation);
        if (success) {
          final targetMonth = event.vacation.startDate?.month ??
              event.vacation.parsedDate?.month ??
              state.focusedMonth.month;
          final targetYear = event.vacation.startDate?.year ??
              event.vacation.parsedDate?.year ??
              state.focusedMonth.year;
          add(FetchVacationCalendarEvent(
            month: targetMonth,
            year: targetYear,
          ));
        }
      } catch (_) {}
    }
  }

  Future<void> _onDeleteVacation(
    DeleteVacationEvent event,
    Emitter<SlotCalendarState> emit,
  ) async {
    // 1. Optimistic state update: Remove matching vacation
    final currentList = List<VendorVacationEntity>.from(state.vacations);
    currentList.removeWhere((v) =>
        (event.vacationId.isNotEmpty && v.id == event.vacationId) ||
        v.matchesDate(event.date));
    emit(state.copyWith(vacations: currentList));

    // 2. Perform remote delete and refresh calendar from server upon success
    if (deleteVacationUseCase != null && event.vacationId.isNotEmpty) {
      try {
        final success = await deleteVacationUseCase!(event.vacationId);
        if (success) {
          add(FetchVacationCalendarEvent(
            month: event.date.month,
            year: event.date.year,
          ));
        }
      } catch (_) {}
    }
  }
}
