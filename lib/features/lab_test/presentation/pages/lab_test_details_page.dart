import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/models/lab_test_model.dart';

class LabTestDetailsPage extends StatefulWidget {
  final LabTestItem item;
  const LabTestDetailsPage({super.key, required this.item});

  @override
  State<LabTestDetailsPage> createState() => _LabTestDetailsPageState();
}

class _LabTestDetailsPageState extends State<LabTestDetailsPage> {
  bool _showAllDescription = false;
  bool _showAllPrecaution = false;
  bool _showAllPreparation = false;
  bool _showAllParameters = false;

  @override
  Widget build(BuildContext context) {
    final details = widget.item.details;
    final isFasting = details.isFasting?.toLowerCase() == 'yes';

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
          details.name,
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
            _buildHeader(details, isFasting),
            const SizedBox(height: 16),

            // Info Grid
            _buildInfoGrid(details),
            const SizedBox(height: 16),
            // Test Parameters
            if (details.detailedParameters.isNotEmpty) ...[
              _buildTestParametersTable(details.detailedParameters),
              const SizedBox(height: 16),
            ],
            //description
            _buildCollapsibleSection(
              title: "Test Information",
              content: details.description ?? "No description available",
              icon: Icons.description_outlined,
              iconColor: const Color(0xFF059669),
              isExpanded: _showAllDescription,
              onToggle: () =>
                  setState(() => _showAllDescription = !_showAllDescription),
            ),
            // Precaution Section
            if (details.precaution != null &&
                details.precaution!.isNotEmpty) ...[
              _buildCollapsibleSection(
                title: "Precaution",
                content: details.precaution!,
                icon: Icons.warning_amber_rounded,
                iconColor: Colors.orange,
                isExpanded: _showAllPrecaution,
                onToggle: () =>
                    setState(() => _showAllPrecaution = !_showAllPrecaution),
              ),
              const SizedBox(height: 16),
            ],

            // Preparation Instructions Section
            if (details.preparationInstructions != null &&
                details.preparationInstructions!.isNotEmpty) ...[
              _buildCollapsibleSection(
                title: "Preparation Instructions",
                content: details.preparationInstructions!,
                icon: Icons.menu_book_outlined,
                iconColor: Colors.blue,
                isExpanded: _showAllPreparation,
                onToggle: () =>
                    setState(() => _showAllPreparation = !_showAllPreparation),
              ),
              const SizedBox(height: 16),
            ],

            if (details.detailedParameters.isNotEmpty) ...[
              _buildDetailedParametersTable(details.detailedParameters),
              const SizedBox(height: 16),
            ],

            // Description
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LabTestDetails details, bool isFasting) {
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
                    child: details.files.isNotEmpty
                        ? Image.network(
                            details.files.first.startsWith('http')
                                ? details.files.first
                                : "https://api.medicompares.com${details.files.first}",
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
                      child: Text("active",
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
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _chip(details.subcategory?.name ?? "N/A",
                            Icons.style_outlined, Colors.indigo),
                        _chip(details.sampleType ?? "N/A",
                            Icons.biotech_outlined, Colors.purple),
                        _chip(
                            isFasting ? "Fasting" : "No Fasting",
                            isFasting
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline,
                            isFasting ? Colors.orange : Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPriceArea(),
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

  Widget _buildPriceArea() {
    final double saving = widget.item.price - widget.item.discountPrice;
    final int percent = ((saving / widget.item.price) * 100).toInt();

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
              Text("₹${widget.item.price.toInt()}",
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
              Text("₹${widget.item.discountPrice.toInt()}",
                  style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.red[50], borderRadius: BorderRadius.circular(6)),
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

  Widget _buildInfoGrid(LabTestDetails details) {
    return Column(
      children: [
        Row(
          children: [
            _infoItem("CATEGORY", details.subcategory?.name ?? "N/A",
                Icons.style_outlined, Colors.blue),
            const SizedBox(width: 12),
            _infoItem("SAMPLE TYPE", details.sampleType ?? "N/A",
                Icons.biotech_outlined, Colors.purple),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _infoItem("REPORT DURATION", details.reportsDuration ?? "N/A",
                Icons.access_time, Colors.orange),
            const SizedBox(width: 12),
            _infoItem("GENDER", details.gender ?? "Both", Icons.person_outline,
                Colors.green),
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

  Widget _buildTestParametersTable(List<LabTestParameter> params) {
    final showAll = _showAllParameters || params.length <= 3;
    final displayParams = showAll ? params : params.take(3).toList();

    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.analytics_outlined,
                            color: Color(0xFF16A34A), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Test Parameters",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E1B4B))),
                            Text("Parameters evaluated in this test",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (params.length > 3)
                  GestureDetector(
                    onTap: () => setState(
                        () => _showAllParameters = !_showAllParameters),
                    child: Row(
                      children: [
                        Text(_showAllParameters ? "Show Less" : "Show More",
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                        Icon(
                            _showAllParameters
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 18,
                            color: AppColors.primary),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFF8F9FD),
            child: Row(
              children: [
                Expanded(
                    flex: 5,
                    child: Text("PARAMETER NAME",
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                            letterSpacing: 0.5))),
                Expanded(
                    flex: 2,
                    child: Text("NORMAL RANGE",
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                            letterSpacing: 0.5))),
                Expanded(
                    flex: 2,
                    child: Text("UNITS",
                        style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[400],
                            letterSpacing: 0.5))),
              ],
            ),
          ),
          ...displayParams.map((p) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey[100]!))),
                child: Row(
                  children: [
                    Expanded(
                        flex: 5,
                        child: Text(p.name,
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E1B4B)))),
                    Expanded(
                        flex: 2,
                        child: Text(_getValidParameterText(p.normalRange),
                            style: GoogleFonts.inter(
                                fontSize: 11, color: const Color(0xFF475569)))),
                    Expanded(
                        flex: 2,
                        child: Text(_getValidParameterText(p.units),
                            style: GoogleFonts.inter(
                                fontSize: 11, color: const Color(0xFF475569)))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildDetailedParametersTable(List<LabTestParameter> params) {
    final showAll = _showAllParameters || params.length <= 3;
    final displayParams = showAll ? params : params.take(3).toList();

    // Fixed widths per column so header + rows always line up while scrolling
    const double wName = 140;
    const double wDesc = 160;
    const double wRange = 120;
    const double wUnits = 90;
    const double wStatus = 100;
    final double tableWidth = wName + wDesc + wRange + wUnits + wStatus;

    Widget headerCell(String label, double width) => Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(label,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400],
                  letterSpacing: 0.5)),
        );

    Widget dataCell(String text, double width,
            {bool bold = false, Color? color}) =>
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(text,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: color ?? const Color(0xFF475569))),
        );

    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FF),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.list_alt,
                            color: Color(0xFF7C3AED), size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Detailed Test Parameters",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E1B4B))),
                            Text("Parameters included in this test",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                    fontSize: 11, color: Colors.grey[500])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (params.length > 3)
                  GestureDetector(
                    onTap: () => setState(
                        () => _showAllParameters = !_showAllParameters),
                    child: Row(
                      children: [
                        Text(_showAllParameters ? "Show Less" : "Show More",
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary)),
                        Icon(
                            _showAllParameters
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 18,
                            color: AppColors.primary),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Horizontally scrollable table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    color: const Color(0xFFF8F9FD),
                    child: Row(
                      children: [
                        headerCell("PARAMETER NAME", wName),
                        headerCell("DESCRIPTION", wDesc),
                        headerCell("NORMAL RANGE", wRange),
                        headerCell("UNITS", wUnits),
                        headerCell("STATUS", wStatus),
                      ],
                    ),
                  ),
                  ...displayParams.map((p) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: Colors.grey[100]!))),
                        child: Row(
                          children: [
                            dataCell(p.name, wName,
                                bold: true, color: const Color(0xFF1E1B4B)),
                            dataCell(
                                _getValidParameterText(p.description), wDesc),
                            Container(
                              width: wRange,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: _buildNormalRangeCell(p),
                            ),
                            dataCell(_getValidParameterText(p.units), wUnits),
                            dataCell(_getValidParameterText(p.status), wStatus),
                          ],
                        ),
                      )),
                  if (params.isEmpty)
                    const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: Text("No parameters listed"))),
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildDetailedParametersTable(List<LabTestParameter> params) {
  //   final showAll = _showAllParameters || params.length <= 3;
  //   final displayParams = showAll ? params : params.take(3).toList();

  //   return Container(
  //     decoration: BoxDecoration(
  //         color: Colors.white, borderRadius: BorderRadius.circular(16)),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Padding(
  //           padding: const EdgeInsets.all(16),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Expanded(
  //                 child: Row(
  //                   children: [
  //                     Container(
  //                       padding: const EdgeInsets.all(8),
  //                       decoration: BoxDecoration(
  //                           color: const Color(0xFFF5F3FF),
  //                           borderRadius: BorderRadius.circular(8)),
  //                       child: const Icon(Icons.list_alt,
  //                           color: Color(0xFF7C3AED), size: 18),
  //                     ),
  //                     const SizedBox(width: 12),
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text("Detailed Test Parameters",
  //                               overflow: TextOverflow.ellipsis,
  //                               style: GoogleFonts.inter(
  //                                   fontSize: 16,
  //                                   fontWeight: FontWeight.bold,
  //                                   color: const Color(0xFF1E1B4B))),
  //                           Text("Parameters included in this test",
  //                               overflow: TextOverflow.ellipsis,
  //                               style: GoogleFonts.inter(
  //                                   fontSize: 11, color: Colors.grey[500])),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //               if (params.length > 3)
  //                 GestureDetector(
  //                   onTap: () => setState(
  //                       () => _showAllParameters = !_showAllParameters),
  //                   child: Row(
  //                     children: [
  //                       Text(_showAllParameters ? "Show Less" : "Show More",
  //                           style: GoogleFonts.inter(
  //                               fontSize: 12,
  //                               fontWeight: FontWeight.bold,
  //                               color: AppColors.primary)),
  //                       Icon(
  //                           _showAllParameters
  //                               ? Icons.keyboard_arrow_up
  //                               : Icons.keyboard_arrow_down,
  //                           size: 18,
  //                           color: AppColors.primary),
  //                     ],
  //                   ),
  //                 ),
  //             ],
  //           ),
  //         ),
  //         const Divider(height: 1),
  //         // Table Header
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //           color: const Color(0xFFF8F9FD),
  //           child: Row(
  //             children: [
  //               Expanded(
  //                   flex: 4,
  //                   child: Text("PARAMETER NAME",
  //                       style: GoogleFonts.inter(
  //                           fontSize: 10,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.grey[400],
  //                           letterSpacing: 0.5))),
  //               Expanded(
  //                   flex: 2,
  //                   child: Text("DESCRIPTION",
  //                       style: GoogleFonts.inter(
  //                           fontSize: 10,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.grey[400],
  //                           letterSpacing: 0.5))),
  //               Expanded(
  //                   flex: 2,
  //                   child: Text("NORMAL RANGE",
  //                       style: GoogleFonts.inter(
  //                           fontSize: 10,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.grey[400],
  //                           letterSpacing: 0.5))),
  //               Expanded(
  //                   flex: 2,
  //                   child: Text("UNITS",
  //                       style: GoogleFonts.inter(
  //                           fontSize: 10,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.grey[400],
  //                           letterSpacing: 0.5))),
  //               Expanded(
  //                   flex: 2,
  //                   child: Text("STATUS",
  //                       style: GoogleFonts.inter(
  //                           fontSize: 10,
  //                           fontWeight: FontWeight.bold,
  //                           color: Colors.grey[400],
  //                           letterSpacing: 0.5))),
  //             ],
  //           ),
  //         ),
  //         ...displayParams.map((p) => Container(
  //               padding:
  //                   const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //               decoration: BoxDecoration(
  //                   border:
  //                       Border(bottom: BorderSide(color: Colors.grey[100]!))),
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                       child: Text(p.name,
  //                           style: GoogleFonts.inter(
  //                               fontSize: 11,
  //                               fontWeight: FontWeight.bold,
  //                               color: const Color(0xFF1E1B4B)))),
  //                   Expanded(
  //                       child: Text(_getValidParameterText(p.normalRange),
  //                           style: GoogleFonts.inter(
  //                               fontSize: 11, color: const Color(0xFF475569)))),
  //                   Expanded(
  //                       child: Text(_getValidParameterText(p.units),
  //                           style: GoogleFonts.inter(
  //                               fontSize: 11, color: const Color(0xFF475569)))),
  //                 ],
  //               ),
  //             )),
  //         if (params.isEmpty)
  //           const Padding(
  //               padding: EdgeInsets.all(24),
  //               child: Center(child: Text("No parameters listed"))),
  //       ],
  //     ),
  //   );
  // }

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
      child: const Icon(Icons.science_outlined, color: Colors.grey, size: 28),
    );
  }

  String _getValidParameterText(String? text) {
    if (text == null || text.trim().isEmpty || text == "null") {
      return "N/A";
    }
    return text;
  }

  bool _isValidRange(String? text) {
    return text != null && text.trim().isNotEmpty && text != "null";
  }

  Widget _buildNormalRangeCell(LabTestParameter p) {
    final ranges = <MapEntry<String, String>>[];

    if (_isValidRange(p.normalRange)) {
      ranges.add(MapEntry("General", p.normalRange!));
    }
    if (_isValidRange(p.childnormalRange)) {
      ranges.add(MapEntry("Child", p.childnormalRange!));
    }
    if (_isValidRange(p.adultMaleRange)) {
      ranges.add(MapEntry("Male", p.adultMaleRange!));
    }
    if (_isValidRange(p.adultFemaleRange)) {
      ranges.add(MapEntry("Female", p.adultFemaleRange!));
    }

    if (ranges.isEmpty) {
      return Text("N/A",
          style:
              GoogleFonts.inter(fontSize: 11, color: const Color(0xFF475569)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: ranges
          .map((e) => Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: "${e.key}: ",
                    style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1B4B)),
                  ),
                  TextSpan(
                    text: e.value,
                    style: GoogleFonts.inter(
                        fontSize: 10, color: const Color(0xFF475569)),
                  ),
                ]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ))
          .toList(),
    );
  }
}
