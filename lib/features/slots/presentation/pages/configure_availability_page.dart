import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
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
  late List<DayAvailabilityEntity> _tempAvailability;

  @override
  void initState() {
    super.initState();
    // Create a mutable copy of the availability list
    _tempAvailability = widget.timing.availability
        .map((e) => DayAvailabilityEntity(
              day: e.day,
              isOpen: e.isOpen,
              startTime: e.startTime,
              endTime: e.endTime,
              id: e.id,
            ))
        .toList();
  }

  Future<void> _selectTime(
      BuildContext context, int index, bool isStartTime) async {
    final currentTime = isStartTime
        ? _tempAvailability[index].startTime
        : _tempAvailability[index].endTime;
    final parts = currentTime.split(':');
    final initialTime =
        TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primary,
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final formattedTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
        final current = _tempAvailability[index];
        _tempAvailability[index] = DayAvailabilityEntity(
          day: current.day,
          isOpen: current.isOpen,
          startTime: isStartTime ? formattedTime : current.startTime,
          endTime: isStartTime ? current.endTime : formattedTime,
          id: current.id,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SlotsBloc, SlotsState>(
      listener: (context, state) {
        if (state is SlotsUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Availability updated successfully!")),
          );
          Navigator.pop(context);
        } else if (state is SlotsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _tempAvailability.length,
                itemBuilder: (context, index) {
                  return _buildAvailabilityRow(index);
                },
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityRow(int index) {
    final item = _tempAvailability[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.day.toUpperCase(),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _tempAvailability[index] = DayAvailabilityEntity(
                      day: item.day,
                      isOpen: !item.isOpen,
                      startTime: item.startTime,
                      endTime: item.endTime,
                      id: item.id,
                    );
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isOpen
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: item.isOpen
                          ? Colors.green.withOpacity(0.5)
                          : Colors.red.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.isOpen ? Icons.check_circle : Icons.cancel,
                        size: 12,
                        color: item.isOpen ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.isOpen ? "OPEN" : "CLOSED",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: item.isOpen ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (item.isOpen) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(
                    "START TIME",
                    item.startTime,
                    () => _selectTime(context, index, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimePicker(
                    "END TIME",
                    item.endTime,
                    () => _selectTime(context, index, false),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, String time, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 9,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Discard Changes",
                style: GoogleFonts.inter(
                    color: Colors.grey[600], fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: BlocBuilder<SlotsBloc, SlotsState>(
              builder: (context, state) {
                final isLoading = state is SlotsLoading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          final updatedEntity = SlotTimingEntity(
                            id: widget.timing.id,
                            vendorId: widget.timing.vendorId,
                            availability: _tempAvailability,
                            updatedAt: DateTime.now(),
                          );
                          context.read<SlotsBloc>().add(UpdateSlotTimingsEvent(
                                id: widget.timing.id,
                                entity: updatedEntity,
                              ));
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text(
                          "Save Timing Settings",
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
