import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/diagnostic_model.dart';

class DiagnosticDetailsPage extends StatefulWidget {
  final DiagnosticItem item;
  const DiagnosticDetailsPage({super.key, required this.item});

  @override
  State<DiagnosticDetailsPage> createState() => _DiagnosticDetailsPageState();
}

class _DiagnosticDetailsPageState extends State<DiagnosticDetailsPage> {
  bool _showAllDescription = false;
  bool _showAllPrecaution = false;
  bool _showAllPrep = false;
  bool _showAllSideEffects = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final details = item.details;
    final baseUrl = 'https://api.medicompares.com';
    String? imageUrl;
    if (details.files.isNotEmpty) {
      final f = details.files.first;
      imageUrl = f.startsWith('http') ? f : '$baseUrl$f';
      imageUrl = Uri.encodeFull(imageUrl);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1B4B)),
            onPressed: () => context.pop()),
        title: Text(details.name,
            style: GoogleFonts.inter(
                color: const Color(0xFF1E1B4B),
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeader(item, imageUrl),
            const SizedBox(height: 16),

            // Info Grid
            _buildInfoGrid(item),
            const SizedBox(height: 16),

            // // Diagnostic Info Section
            // _buildSectionHeader(Icons.info_outline, "Diagnostic Information", "Complete details about the diagnostic"),
            // const SizedBox(height: 12),
            // _buildDetailsGrid(details),
            // const SizedBox(height: 16),

            // Description
            if (details.description != null && details.description!.isNotEmpty)
              _buildCollapsibleHtml(
                  "Description",
                  details.description!,
                  Icons.description_outlined,
                  Colors.green,
                  _showAllDescription,
                  () => setState(
                      () => _showAllDescription = !_showAllDescription)),

            const SizedBox(height: 12),

            // Precaution
            if (details.precaution != null && details.precaution!.isNotEmpty)
              _buildCollapsibleHtml(
                  "Precautions",
                  details.precaution!,
                  Icons.warning_amber_outlined,
                  Colors.orange,
                  _showAllPrecaution,
                  () =>
                      setState(() => _showAllPrecaution = !_showAllPrecaution)),

            const SizedBox(height: 12),

            // Preparation Instructions
            if (details.preparationInstructions != null &&
                details.preparationInstructions!.isNotEmpty)
              _buildCollapsibleHtml(
                  "Preparation Instructions",
                  details.preparationInstructions!,
                  Icons.checklist_outlined,
                  AppColors.primary,
                  _showAllPrep,
                  () => setState(() => _showAllPrep = !_showAllPrep)),

            const SizedBox(height: 12),

            // Side Effects
            if (details.sideEffects != null && details.sideEffects!.isNotEmpty)
              _buildCollapsibleHtml(
                  "Side Effects",
                  details.sideEffects!,
                  Icons.medical_services_outlined,
                  Colors.red,
                  _showAllSideEffects,
                  () => setState(
                      () => _showAllSideEffects = !_showAllSideEffects)),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(DiagnosticItem item, String? imageUrl) {
    final details = item.details;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl != null
                        ? Image.network(imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholder())
                        : _placeholder(),
                  ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.status == 'active'
                            ? Colors.green
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(details.name,
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1B4B))),
                    if (details.subcategory != null) ...[
                      const SizedBox(height: 4),
                      Text(details.subcategory!.name,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey[500])),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (details.bodyPart != null)
                          _chip(details.bodyPart!, Icons.location_on_outlined,
                              Colors.blue),
                        if (details.reportsDuration != null)
                          _chip(details.reportsDuration!,
                              Icons.schedule_outlined, Colors.purple),
                        if (details.isContrast != null)
                          _chip(
                            details.isContrast!.toLowerCase() == 'yes'
                                ? 'Contrast Required'
                                : 'No Contrast Required',
                            Icons.contrast,
                            details.isContrast!.toLowerCase() == 'yes'
                                ? Colors.orange
                                : Colors.green,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceArea(item),
        ],
      ),
    );
  }

  Widget _buildPriceArea(DiagnosticItem item) {
    final saving = item.price - item.discountPrice;
    final percent = item.price > 0 ? ((saving / item.price) * 100).toInt() : 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.1)),
      ),
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
              Text("SELLING PRICE",
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
              child: Text("$percent% OFF",
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.red[700],
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(DiagnosticItem item) {
    return Row(
      children: [
        _infoTile("BODY PART", item.details.bodyPart ?? 'N/A',
            Icons.location_on_outlined, Colors.blue),
        const SizedBox(width: 12),
        _infoTile(
            "CONTRAST",
            item.details.isContrast?.toLowerCase() == 'yes'
                ? 'Required'
                : 'Not Required',
            Icons.contrast,
            item.details.isContrast?.toLowerCase() == 'yes'
                ? Colors.orange
                : Colors.green),
        const SizedBox(width: 12),
        _infoTile("STATUS", item.status.toUpperCase(),
            Icons.check_circle_outline, Colors.teal),
      ],
    );
  }

  Widget _infoTile(String label, String value, IconData icon, Color color) {
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
                Icon(icon, size: 13, color: color),
                const SizedBox(width: 4),
                Expanded(
                    child: Text(label,
                        style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 0.2))),
              ],
            ),
            const SizedBox(height: 4),
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

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFF7C3AED), size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B))),
            Text(subtitle,
                style:
                    GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailsGrid(DiagnosticDetails details) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _detailRow("DIAGNOSTIC NAME", details.name, Icons.crop_free_outlined,
              Colors.indigo),
          const Divider(height: 1),
          _detailRow("BODY PART", details.bodyPart ?? 'N/A',
              Icons.location_on_outlined, Colors.blue),
          if (details.subcategory != null) ...[
            const Divider(height: 1),
            _detailRow("CATEGORY", details.subcategory!.name,
                Icons.category_outlined, Colors.purple),
          ],
          const Divider(height: 1),
          _detailRow(
            "CONTRAST REQUIRED",
            details.isContrast?.toLowerCase() == 'yes'
                ? 'Yes'
                : 'No Contrast Required',
            Icons.contrast,
            details.isContrast?.toLowerCase() == 'yes'
                ? Colors.orange
                : Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500])),
                const SizedBox(height: 4),
                Text(value,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1B4B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleHtml(String title, String content, IconData icon,
      Color iconColor, bool isExpanded, VoidCallback onToggle) {
    final hasLong = content.length > 200;
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
                          color: iconColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8)),
                      child: Icon(icon, color: iconColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E1B4B)))),
                  ],
                ),
              ),
              if (hasLong)
                GestureDetector(
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
            ],
          ),
          const SizedBox(height: 12),
          isExpanded
              ? HtmlWidget(content,
                  textStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF4B5563),
                      height: 1.6))
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

  Widget _chip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFF5F3FF),
      child: const Icon(Icons.biotech_outlined,
          color: AppColors.primary, size: 28),
    );
  }
}
