import 'package:MediCompare/features/slots/domain/entities/slot_timing_entity.dart';
import 'package:MediCompare/features/slots/presentation/bloc/slot_calendar_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/token_storage.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../slots_injection.dart';
import '../bloc/slot_calendar_bloc.dart';
import '../bloc/slots_bloc.dart';
import '../bloc/slots_event.dart';
import '../bloc/slots_state.dart';
import '../widgets/custom_slot_calendar.dart';
import 'configure_availability_page.dart';

class SlotTimingsPage extends StatelessWidget {
  const SlotTimingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return BlocProvider<SlotCalendarBloc>(
      create: (_) => SlotsInjection.provideSlotCalendarBloc()
        ..add(FetchVacationCalendarEvent(
          month: now.month,
          year: now.year,
        )),
      child: BlocListener<SlotsBloc, SlotsState>(
        listener: (context, state) {
          if (state is SlotsError && state.message.contains('UNAUTHORIZED')) {
            TokenStorage.clearAll().then((_) {
              if (context.mounted) {
                context.go('/login');
              }
            });
          }
        },
        child: BlocBuilder<SlotsBloc, SlotsState>(
          builder: (context, state) {
            if (state is SlotsLoading) {
              return const Scaffold(
                backgroundColor: Color(0xFFF3F6FF),
                body: Center(child: CircularProgressIndicator()),
              );
            } else if (state is SlotsLoaded) {
              return Scaffold(
                backgroundColor: const Color(0xFFF3F6FF),
                appBar: const CustomHomeAppBar(
                  title: "Slot Timings",
                  subtitle: "Manage your weekly availability",
                ),
                body: _buildContent(context, state.timings),
              );
            } else if (state is SlotsError) {
              return Scaffold(
                backgroundColor: const Color(0xFFF3F6FF),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context
                            .read<SlotsBloc>()
                            .add(GetSlotTimingsEvent()),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<SlotTimingEntity> timings) {
    if (timings.isEmpty) {
      return const Center(child: Text("No slot timings found."));
    }

    final parentTiming = timings.first;
    final availability = parentTiming.availability;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<SlotsBloc>().add(GetSlotTimingsEvent());
        final calendarState = context.read<SlotCalendarBloc>().state;
        context.read<SlotCalendarBloc>().add(FetchVacationCalendarEvent(
              month: calendarState.focusedMonth.month,
              year: calendarState.focusedMonth.year,
            ));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // 1. SECTION HEADER: AVAILABILITY GRID
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Availability Grid",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  TextButton.icon(
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
                    icon: const Icon(Icons.settings_outlined, size: 16),
                    label: const Text("Configure"),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF241442),
                      textStyle: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. RESPONSIVE GRID OF CARDS
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 440,
                    mainAxisExtent: 244,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: availability.length,
                  itemBuilder: (context, index) {
                    return _buildTimingCard(
                        context, availability[index], parentTiming);
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // 3. SECTION HEADER: AVAILABILITY CALENDAR (DISPLAYED AFTER AVAILABILITY GRID)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Availability Calendar",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Select any date to view scheduled shifts and slot capacity",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 4. CUSTOMIZED CALENDAR COMPONENT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: CustomSlotCalendar(parentTiming: parentTiming),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimingCard(BuildContext context, DayAvailabilityEntity item,
      SlotTimingEntity parentTiming) {
    final shifts = _normalizeShifts(item);
    final openShifts = shifts.where((s) => s.isOpen).toList();
    final isOpen = item.isOpen && openShifts.isNotEmpty;
    final openCount = openShifts.length;

    // Calculate total slots and total capacity
    final totalSlots = item.totalSlots;
    final totalCapacity = item.totalCapacity;

    return InkWell(
      onTap: () async {
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Clock Icon + Day Name
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: Color(0xFF241442),
                ),
                const SizedBox(width: 6),
                Text(
                  item.day,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),

            // Status: • OPEN (X SHIFTS) or • CLOSED
            Text(
              isOpen ? "• OPEN ($openCount SHIFTS)" : "• CLOSED",
              style: GoogleFonts.inter(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color:
                    isOpen ? const Color(0xFF059669) : const Color(0xFF9CA3AF),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 10),

            // Shifts list (Morning, Afternoon, Evening, Night)
            ...shifts.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _buildShiftRow(s),
                )),

            const Spacer(),

            // Footer: TOTAL: X SLOTS (Y CAPACITY)
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "TOTAL: $totalSlots SLOTS ($totalCapacity CAPACITY)",
                style: GoogleFonts.inter(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF9CA3AF),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftRow(DayShiftEntity shift) {
    final isShiftOpen = shift.isOpen;
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

    if (isShiftOpen) {
      final slotsList = shift.slots.isNotEmpty
          ? shift.slots
          : (shift.startTime != null && shift.endTime != null
              ? DayShiftEntity.generateSlots(shift.startTime!, shift.endTime!,
                  shift.slotInterval, shift.capacity)
              : <DayShiftSlotEntity>[]);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(iconData, size: 14, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                shiftTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "${shift.startTime ?? ''} - ${shift.endTime ?? ''}",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4B5563),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F0F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                "${slotsList.length} slots",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A2B82),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            Icon(iconData, size: 14, color: const Color(0xFF9CA3AF)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                shiftTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ),
            Text(
              "Closed",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
    }
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
}
