import 'package:MediCompare/features/slots/domain/entities/slot_timing_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/token_storage.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../bloc/slots_bloc.dart';
import '../bloc/slots_event.dart';
import '../bloc/slots_state.dart';
import 'configure_availability_page.dart';

class SlotTimingsPage extends StatelessWidget {
  const SlotTimingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SlotsBloc, SlotsState>(
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
                      onPressed: () =>
                          context.read<SlotsBloc>().add(GetSlotTimingsEvent()),
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
    );
  }

  Widget _buildContent(BuildContext context, List<SlotTimingEntity> timings) {
    // Usually there's only one timing document for a vendor
    final availability = timings.isNotEmpty ? timings.first.availability : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
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
                  color: Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  if (timings.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ConfigureAvailabilityPage(timing: timings.first),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.settings_outlined, size: 16),
                label: const Text("Configure"),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: GoogleFonts.inter(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        /// GRID OF CARDS
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: availability.length,
            itemBuilder: (context, index) {
              return _buildTimingCard(
                  context, availability[index], timings.first);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimingCard(BuildContext context, DayAvailabilityEntity item,
      SlotTimingEntity parentTiming) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_filled,
                      color: AppColors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    item.day,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) =>
              //             ConfigureAvailabilityPage(timing: parentTiming),
              //       ),
              //     );
              //   },
              //   child: const Icon(Icons.edit_outlined,
              //       size: 18, color: Colors.grey),
              // ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: item.isOpen ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                item.isOpen ? "OPEN" : "CLOSED",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: item.isOpen ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "AVAILABILITY",
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        "${item.startTime} - ${item.endTime}",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
