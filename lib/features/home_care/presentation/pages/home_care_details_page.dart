import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/home_care/data/models/home_care_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class HomeCareDetailsPage extends StatefulWidget {
  final HomeCareItem item;

  const HomeCareDetailsPage({super.key, required this.item});

  @override
  State<HomeCareDetailsPage> createState() => _HomeCareDetailsPageState();
}

class _HomeCareDetailsPageState extends State<HomeCareDetailsPage> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final details = widget.item.details;
    final baseUrl = 'https://api.medicompares.com';
    String? imageUrl;
    if (details.files.isNotEmpty) {
      final f = details.files.first;
      imageUrl = f.startsWith('http') ? f : '$baseUrl$f';
      imageUrl = Uri.encodeFull(imageUrl);
    }
    final double discount = widget.item.price > 0 ? ((widget.item.price - widget.item.discountPrice) / widget.item.price * 100) : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FB),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Service Details",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section (Image, Name & Price)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            border: Border.all(color: Colors.grey[100]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(imageUrl, fit: BoxFit.cover)
                              : const Icon(Icons.home_repair_service_outlined, size: 30, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              details.name,
                              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1B1B1B)),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("SELLING PRICE: ", style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF166534))),
                                  Text("₹${widget.item.discountPrice.toInt()}", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF15803D))),
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
                      _badge(Icons.local_offer_outlined, details.subcategory?.name ?? "General", const Color(0xFFE8EEFF), const Color(0xFF506CCF)),
                      _badge(Icons.access_time, details.duration ?? "N/A", const Color(0xFFFFF7ED), const Color(0xFFC2410C)),
                      if (discount > 0) _badge(Icons.card_giftcard, "${discount.toInt()}% OFF", const Color(0xFFFEF2F2), const Color(0xFFB91C1C)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Info Cards
                  Row(
                    children: [
                      _infoCard("CATEGORY", details.subcategory?.name ?? "N/A", const Color(0xFFE8F1FF), Icons.category_outlined),
                      const SizedBox(width: 12),
                      _infoCard("DURATION", details.duration ?? "N/A", const Color(0xFFF5EAFC), Icons.access_time),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _infoCard("MRP", "₹${widget.item.price.toInt()}", const Color(0xFFFFF6E5), Icons.currency_rupee),
                      const SizedBox(width: 12),
                      _infoCard("STATUS", widget.item.status.toUpperCase(), const Color(0xFFEAF9F1), Icons.check_circle_outline),
                    ],
                  ),
                ],
              ),
            ),

            // Description / HTML Section
            if (details.description != null && details.description!.isNotEmpty)
              _buildHtmlSection("Description", details.description!, Icons.description_outlined, const Color(0xFFEAF9F1), const Color(0xFF15803D)),
            if (details.precaution != null && details.precaution!.isNotEmpty)
              _buildHtmlSection("Precautions", details.precaution!, Icons.warning_amber_rounded, const Color(0xFFFFF6E5), const Color(0xFFC2410C)),
            if (details.sideEffects != null && details.sideEffects!.isNotEmpty)
              _buildHtmlSection("Side Effects", details.sideEffects!, Icons.coronavirus_outlined, const Color(0xFFFEF2F2), const Color(0xFFB91C1C)),
            if (details.preparationInstructions != null && details.preparationInstructions!.isNotEmpty)
              _buildHtmlSection("Preparation", details.preparationInstructions!, Icons.checklist_rtl_outlined, const Color(0xFFF5EAFC), const Color(0xFF9333EA)),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String label, Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 6),
          Flexible(child: Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: text), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _infoCard(String label, String value, Color bg, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: Colors.indigo[900]?.withOpacity(0.5)),
                const SizedBox(width: 6),
                Text(label, style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.indigo[900]?.withOpacity(0.6))),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF1E1B4B)), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildHtmlSection(String title, String html, IconData icon, Color bg, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          HtmlWidget(html, textStyle: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF4B5563), height: 1.6)),
        ],
      ),
    );
  }
}
