import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/slot_timing_entity.dart';
import '../bloc/slots_bloc.dart';
import '../bloc/slots_event.dart';
import '../bloc/slots_state.dart';

class ConfigureAvailabilityPage extends StatefulWidget {
  final SlotTimingEntity timing;

  const ConfigureAvailabilityPage({super.key, required this.timing});

  @override
  State<ConfigureAvailabilityPage> createState() =>
      _ConfigureAvailabilityPageState();
}

class _ConfigureAvailabilityPageState extends State<ConfigureAvailabilityPage> {
  static const List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late List<DayAvailabilityEntity> _tempAvailability;
  int _selectedDayIndex = 0;
  final ScrollController _tabsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tempAvailability =
        _buildCompleteWeekAvailability(widget.timing.availability);
  }

  @override
  void dispose() {
    _tabsScrollController.dispose();
    super.dispose();
  }

  List<DayAvailabilityEntity> _buildCompleteWeekAvailability(
      List<DayAvailabilityEntity> existingList) {
    final Map<String, DayAvailabilityEntity> map = {};
    for (final item in existingList) {
      final key = item.day.trim().toLowerCase();
      map[key] = item;
      if (key.startsWith('mon')) map['monday'] = item;
      if (key.startsWith('tue')) map['tuesday'] = item;
      if (key.startsWith('wed')) map['wednesday'] = item;
      if (key.startsWith('thu')) map['thursday'] = item;
      if (key.startsWith('fri')) map['friday'] = item;
      if (key.startsWith('sat')) map['saturday'] = item;
      if (key.startsWith('sun')) map['sunday'] = item;
    }

    return _weekDays.map((dayName) {
      final key = dayName.toLowerCase();
      if (map.containsKey(key)) {
        final existing = map[key]!;
        List<DayShiftEntity> finalShifts;
        if (existing.shifts.isNotEmpty && existing.shifts.length >= 4) {
          finalShifts = existing.shifts.map((s) => s.copyWith()).toList();
        } else {
          finalShifts = DayAvailabilityEntity.defaultShiftsForDay(
            dayName,
            existing.startTime,
            existing.endTime,
            true,
          );
        }

        return DayAvailabilityEntity(
          day: dayName,
          isOpen: true,
          startTime:
              existing.startTime.isNotEmpty ? existing.startTime : '09:00',
          endTime: existing.endTime.isNotEmpty ? existing.endTime : '17:00',
          id: existing.id,
          shifts: finalShifts,
        );
      } else {
        return DayAvailabilityEntity(
          day: dayName,
          isOpen: true,
          startTime: '09:00',
          endTime: '17:00',
          id: '',
          shifts: DayAvailabilityEntity.defaultShiftsForDay(
            dayName,
            '09:00',
            '17:00',
            true,
          ),
        );
      }
    }).toList();
  }

  DayAvailabilityEntity get _currentDay {
    if (_tempAvailability.isEmpty) {
      return DayAvailabilityEntity(
        day: 'Monday',
        isOpen: true,
        startTime: '09:00',
        endTime: '17:00',
        id: '',
      );
    }
    final day = _tempAvailability[
        _selectedDayIndex.clamp(0, _tempAvailability.length - 1)];
    if (day.shifts.isEmpty || day.shifts.length < 4) {
      return day.copyWith(
        shifts: DayAvailabilityEntity.defaultShiftsForDay(
          day.day,
          day.startTime,
          day.endTime,
          day.isOpen,
        ),
      );
    }
    return day;
  }

  void _selectDay(int index) {
    if (index < 0 || index >= _tempAvailability.length) return;
    setState(() {
      _selectedDayIndex = index;
    });

    if (_tabsScrollController.hasClients) {
      final targetOffset = (index * 130.0).clamp(
        0.0,
        _tabsScrollController.position.maxScrollExtent,
      );
      _tabsScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _toggleCurrentDayOpen() {
    setState(() {
      final current = _currentDay;
      final newIsOpen = !current.isOpen;
      _tempAvailability[_selectedDayIndex] = current.copyWith(
        isOpen: newIsOpen,
        shifts: current.shifts.map((s) {
          if (newIsOpen && !current.shifts.any((shift) => shift.isEnabled)) {
            final isMorningOrAfternoon =
                s.type == 'morning' || s.type == 'afternoon';
            return s.copyWith(isOpen: isMorningOrAfternoon);
          }
          return s.copyWith();
        }).toList(),
      );
    });
  }

  void _applyCurrentDayToAllDays() {
    final source = _currentDay;
    setState(() {
      for (int i = 0; i < _tempAvailability.length; i++) {
        if (i != _selectedDayIndex) {
          _tempAvailability[i] = _tempAvailability[i].copyWith(
            isOpen: source.isOpen,
            shifts: source.shifts.map((s) => s.copyWith()).toList(),
          );
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Applied ${source.day} shifts & timings to all days",
          style: GoogleFonts.inter(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF241442),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _updateShift(int shiftIndex, DayShiftEntity updatedShift) {
    setState(() {
      final current = _currentDay;
      final newShifts = List<DayShiftEntity>.from(current.shifts);
      newShifts[shiftIndex] = updatedShift;

      final activeShifts = newShifts.where((s) => s.isOpen).toList();
      String parentStart = current.startTime;
      String parentEnd = current.endTime;
      if (activeShifts.isNotEmpty) {
        parentStart = activeShifts.first.startTime ?? '09:00';
        parentEnd = activeShifts.last.endTime ?? '17:00';
      }

      _tempAvailability[_selectedDayIndex] = current.copyWith(
        shifts: newShifts,
        startTime: parentStart,
        endTime: parentEnd,
        isOpen: activeShifts.isNotEmpty ? true : current.isOpen,
      );
    });
  }

  void _onToggleShift(int shiftIndex, bool isEnabled) {
    final shift = _currentDay.shifts[shiftIndex];
    if (isEnabled) {
      String defaultStart;
      String defaultEnd;
      switch (shift.shiftType.toLowerCase()) {
        case 'afternoon':
          defaultStart = '13:00';
          defaultEnd = '14:00';
          break;
        case 'evening':
          defaultStart = '17:00';
          defaultEnd = '21:00';
          break;
        case 'night':
          defaultStart = '21:00';
          defaultEnd = '23:00';
          break;
        case 'morning':
        default:
          defaultStart = '09:00';
          defaultEnd = '13:00';
          break;
      }
      final updated = shift.copyWith(
        isOpen: true,
        startTime: shift.startTime ?? defaultStart,
        endTime: shift.endTime ?? defaultEnd,
      );
      _updateShift(shiftIndex, updated);
    } else {
      final updated = shift.copyWith(
        isOpen: false,
        clearTimes: true,
        slots: const [],
      );
      _updateShift(shiftIndex, updated);
    }
  }

  Future<void> _pickShiftTime(
      BuildContext context, int shiftIndex, bool isStartTime) async {
    final shift = _currentDay.shifts[shiftIndex];
    final timeStr = isStartTime ? shift.startTime : shift.endTime;
    final initialTime =
        _parseTimeToTimeOfDay(timeStr ?? (isStartTime ? '09:00' : '17:00'));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF241442),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF241442),
              secondary: Color(0xFF241442),
            ),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      final updated = shift.copyWith(
        startTime: isStartTime ? formatted : shift.startTime,
        endTime: isStartTime ? shift.endTime : formatted,
      );
      _updateShift(shiftIndex, updated);
    }
  }

  // Future<void> _editShiftCapacity(BuildContext context, int shiftIndex) async {
  //   final shift = _currentDay.shifts[shiftIndex];
  //   final controller = TextEditingController(text: shift.capacity.toString());

  //   final newCap = await showDialog<int>(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         shape:
  //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  //         title: Text(
  //           "Capacity per Slot",
  //           style: GoogleFonts.inter(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //               color: const Color(0xFF1F2937)),
  //         ),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               "Enter max customers allowed for each divided slot:",
  //               style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
  //             ),
  //             const SizedBox(height: 12),
  //             TextField(
  //               controller: controller,
  //               keyboardType: TextInputType.number,
  //               autofocus: true,
  //               decoration: InputDecoration(
  //                 border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(10)),
  //                 hintText: "e.g. 5",
  //                 suffixText: "per slot",
  //               ),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child:
  //                 Text("Cancel", style: GoogleFonts.inter(color: Colors.grey)),
  //           ),
  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: const Color(0xFF241442),
  //               shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(8)),
  //             ),
  //             onPressed: () {
  //               final val = int.tryParse(controller.text.trim());
  //               if (val != null && val > 0) {
  //                 Navigator.pop(context, val);
  //               } else {
  //                 Navigator.pop(context);
  //               }
  //             },
  //             child: Text("Save",
  //                 style: GoogleFonts.inter(
  //                     fontWeight: FontWeight.bold, color: Colors.white)),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   if (newCap != null && newCap != shift.capacity) {
  //     _updateShift(shiftIndex, shift.copyWith(capacity: newCap));
  //   }
  // }

  TimeOfDay _parseTimeToTimeOfDay(String timeStr) {
    try {
      final clean = timeStr.trim().toUpperCase();
      if (clean.contains('AM') || clean.contains('PM')) {
        final isPM = clean.contains('PM');
        final parts =
            clean.replaceAll('AM', '').replaceAll('PM', '').trim().split(':');
        int hour = int.parse(parts[0]);
        final int minute = parts.length > 1 ? int.parse(parts[1]) : 0;
        if (isPM && hour < 12) hour += 12;
        if (!isPM && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      } else {
        final parts = clean.split(':');
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: parts.length > 1 ? int.parse(parts[1]) : 0,
        );
      }
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  String _formatTo12Hour(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '09:00 AM';
    try {
      final tod = _parseTimeToTimeOfDay(timeStr);
      final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
      final minute = tod.minute.toString().padLeft(2, '0');
      final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
      return "${hour.toString().padLeft(2, '0')}:$minute $period";
    } catch (_) {
      return timeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SlotsBloc, SlotsState>(
      listener: (context, state) {
        if (state is SlotsUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("All weekly shifts & slots saved successfully!"),
              backgroundColor: Color(0xFF10B981),
            ),
          );
          Navigator.pop(context);
        } else if (state is SlotsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Configure Availability",
                style: GoogleFonts.inter(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                "Set your open hours for each day",
                style: GoogleFonts.inter(
                  color: Colors.grey,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBodyHeader(),
                    const SizedBox(height: 14),
                    _buildWeeklyDayTabs(),
                    const SizedBox(height: 14),
                    _buildDayStatusBanner(),
                    const SizedBox(height: 16),
                    _buildShiftsSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Configure Weekly Shifts & Slots",
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Set timings and allocate slots across Morning, Afternoon, Evening, and Night shifts",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDayTabs() {
    return Row(
      children: [
        // Previous Button
        InkWell(
          onTap: _selectedDayIndex > 0
              ? () => _selectDay(_selectedDayIndex - 1)
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              size: 20,
              color: _selectedDayIndex > 0
                  ? const Color(0xFF374151)
                  : const Color(0xFFD1D5DB),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Scrollable 7 Tabs
        Expanded(
          child: SizedBox(
            height: 42,
            child: ListView.separated(
              controller: _tabsScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _tempAvailability.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final dayItem = _tempAvailability[index];
                final isSelected = index == _selectedDayIndex;
                final activeCount = dayItem.activeShiftsCount;
                final isOpen = dayItem.isOpen;

                return InkWell(
                    onTap: () => _selectDay(index),
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFF241442) : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF241442)
                              : const Color(0xFFE5E7EB),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFF241442).withOpacity(0.16),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Indicator dot
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isOpen
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Day Name
                          Text(
                            dayItem.day,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Shifts badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF38235E)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$activeCount shifts",
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.95)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
              },
            ),
          ),
        ),

        const SizedBox(width: 8),
        // Next Button
        InkWell(
          onTap: _selectedDayIndex < _tempAvailability.length - 1
              ? () => _selectDay(_selectedDayIndex + 1)
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: _selectedDayIndex < _tempAvailability.length - 1
                  ? const Color(0xFF374151)
                  : const Color(0xFFD1D5DB),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayStatusBanner() {
    final dayItem = _currentDay;
    final isOpen = dayItem.isOpen;
    final dayUpper = dayItem.day.toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              // Open/Closed Toggle Pill
              InkWell(
                onTap: _toggleCurrentDayOpen,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isOpen
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEE2E2),
                    border: Border.all(
                      color: isOpen
                          ? const Color(0xFF86EFAC)
                          : const Color(0xFFFCA5A5),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOpen
                            ? Icons.check_circle_outline_rounded
                            : Icons.cancel_outlined,
                        size: 15,
                        color: isOpen
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOpen ? "$dayUpper IS OPEN" : "$dayUpper IS CLOSED",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isOpen
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                "Toggle off if closed all day",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),

          // Apply to All Days Button
          InkWell(
            onTap: _applyCurrentDayToAllDays,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD1D5DB)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.content_copy_outlined,
                    size: 15,
                    color: Color(0xFF241442),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Apply ${dayItem.day} to All Days",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF241442),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftsSection() {
    final shifts = _currentDay.shifts;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;

        if (isWide) {
          // 2x2 Grid for wide screens / tablets / web
          final leftColShifts = <int>[];
          final rightColShifts = <int>[];
          for (int i = 0; i < shifts.length; i++) {
            if (i % 2 == 0) {
              leftColShifts.add(i);
            } else {
              rightColShifts.add(i);
            }
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: leftColShifts
                      .map((idx) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildShiftCard(idx, shifts[idx]),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: rightColShifts
                      .map((idx) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildShiftCard(idx, shifts[idx]),
                          ))
                      .toList(),
                ),
              ),
            ],
          );
        } else {
          // 1 Column list for mobile screens
          return Column(
            children: List.generate(shifts.length, (idx) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildShiftCard(idx, shifts[idx]),
              );
            }),
          );
        }
      },
    );
  }

  String _defaultTitleForType(String type) {
    switch (type.toLowerCase().trim()) {
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

  Widget _buildShiftCard(int shiftIndex, DayShiftEntity shift) {
    final isEnabled = shift.isEnabled;

    Color iconBg;
    Color iconColor;
    IconData iconData;

    switch (shift.type.toLowerCase()) {
      case 'morning':
        iconBg = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFD97706);
        iconData = Icons.wb_twilight_rounded;
        break;
      case 'afternoon':
        iconBg = const Color(0xFFFFF7ED);
        iconColor = const Color(0xFFEA580C);
        iconData = Icons.wb_sunny_rounded;
        break;
      case 'evening':
        iconBg = const Color(0xFFEEF2FF);
        iconColor = const Color(0xFF6366F1);
        iconData = Icons.cloud_outlined;
        break;
      case 'night':
      default:
        iconBg = const Color(0xFFE0F2FE);
        iconColor = const Color(0xFF0284C7);
        iconData = Icons.nightlight_round;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isEnabled ? const Color(0xFFE5E7EB) : const Color(0xFFF3F4F6),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Icon + Title + Type + Toggle Switch
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isEnabled ? iconBg : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  iconData,
                  size: 20,
                  color: isEnabled ? iconColor : const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shift.title.isNotEmpty
                          ? shift.title
                          : _defaultTitleForType(shift.type),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isEnabled
                            ? const Color(0xFF1F2937)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Shift type: ${shift.type.toLowerCase()}",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF241442),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE5E7EB),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (val) {
                  _onToggleShift(shiftIndex, val);
                },
              ),
            ],
          ),

          // If enabled, show inputs and divided slots
          if (isEnabled) ...[
            const SizedBox(height: 16),
            _buildShiftInputs(shiftIndex, shift),
            const SizedBox(height: 14),
            _buildDividedSlotsBox(shift),
          ],
        ],
      ),
    );
  }

  Widget _buildShiftInputs(int shiftIndex, DayShiftEntity shift) {
    final start12h = _formatTo12Hour(shift.startTime);
    final end12h = _formatTo12Hour(shift.endTime);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 440;

        if (isCompact) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTimeInputBox(
                      label: "START TIME",
                      displayTime: start12h,
                      onTap: () => _pickShiftTime(context, shiftIndex, true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildTimeInputBox(
                      label: "END TIME",
                      displayTime: end12h,
                      onTap: () => _pickShiftTime(context, shiftIndex, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildIntervalDropdown(shiftIndex, shift),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Container()
                      //  _buildCapacityInputBox(
                      //   shiftIndex: shiftIndex,
                      //   capacity: shift.capacity,
                      //   onTap: () => _editShiftCapacity(context, shiftIndex),
                      // ),
                      ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildTimeInputBox(
                label: "START TIME",
                displayTime: start12h,
                onTap: () => _pickShiftTime(context, shiftIndex, true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTimeInputBox(
                label: "END TIME",
                displayTime: end12h,
                onTap: () => _pickShiftTime(context, shiftIndex, false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildIntervalDropdown(shiftIndex, shift),
            ),
            const SizedBox(width: 8),
            Expanded(child: Container()
                // _buildCapacityInputBox(
                //   shiftIndex: shiftIndex,
                //   capacity: shift.capacity,
                //   onTap: () => _editShiftCapacity(context, shiftIndex),
                // ),
                ),
          ],
        );
      },
    );
  }

  Widget _buildTimeInputBox({
    required String label,
    required String displayTime,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF9CA3AF),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    displayTime,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
                const Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Color(0xFF6B7280),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalDropdown(int shiftIndex, DayShiftEntity shift) {
    const intervals = [15, 30, 45, 60, 90, 120];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "SLOT INTERVAL",
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF9CA3AF),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: intervals.contains(shift.intervalMinutes)
                  ? shift.intervalMinutes
                  : 60,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              items: intervals.map((int val) {
                return DropdownMenuItem<int>(
                  value: val,
                  child: Text(
                    "$val mins",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (int? newVal) {
                if (newVal != null) {
                  _updateShift(
                      shiftIndex, shift.copyWith(slotInterval: newVal));
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildCapacityInputBox({
  //   required int shiftIndex,
  //   required int capacity,
  //   required VoidCallback onTap,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         "CAPACITY / SLOT",
  //         style: GoogleFonts.inter(
  //           fontSize: 9,
  //           fontWeight: FontWeight.w700,
  //           color: const Color(0xFF9CA3AF),
  //           letterSpacing: 0.4,
  //         ),
  //       ),
  //       const SizedBox(height: 4),
  //       InkWell(
  //         onTap: onTap,
  //         borderRadius: BorderRadius.circular(8),
  //         child: Container(
  //           height: 38,
  //           padding: const EdgeInsets.symmetric(horizontal: 10),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFF9FAFB),
  //             border: Border.all(color: const Color(0xFFE5E7EB)),
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Text(
  //                 "$capacity",
  //                 style: GoogleFonts.inter(
  //                   fontSize: 12,
  //                   fontWeight: FontWeight.w700,
  //                   color: const Color(0xFF1F2937),
  //                 ),
  //               ),
  //               const Icon(
  //                 Icons.edit_outlined,
  //                 size: 13,
  //                 color: Color(0xFF9CA3AF),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDividedSlotsBox(DayShiftEntity shift) {
    final slotsList = shift.slots.isNotEmpty
        ? shift.slots
        : (shift.isOpen && shift.startTime != null && shift.endTime != null
            ? DayShiftEntity.generateSlots(
                shift.startTime!,
                shift.endTime!,
                shift.intervalMinutes,
                shift.capacity,
              )
            : <DayShiftSlotEntity>[]);
    final totalCapacity =
        slotsList.fold<int>(0, (sum, s) => sum + s.allottedSlots);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome_rounded,
                      size: 15,
                      color: Color(0xFF241442),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "Divided Slots (${slotsList.length}) • $totalCapacity Total Capacity",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF241442),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${shift.intervalMinutes}m intervals",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          if (slotsList.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: slotsList.map((slotItem) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slotItem.slot,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F0F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "(${slotItem.allottedSlots})",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF38235E),
                          ),
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

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  "Discard Changes",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: BlocBuilder<SlotsBloc, SlotsState>(
                builder: (context, state) {
                  final isLoading = state is SlotsLoading;

                  return ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            final updatedEntity = SlotTimingEntity(
                              id: widget.timing.id,
                              vendorId: widget.timing.vendorId,
                              availability: _tempAvailability,
                              updatedAt: DateTime.now(),
                            );
                            context.read<SlotsBloc>().add(
                                  UpdateSlotTimingsEvent(
                                    id: widget.timing.id,
                                    entity: updatedEntity,
                                  ),
                                );
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check,
                            size: 16, color: Colors.white),
                    label: Text(
                      isLoading ? "Saving..." : "Save All Shifts & Slots",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF241442),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
