import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/slot_timing_entity.dart';
import '../../domain/entities/vendor_vacation_entity.dart';
import '../bloc/slot_calendar_bloc.dart';
import '../bloc/slot_calendar_event.dart';
import '../bloc/slot_calendar_state.dart';
import '../pages/configure_availability_page.dart';
import '../bloc/slots_bloc.dart';
import '../bloc/slots_event.dart';
import 'manage_vacation_dialog.dart';

class CustomSlotCalendar extends StatelessWidget {
  final SlotTimingEntity parentTiming;

  const CustomSlotCalendar({
    super.key,
    required this.parentTiming,
  });

  static const List<String> _weekdayLabels = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SlotCalendarBloc, SlotCalendarState>(
      builder: (context, state) {
        final focusedMonth = state.focusedMonth;
        final selectedDate = state.selectedDate;

        final selectedDayAvailability =
            parentTiming.getAvailabilityForDate(selectedDate);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CALENDAR HEADER: Month Navigator & Legend
              _buildMonthNavigator(
                context,
                focusedMonth,
                selectedDate,
                state.isLoadingVacations,
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // 2. CALENDAR GRID
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildWeekdayHeader(),
                    const SizedBox(height: 10),
                    _buildDaysGrid(
                      context: context,
                      focusedMonth: focusedMonth,
                      selectedDate: selectedDate,
                      vacations: state.vacations,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // 3. SELECTED DAY SLOTS INSPECTOR
              _buildSelectedDayInspector(
                context: context,
                selectedDate: selectedDate,
                availability: selectedDayAvailability,
                vacations: state.vacations,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMonthNavigator(
    BuildContext context,
    DateTime focusedMonth,
    DateTime selectedDate,
    bool isLoadingVacations,
  ) {
    final monthTitle = DateFormat('MMMM yyyy').format(focusedMonth);
    final now = DateTime.now();
    final isCurrentMonth =
        focusedMonth.year == now.year && focusedMonth.month == now.month;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Calendar Icon + Month Title + Optional Vacation loading indicator
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        monthTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    if (isLoadingVacations) ...[
                      const SizedBox(width: 8),
                      const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Right Controls: Previous Month, Jump to Today, Next Month
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isCurrentMonth)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: InkWell(
                        onTap: () {
                          context
                              .read<SlotCalendarBloc>()
                              .add(const JumpToTodayEvent());
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Text(
                            "Today",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF374151),
                            ),
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    iconSize: 20,
                    tooltip: "Previous Month",
                    onPressed: () {
                      context
                          .read<SlotCalendarBloc>()
                          .add(const PreviousCalendarMonthEvent());
                    },
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    iconSize: 20,
                    tooltip: "Next Month",
                    onPressed: () {
                      context
                          .read<SlotCalendarBloc>()
                          .add(const NextCalendarMonthEvent());
                    },
                    icon: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _legendDot(const Color(0xFF059669), "Available"),
        _legendDot(const Color(0xFFEA580C), "Holiday / Vacation"),
        _legendDot(const Color(0xFF9CA3AF), "Closed"),
        _legendDot(AppColors.primary, "Selected"),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader() {
    return Row(
      children: _weekdayLabels.map((dayLabel) {
        return Expanded(
          child: Center(
            child: Text(
              dayLabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6B7280),
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDaysGrid({
    required BuildContext context,
    required DateTime focusedMonth,
    required DateTime selectedDate,
    required List<VendorVacationEntity> vacations,
  }) {
    final year = focusedMonth.year;
    final month = focusedMonth.month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Monday is 1, Sunday is 7.
    // Leading cells from previous month = firstDayOfMonth.weekday - 1
    final leadingDays = firstDayOfMonth.weekday - 1;
    final daysInPrevMonth = DateTime(year, month, 0).day;

    final totalGridCells = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;
    final now = DateTime.now();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalGridCells,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, index) {
        // Leading month days
        if (index < leadingDays) {
          final prevDay = daysInPrevMonth - (leadingDays - index - 1);
          return _buildInactiveDayCell(prevDay);
        }

        // Current month days
        final dayNumber = index - leadingDays + 1;
        if (dayNumber <= daysInMonth) {
          final cellDate = DateTime(year, month, dayNumber);
          final isToday = _isSameDay(cellDate, now);
          final isSelected = _isSameDay(cellDate, selectedDate);

          final dayAvailability = parentTiming.getAvailabilityForDate(cellDate);
          final isDayOpen = (dayAvailability != null &&
              dayAvailability.isOpen &&
              dayAvailability.activeShiftsCount > 0);

          VendorVacationEntity? matchingVacation;
          for (final v in vacations) {
            if (v.matchesDate(cellDate)) {
              matchingVacation = v;
              break;
            }
          }
          final isVacation =
              matchingVacation != null && matchingVacation.isVacation;
          final vacationReason = matchingVacation?.reason.trim();
          final vacationLabel =
              (vacationReason != null && vacationReason.isNotEmpty)
                  ? vacationReason
                  : (matchingVacation?.type.isNotEmpty == true
                      ? matchingVacation!.type
                      : 'Holiday');

          return _buildActiveDayCell(
            context: context,
            date: cellDate,
            dayNumber: dayNumber,
            isToday: isToday,
            isSelected: isSelected,
            isDayOpen: isDayOpen,
            isVacation: isVacation,
            vacationLabel: isVacation ? vacationLabel : '',
            matchingVacation: matchingVacation,
          );
        }

        // Trailing month days
        final nextDay = dayNumber - daysInMonth;
        return _buildInactiveDayCell(nextDay);
      },
    );
  }

  Widget _buildActiveDayCell({
    required BuildContext context,
    required DateTime date,
    required int dayNumber,
    required bool isToday,
    required bool isSelected,
    required bool isDayOpen,
    required bool isVacation,
    required String vacationLabel,
    VendorVacationEntity? matchingVacation,
  }) {
    Color backgroundColor;
    Color textColor;
    Border? border;

    if (isSelected) {
      backgroundColor = AppColors.primary;
      textColor = Colors.white;
      border = null;
    } else if (isVacation) {
      backgroundColor = const Color(0xFFFFF7ED);
      textColor = const Color(0xFFC2410C);
      border = Border.all(color: const Color(0xFFFED7AA));
    } else if (isToday) {
      backgroundColor = AppColors.primary.withValues(alpha: 0.08);
      textColor = AppColors.primary;
      border = Border.all(color: AppColors.primary, width: 1.5);
    } else {
      backgroundColor = Colors.white;
      textColor = isDayOpen ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF);
      border = Border.all(color: const Color(0xFFF1F5F9));
    }

    // Indicator dot color
    final Color dotColor;
    if (isSelected) {
      dotColor = Colors.white;
    } else if (isVacation) {
      dotColor = const Color(0xFFEA580C);
    } else if (isDayOpen) {
      dotColor = const Color(0xFF059669);
    } else {
      dotColor = const Color(0xFFD1D5DB);
    }

    final cellWidget = InkWell(
      onTap: () {
        context.read<SlotCalendarBloc>().add(SelectCalendarDateEvent(date));
        _openManageVacationDialog(
          context: context,
          date: date,
          vacation: isVacation ? matchingVacation : null,
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: border,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "$dayNumber",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight:
                      isSelected || isToday ? FontWeight.w700 : FontWeight.w600,
                  color: textColor,
                  height: 1.1,
                ),
              ),
            ),
            // ONLY display vacation reason/name if it's an actual vacation
            // If isClosed: false and both vacationReason/vacationType are null, day name does not display!
            if (isVacation && vacationLabel.isNotEmpty) ...[
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Text(
                  vacationLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.95)
                        : const Color(0xFFEA580C),
                    letterSpacing: -0.2,
                    height: 1.0,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 3),
            // Availability / Vacation indicator dot
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
          ],
        ),
      ),
    );

    if (isVacation && vacationLabel.isNotEmpty) {
      return Tooltip(
        message: vacationLabel,
        preferBelow: false,
        child: cellWidget,
      );
    }

    return cellWidget;
  }

  Widget _buildInactiveDayCell(int dayNumber) {
    return Center(
      child: Text(
        "$dayNumber",
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  Widget _buildSelectedDayInspector({
    required BuildContext context,
    required DateTime selectedDate,
    required DayAvailabilityEntity? availability,
    required List<VendorVacationEntity> vacations,
  }) {
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(selectedDate);
    final isOpen = availability != null &&
        availability.isOpen &&
        availability.activeShiftsCount > 0;

    final matchingVacations =
        vacations.where((v) => v.matchesDate(selectedDate)).toList();
    final isVacation = matchingVacations.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inspector Title Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.event_available_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: GoogleFonts.inter(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isOpen
                          ? "${availability.activeShiftsCount} Active Shifts • ${availability.totalSlots} Slots • ${availability.totalCapacity} Total Capacity"
                          : "No active shifts scheduled for this day",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // Status Badge
              if (isVacation)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFDBA74)),
                  ),
                  child: Text(
                    matchingVacations.first.reason.toLowerCase() == 'vacation'
                        ? "VACATION"
                        : "HOLIDAY",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFEA580C),
                    ),
                  ),
                )
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isOpen
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: Text(
                    isOpen ? "OPEN" : "CLOSED",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isOpen
                          ? const Color(0xFF166534)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
            ],
          ),

          if (isVacation) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                _openManageVacationDialog(
                  context: context,
                  date: selectedDate,
                  vacation: matchingVacations.first,
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDBA74)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.beach_access_rounded,
                        size: 18, color: Color(0xFFEA580C)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Holiday / Vacation: ${matchingVacations.first.reason.isNotEmpty ? matchingVacations.first.reason : 'Holiday'}",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF9A3412),
                        ),
                      ),
                    ),
                    const Icon(Icons.edit_outlined,
                        size: 16, color: Color(0xFFEA580C)),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Shift Cards or Closed Message
          if (isOpen)
            _buildShiftsList(context, availability)
          else
            _buildClosedNotice(context),
        ],
      ),
    );
  }

  Widget _buildShiftsList(
    BuildContext context,
    DayAvailabilityEntity availability,
  ) {
    final shifts = _normalizeShifts(availability);

    return Column(
      children: shifts.map((shift) {
        return _buildShiftInspectionCard(context, shift);
      }).toList(),
    );
  }

  Widget _buildShiftInspectionCard(BuildContext context, DayShiftEntity shift) {
    final isOpen = shift.isOpen;
    IconData iconData;
    Color iconColor;

    switch (shift.shiftType.toLowerCase()) {
      case 'afternoon':
        iconData = Icons.wb_sunny_rounded;
        iconColor = const Color(0xFFEA580C);
        break;
      case 'evening':
        iconData = Icons.cloud_outlined;
        iconColor = const Color(0xFF6366F1);
        break;
      case 'night':
        iconData = Icons.nightlight_round;
        iconColor = const Color(0xFF0284C7);
        break;
      case 'morning':
      default:
        iconData = Icons.wb_twilight_rounded;
        iconColor = const Color(0xFFF59E0B);
        break;
    }

    final shiftTitle = shift.shiftName.isNotEmpty
        ? shift.shiftName
        : _defaultShiftTitle(shift.shiftType);

    final slotsList = shift.slots.isNotEmpty
        ? shift.slots
        : (shift.startTime != null && shift.endTime != null
            ? DayShiftEntity.generateSlots(shift.startTime!, shift.endTime!,
                shift.slotInterval, shift.capacity)
            : <DayShiftSlotEntity>[]);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOpen ? const Color(0xFFF9FAFB) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOpen ? const Color(0xFFE5E7EB) : const Color(0xFFF3F4F6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconData, size: 16, color: isOpen ? iconColor : Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shiftTitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isOpen
                        ? const Color(0xFF1F2937)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              if (isOpen && shift.startTime != null && shift.endTime != null)
                Text(
                  "${shift.startTime} - ${shift.endTime}",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4B5563),
                  ),
                ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isOpen
                      ? const Color(0xFFF3F0F9)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isOpen ? "${slotsList.length} slots" : "Closed",
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isOpen ? AppColors.primary : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          if (isOpen && slotsList.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: slotsList.map((slot) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        slot.slot.isNotEmpty
                            ? slot.slot
                            : "${slot.startTime} - ${slot.endTime}",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "(${slot.allottedSlots} cap)",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClosedNotice(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_busy_outlined,
            size: 32,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 8),
          Text(
            "Closed for Bookings",
            style: GoogleFonts.inter(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "This day is configured as closed in your recurring weekly availability schedule.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ConfigureAvailabilityPage(timing: parentTiming),
                ),
              );
              if (context.mounted) {
                context.read<SlotsBloc>().add(GetSlotTimingsEvent());
              }
            },
            icon: const Icon(Icons.tune_rounded, size: 14),
            label: const Text("Configure Availability"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              textStyle: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<DayShiftEntity> _normalizeShifts(DayAvailabilityEntity item) {
    List<DayShiftEntity> shifts = item.shifts;
    if (shifts.isEmpty) {
      shifts = DayAvailabilityEntity.defaultShiftsForDay(
        item.day,
        item.startTime,
        item.endTime,
        item.isOpen,
      );
    }

    const order = ['morning', 'afternoon', 'evening', 'night'];
    final sorted = List<DayShiftEntity>.from(shifts);
    sorted.sort((a, b) {
      final aIdx = order.indexOf(a.shiftType.toLowerCase());
      final bIdx = order.indexOf(b.shiftType.toLowerCase());
      return (aIdx == -1 ? 99 : aIdx).compareTo(bIdx == -1 ? 99 : bIdx);
    });
    return sorted;
  }

  String _defaultShiftTitle(String type) {
    switch (type.toLowerCase()) {
      case 'afternoon':
        return 'Afternoon Shift';
      case 'evening':
        return 'Evening Shift';
      case 'night':
        return 'Night Shift';
      case 'morning':
      default:
        return 'Morning Shift';
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _openManageVacationDialog({
    required BuildContext context,
    required DateTime date,
    VendorVacationEntity? vacation,
  }) {
    showDialog(
      context: context,
      builder: (dialogCtx) => ManageVacationDialog(
        selectedDate: date,
        existingVacation: vacation,
        vendorId: parentTiming.vendorId,
        onSave: (newVacation) {
          context.read<SlotCalendarBloc>().add(SaveVacationEvent(newVacation));
        },
        onClear: (vacationId, clearDate) {
          context.read<SlotCalendarBloc>().add(DeleteVacationEvent(
                vacationId: vacationId,
                date: clearDate,
              ));
        },
      ),
    );
  }
}
