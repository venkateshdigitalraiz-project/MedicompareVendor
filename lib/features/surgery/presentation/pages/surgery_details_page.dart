import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/surgery_model.dart';
import '../../surgery_injection.dart';

class SurgeryDetailsPage extends StatefulWidget {
  final SurgeryItem surgery;

  const SurgeryDetailsPage({super.key, required this.surgery});

  @override
  State<SurgeryDetailsPage> createState() => _SurgeryDetailsPageState();
}

class _SurgeryDetailsPageState extends State<SurgeryDetailsPage> {
  late SurgeryItem _currentSurgery;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentSurgery = widget.surgery;
    _loadFullDetails();
  }

  Future<void> _loadFullDetails() async {
    try {
      final service = SurgeryInjection.provideSurgeryService();
      final fullDetails = await service.getSurgeryDetails(widget.surgery.id);
      if (mounted) {
        setState(() {
          _currentSurgery = fullDetails;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = _currentSurgery.details;
    final imageUrl = details.files.isNotEmpty
        ? "https://api.medicompares.com${details.files.first}"
        : "";

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FB),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Surgery Details",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Top Section (Name, Info, Price)
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
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      border:
                                          Border.all(color: Colors.grey[100]!),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: imageUrl.isNotEmpty
                                        ? Image.network(imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (c, e, s) =>
                                                const Icon(
                                                    Icons.medical_services,
                                                    size: 30,
                                                    color: Colors.grey))
                                        : const Icon(Icons.medical_services,
                                            size: 30, color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Name and Price
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        details.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1B1B1B),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF0FDF4),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "Discount: ",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      const Color(0xFF166534)),
                                            ),
                                            Text(
                                              "₹${_currentSurgery.discountPrice}",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      const Color(0xFF15803D)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Badges
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _badge(
                                    Icons.category_outlined,
                                    details.subcategory?.name ?? "N/A",
                                    const Color(0xFFE8EEFF),
                                    const Color(0xFF506CCF)),
                                _badge(
                                    Icons.settings_suggest_outlined,
                                    details.procedureType ?? "N/A",
                                    const Color(0xFFF3E8FF),
                                    const Color(0xFF9333EA)),
                                _badge(
                                    Icons.star_outline,
                                    details.complexity ?? "Simple",
                                    const Color(0xFFE6FFFA),
                                    const Color(0xFF0D9488)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // Grid Info Cards
                            Row(
                              children: [
                                _infoCard("DURATION", details.duration ?? "N/A",
                                    const Color(0xFFE8F1FF), Icons.access_time),
                                const SizedBox(width: 12),
                                _infoCard(
                                    "RECOVERY",
                                    details.recoveryTime ?? "N/A",
                                    const Color(0xFFF5EAFC),
                                    Icons.healing_outlined),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _infoCard(
                                    "COMPLEXITY",
                                    details.complexity ?? "Simple",
                                    const Color(0xFFFFF6E5),
                                    Icons.extension_outlined),
                                const SizedBox(width: 12),
                                _infoCard(
                                    "PROCEDURE",
                                    details.procedureType ?? "Simple",
                                    const Color(0xFFEAF9F1),
                                    Icons.medical_services_outlined),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Detail Sections
                      if (details.description != null &&
                          details.description!.isNotEmpty)
                        ExpandableHtmlSection(
                          title: "Description",
                          htmlContent: details.description!,
                          icon: Icons.description_outlined,
                          bg: const Color(0xFFEAF9F1),
                          color: const Color(0xFF15803D),
                        ),

                      if (details.directionOfUse != null &&
                          details.directionOfUse!.isNotEmpty)
                        ExpandableHtmlSection(
                          title: "Post-Procedure Care",
                          htmlContent: details.directionOfUse!,
                          icon: Icons.assignment_outlined,
                          bg: const Color(0xFFEFF6FF),
                          color: const Color(0xFF1D4ED8),
                        ),

                      if (details.precaution != null &&
                          details.precaution!.isNotEmpty)
                        ExpandableHtmlSection(
                          title: "Pre-Procedure Instructions",
                          htmlContent: details.precaution!,
                          icon: Icons.warning_amber_outlined,
                          bg: const Color(0xFFFFF7ED),
                          color: const Color(0xFFC2410C),
                        ),

                      if (details.sideEffects != null &&
                          details.sideEffects!.isNotEmpty)
                        ExpandableHtmlSection(
                          title: "Risks & Side Effects",
                          htmlContent: details.sideEffects!,
                          icon: Icons.error_outline,
                          bg: const Color(0xFFFEF2F2),
                          color: const Color(0xFFB91C1C),
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _badge(IconData icon, String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
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

  Widget _infoCard(String label, String value, Color bg, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 14, color: Colors.indigo[900]?.withOpacity(0.5)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo[900]?.withOpacity(0.6)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E1B4B)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
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
              maxHeight:
                  isExpanded ? double.infinity : 100, // Roughly 3-4 lines
            ),
            child: ClipRect(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: HtmlWidget(
                  widget.htmlContent,
                  textStyle: GoogleFonts.poppins(
                      fontSize: 12,
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
