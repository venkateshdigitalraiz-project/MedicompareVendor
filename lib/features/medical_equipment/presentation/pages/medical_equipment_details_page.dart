import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/medical_equipment/medical_equipment_injection.dart';
import 'package:MediCompare/features/medical_equipment/presentation/bloc/medical_equipment_details_bloc.dart';
import 'package:MediCompare/features/medical_equipment/presentation/bloc/medical_equipment_details_event.dart';
import 'package:MediCompare/features/medical_equipment/presentation/bloc/medical_equipment_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/medical_equipment_entity.dart';

class MedicalEquipmentDetailsPage extends StatefulWidget {
  final MedicalEquipmentItem item;

  const MedicalEquipmentDetailsPage({super.key, required this.item});

  @override
  State<MedicalEquipmentDetailsPage> createState() =>
      _MedicalEquipmentDetailsPageState();
}

class _MedicalEquipmentDetailsPageState
    extends State<MedicalEquipmentDetailsPage> {
  bool _showAllDescription = false;
  bool _showAllPrecaution = false;
  bool _showAllSideEffects = false;
  bool _showAllPreparation = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MedicalEquipmentInjection.provideMedicalEquipmentDetailsBloc()
            ..add(LoadMedicalEquipmentDetailsEvent(widget.item.id)),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1B4B)),
            onPressed: () => context.pop(),
          ),
          title: Text(
            "Equipment Details",
            style: GoogleFonts.inter(
                color: const Color(0xFF1E1B4B),
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
        body: BlocBuilder<MedicalEquipmentDetailsBloc,
            MedicalEquipmentDetailsState>(
          builder: (context, state) {
            if (state is MedicalEquipmentDetailsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is MedicalEquipmentDetailsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: GoogleFonts.inter(color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MedicalEquipmentDetailsBloc>().add(
                              LoadMedicalEquipmentDetailsEvent(widget.item.id),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }

            // Fallback to widget.item if initial or load succeeds
            final item = state is MedicalEquipmentDetailsLoaded
                ? state.item
                : widget.item;

            final details = item.details;
            const baseUrl = 'https://api.medicompares.com';
            String? imageUrl;
            if (details.files.isNotEmpty) {
              imageUrl = details.files.first;
              if (!imageUrl.startsWith('http')) {
                imageUrl = '$baseUrl$imageUrl';
              }
              imageUrl = Uri.encodeFull(imageUrl);
            }
            final double saving = item.price - item.discountPrice;
            final double percent =
                item.price > 0 ? (saving / item.price * 100) : 0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(item, details, imageUrl, percent),
                  const SizedBox(height: 16),

                  // Rental Info Grid
                  _buildInfoGrid(item),
                  const SizedBox(height: 16),

                  // Description
                  if (details.description.isNotEmpty) ...[
                    _buildCollapsibleSection(
                      title: "Description",
                      content: details.description,
                      icon: Icons.description_outlined,
                      iconColor: const Color(0xFF059669),
                      isExpanded: _showAllDescription,
                      onToggle: () => setState(
                          () => _showAllDescription = !_showAllDescription),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Precaution / Instructions
                  if (details.condition != null &&
                      details.condition!.isNotEmpty) ...[
                    _buildCollapsibleSection(
                      title: "Precautions & Instructions",
                      content: details.condition!, // Uses precaution value if stored in details
                      icon: Icons.warning_amber_rounded,
                      iconColor: Colors.amber[800]!,
                      isExpanded: _showAllPrecaution,
                      onToggle: () => setState(
                          () => _showAllPrecaution = !_showAllPrecaution),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Side Effects / Care Info
                  if (details.machineType != null &&
                      details.machineType!.isNotEmpty) ...[
                    _buildCollapsibleSection(
                      title: "Machine Information",
                      content: "Type: ${details.machineType}",
                      icon: Icons.info_outline,
                      iconColor: Colors.blue[800]!,
                      isExpanded: _showAllSideEffects,
                      onToggle: () => setState(
                          () => _showAllSideEffects = !_showAllSideEffects),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(MedicalEquipmentItem item,
      MedicalEquipmentDetails details, String? imageUrl, double percent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(item.status,
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Info Area
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(details.name,
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1B4B))),
                    const SizedBox(height: 8),
                    _chip(details.subcategory?.name ?? "Equipment",
                        Icons.category_outlined, Colors.indigo),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceArea(item, percent),
        ],
      ),
    );
  }

  Widget _chip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildPriceArea(MedicalEquipmentItem item, double percent) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF0FFF4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("MRP",
                  style: GoogleFonts.inter(
                      fontSize: 9,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold)),
              Text("₹${item.price.toInt()}",
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Price",
                  style: GoogleFonts.inter(
                      fontSize: 9,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold)),
              Text("₹${item.discountPrice.toInt()}",
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold)),
            ],
          ),
          if (percent > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(6)),
              child: Text("${percent.toInt()}% OFF",
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(MedicalEquipmentItem item) {
    return Column(
      children: [
        Row(
          children: [
            _infoItem("FIXED DEPOSIT", "₹${item.fixedDeposit?.toInt() ?? 0}",
                Icons.savings_outlined, Colors.orange),
            const SizedBox(width: 12),
            _infoItem("PER DAY RENT", "₹${item.perDayRent?.toInt() ?? 0}",
                Icons.calendar_today_outlined, Colors.purple),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _infoItem("RETURN CHARGE", "₹${item.returnCharge?.toInt() ?? 0}",
                Icons.replay_outlined, Colors.blue),
            const SizedBox(width: 12),
            _infoItem("SERVICE CHARGE", "₹${item.serviceCharges?.toInt() ?? 0}",
                Icons.design_services_outlined, Colors.green),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _infoItem("INTEREST (%)", "${item.interest?.toInt() ?? 0}%",
                Icons.percent_outlined, Colors.red),
            const SizedBox(width: 12),
            _infoItem("STATUS", item.status.toUpperCase(),
                Icons.check_circle_outline, Colors.teal),
          ],
        ),
      ],
    );
  }

  Widget _infoItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.2)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B))),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    final hasLongContent = content.length > 200;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(icon, color: iconColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1B4B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasLongContent)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: GestureDetector(
                    onTap: onToggle,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(isExpanded ? "Show Less" : "Show More",
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                        Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 18,
                            color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          isExpanded
              ? HtmlWidget(
                  content,
                  textStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF4B5563),
                      height: 1.6),
                )
              : Text(
                  content
                      .replaceAll(RegExp(r'<[^>]*>|&nbsp;'), ' ')
                      .replaceAll(RegExp(r'\s+'), ' ')
                      .trim(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF4B5563),
                      height: 1.6),
                ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFF1F5F9),
      child: const Icon(Icons.medical_services_outlined,
          color: Colors.grey, size: 28),
    );
  }
}
