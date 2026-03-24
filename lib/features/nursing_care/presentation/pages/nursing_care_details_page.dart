import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/nursing_care/data/models/nursing_care_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class NursingCareDetailsPage extends StatelessWidget {
  final NursingCareItem item;

  const NursingCareDetailsPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final details = item.details;
    final baseUrl = 'https://api.medicompares.com';
    String? imageUrl;
    if (details.files.isNotEmpty) {
      final f = details.files.first;
      imageUrl = f.startsWith('http') ? f : '$baseUrl$f';
      imageUrl = Uri.encodeFull(imageUrl);
    }
    final saving = item.price - item.discountPrice;
    final double discountPercent =
        item.price > 0 ? (saving / item.price * 100) : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FB),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text("Service Details",
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        leading:
            BackButton(color: Colors.white, onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                              color: Colors.grey[50],
                              border: Border.all(color: Colors.grey[100]!)),
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                      Icons.person,
                                      color: Colors.grey))
                              : const Icon(Icons.person,
                                  size: 30, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(details.name,
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1B1B1B))),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("SELLING PRICE: ",
                                      style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF166534))),
                                  Text("₹${item.discountPrice.toInt()}",
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF15803D))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _badge(
                          Icons.category_outlined,
                          details.subcategory?.name ?? "General",
                          const Color(0xFFE8EEFF),
                          const Color(0xFF506CCF)),
                      _badge(Icons.access_time, details.duration ?? "N/A",
                          const Color(0xFFFFF7ED), const Color(0xFFC2410C)),
                      if (details.shiftType != null)
                        _badge(
                            Icons.watch_later_outlined,
                            details.shiftType!
                                .replaceAll('_', ' ')
                                .toUpperCase(),
                            const Color(0xFFF5EAFC),
                            const Color(0xFF9333EA)),
                      if (discountPercent > 0)
                        _badge(
                            Icons.local_offer_outlined,
                            "${discountPercent.toInt()}% OFF",
                            const Color(0xFFFEF2F2),
                            const Color(0xFFB91C1C)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _infoTile("CATEGORY", details.subcategory?.name ?? "N/A",
                          Icons.category_outlined, Colors.blue),
                      const SizedBox(width: 12),
                      _infoTile("DURATION", details.duration ?? "N/A",
                          Icons.access_time, Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _infoTile(
                          "CARE TYPE",
                          (details.nursecareType ?? 'N/A')
                              .replaceAll('_', ' ')
                              .toUpperCase(),
                          Icons.medical_services_outlined,
                          Colors.green),
                      const SizedBox(width: 12),
                      _infoTile("STATUS", item.status.toUpperCase(),
                          Icons.check_circle_outline, Colors.teal),
                    ],
                  ),
                ],
              ),
            ),

            // Content Sections
            if (details.description != null && details.description!.isNotEmpty)
              ExpandableHtmlSection(
                  title: "Nursing Care Information",
                  htmlContent: details.description!,
                  icon: Icons.description_outlined,
                  bg: const Color(0xFFEAF9F1),
                  color: const Color(0xFF15803D)),
            if (details.precaution != null && details.precaution!.isNotEmpty)
              ExpandableHtmlSection(
                  title: "Precautions",
                  htmlContent: details.precaution!,
                  icon: Icons.warning_amber_rounded,
                  bg: const Color(0xFFFFF6E5),
                  color: const Color(0xFFC2410C)),
            if (details.preparationInstructions != null &&
                details.preparationInstructions!.isNotEmpty)
              ExpandableHtmlSection(
                  title: "Preparation",
                  htmlContent: details.preparationInstructions!,
                  icon: Icons.checklist_rtl_outlined,
                  bg: const Color(0xFFF5EAFC),
                  color: const Color(0xFF9333EA)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 11, fontWeight: FontWeight.w500, color: text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.1))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class ExpandableHtmlSection extends StatefulWidget {
  final String title;
  final String htmlContent;
  final IconData icon;
  final Color bg;
  final Color color;

  const ExpandableHtmlSection({
    super.key,
    required this.title,
    required this.htmlContent,
    required this.icon,
    required this.bg,
    required this.color,
  });

  @override
  State<ExpandableHtmlSection> createState() => _ExpandableHtmlSectionState();
}

class _ExpandableHtmlSectionState extends State<ExpandableHtmlSection> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: widget.bg,
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(widget.icon, color: widget.color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.title,
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => setState(() => isExpanded = !isExpanded),
                child: Row(
                  children: [
                    Text(
                      isExpanded ? "Show Less" : "Show More",
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 4),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: isExpanded ? double.infinity : 100, // Roughly 3-4 lines
            ),
            child: ClipRect(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: HtmlWidget(
                  widget.htmlContent,
                  textStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF4B5563),
                      height: 1.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
