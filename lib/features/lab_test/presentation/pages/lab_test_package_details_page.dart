import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:MediCompare/features/lab_test/data/models/lab_test_package_model.dart';
import 'package:MediCompare/features/lab_test/data/models/lab_test_model.dart';
import 'package:MediCompare/features/lab_test/data/data_sources/lab_test_service.dart';
import 'package:MediCompare/features/lab_test/lab_test_injection.dart';

class LabTestPackageDetailsPage extends StatefulWidget {
  final LabTestPackageItem package;
  const LabTestPackageDetailsPage({super.key, required this.package});

  @override
  State<LabTestPackageDetailsPage> createState() =>
      _LabTestPackageDetailsPageState();
}

class _LabTestPackageDetailsPageState extends State<LabTestPackageDetailsPage> {
  final LabTestService _labTestService =
      LabTestInjection.provideLabTestService();
  late LabTestPackageItem _package;
  bool _isLoading = true;
  bool _showAllDescription = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _package = widget.package;
    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    try {
      final updatedPackage =
          await _labTestService.getPackageDetails(widget.package.id);
      if (mounted) {
        setState(() {
          _package = updatedPackage;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FD),
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(child: Text("Error: $_error")),
      );
    }

    final package = _package;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1B4B)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          package.name,
          style: GoogleFonts.inter(
              color: const Color(0xFF1E1B4B),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(package),
            const SizedBox(height: 16),

            // Info Grid (Tests Count, Status)
            _buildInfoGrid(package),
            const SizedBox(height: 16),

            // Package Information Section
            _buildSectionHeader(Icons.info_outline, "Package Information",
                "Complete details about the package"),
            const SizedBox(height: 12),
            _buildPackageDetails(package),
            const SizedBox(height: 16),

            // Included Tests Table
            _buildIncludedTestsTable(package.tabletsDetails),
            const SizedBox(height: 16),

            // Description
            _buildCollapsibleSection(
              title: "Description",
              content: package.description ?? "No description available",
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF059669),
              isExpanded: _showAllDescription,
              onToggle: () =>
                  setState(() => _showAllDescription = !_showAllDescription),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LabTestPackageItem package) {
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
                    child: package.files.isNotEmpty
                        ? Image.network(
                            package.files
                                .first, // Package API gives full URL usually or check
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
                      child: Text(package.status,
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
                    Text(package.name,
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1B4B))),
                    const SizedBox(height: 8),
                    _chip("${package.products.length} Tests Included",
                        Icons.biotech_outlined, Colors.indigo),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceArea(package),
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

  Widget _buildPriceArea(LabTestPackageItem package) {
    final double saving = package.price - package.discountPrice;
    final int percent =
        package.price > 0 ? ((saving / package.price) * 100).toInt() : 0;

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
              Text("₹${package.price.toInt()}",
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Discount Price",
                  style: GoogleFonts.inter(
                      fontSize: 9,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold)),
              Text("₹${package.discountPrice.toInt()}",
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

  Widget _buildInfoGrid(LabTestPackageItem package) {
    return Row(
      children: [
        _infoItem("TESTS COUNT", "${package.products.length}",
            Icons.biotech_outlined, Colors.blue),
        const SizedBox(width: 12),
        _infoItem("STATUS", package.status.toUpperCase(),
            Icons.check_circle_outline, Colors.green),
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

  Widget _buildPackageDetails(LabTestPackageItem package) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _detailRow("PACKAGE NAME", package.name, Icons.inventory_2_outlined,
              Colors.blue),
          const Divider(height: 1),
          _detailRow("STATUS", package.status, Icons.check_circle_outline,
              Colors.green),
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
                color: color.withOpacity(0.08),
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

  Widget _buildIncludedTestsTable(List<LabTestDetails> tests) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildSectionHeader(Icons.assignment_outlined,
                "Included Tests", "Lab tests included in this package"),
          ),
          const Divider(height: 1),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFF8F9FD),
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text("TEST NAME",
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                            letterSpacing: 0.5))),
                Expanded(
                    flex: 2,
                    child: Text("SAMPLE TYPE",
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                            letterSpacing: 0.5))),
                Expanded(
                    flex: 2,
                    child: Text("REPORT DURATION",
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                            letterSpacing: 0.5))),
                Expanded(
                    flex: 1,
                    child: Text("FASTING",
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                            letterSpacing: 0.5))),
              ],
            ),
          ),
          ...tests.map((t) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey[100]!))),
                child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Text(t.name,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E1B4B)))),
                    Expanded(
                        flex: 2,
                        child: Text(t.sampleType ?? "N/A",
                            style: GoogleFonts.inter(
                                fontSize: 11, color: const Color(0xFF475569)))),
                    Expanded(
                        flex: 2,
                        child: Text(t.reportsDuration ?? "N/A",
                            style: GoogleFonts.inter(
                                fontSize: 11, color: const Color(0xFF475569)))),
                    Expanded(
                        flex: 1,
                        child:
                            _smallBadge(t.isFasting?.toLowerCase() == 'yes')),
                  ],
                ),
              )),
          if (tests.isEmpty)
            const Padding(
                padding: EdgeInsets.all(24),
                child:
                    Center(child: Text("No tests included in this package"))),
        ],
      ),
    );
  }

  Widget _smallBadge(bool isYes) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: (isYes ? Colors.yellow[100] : Colors.green[50]),
          borderRadius: BorderRadius.circular(4)),
      child: Text(isYes ? "Yes" : "No",
          style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: (isYes ? Colors.orange[800] : Colors.green[700]))),
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
                      fontSize: 11,
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
      child:
          const Icon(Icons.inventory_2_outlined, color: Colors.grey, size: 28),
    );
  }
}
