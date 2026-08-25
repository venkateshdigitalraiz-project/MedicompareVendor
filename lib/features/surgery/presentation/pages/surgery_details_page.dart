import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:MediCompare/core/utils/price_formatter.dart';
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

  double _calculateFinalPrice() {
    final item = _currentSurgery;
    double price = item.effectivePrice;
    double discount = item.effectiveDiscountPrice;
    String type = item.effectiveDiscountType ?? 'price';

    // Only fall back to variantDetails when NOT a mix-variant product
    if (!item.isVariant && price == 0 && item.variantDetails.isNotEmpty) {
      final v = item.variantDetails.first;
      price = v.price;
      discount = v.discountPrice;
      type = v.discountType;
    }

    if (type == 'percentage') {
      return price - (price * discount / 100);
    }
    // Return discount if it exists, otherwise price
    return discount > 0 ? discount : price;
  }

  double _calculateOriginalPrice() {
    final item = _currentSurgery;
    double price = item.effectivePrice;
    if (!item.isVariant && price == 0 && item.variantDetails.isNotEmpty) {
      price = item.variantDetails.first.price;
    }
    return price;
  }

  @override
  Widget build(BuildContext context) {
    final details = _currentSurgery.details;
    final imageUrl = details.files.isNotEmpty
        ? _getSurgeryImageUrl(details.files.first)
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
                                      if (_calculateOriginalPrice() > 0 &&
                                          _calculateFinalPrice() > 0 &&
                                          _calculateOriginalPrice() >
                                              _calculateFinalPrice())
                                        Text(
                                          "MRP: ${_calculateOriginalPrice().toRupeeFormat()}",
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.grey[500]),
                                        ),
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
                                              _calculateOriginalPrice() == 0
                                                  ? (_currentSurgery.isVariant
                                                      ? "Price varies by variant"
                                                      : "From ")
                                                  : "Selling Price: ",
                                              style: GoogleFonts.poppins(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      const Color(0xFF166534)),
                                            ),
                                            Text(
                                              _calculateOriginalPrice() == 0 &&
                                                      _currentSurgery.isVariant
                                                  ? " ₹0"
                                                  : _calculateFinalPrice()
                                                      .toRupeeFormat(),
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
                            // Wrap(
                            //   spacing: 8,
                            //   runSpacing: 8,
                            //   children: [
                            //     _badge(
                            //         Icons.category_outlined,
                            //         details.subcategory?.name ?? "N/A",
                            //         const Color(0xFFE8EEFF),
                            //         const Color(0xFF506CCF)),
                            //     _badge(
                            //         Icons.settings_suggest_outlined,
                            //         details.procedureType ?? "N/A",
                            //         const Color(0xFFF3E8FF),
                            //         const Color(0xFF9333EA)),
                            //     _badge(
                            //         Icons.star_outline,
                            //         details.complexity ?? "Simple",
                            //         const Color(0xFFE6FFFA),
                            //         const Color(0xFF0D9488)),
                            //   ],
                            // ),
                            // const SizedBox(height: 24),
                            // Grid Info Cards
                            Row(
                              children: [
                                _infoCard(
                                    "CATEGORY",
                                    details.subcategory?.name ?? "N/A",
                                    const Color(0xFFF9F8EF),
                                    Icons.category_outlined),
                                const SizedBox(width: 12),
                                _infoCard(
                                    "STATUS",
                                    details.status ?? "N/A",
                                    const Color(0xFFE3DDDE),
                                    Icons.healing_outlined),
                              ],
                            ),
                            const SizedBox(height: 12),
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

                      const SizedBox(height: 8),

                      _buildVariantsTable(),

                      // Detail Sections
                      if (details.description != null &&
                          details.description!.isNotEmpty)
                        ExpandableHtmlSection(
                          title: "Surgery Information",
                          htmlContent: details.description!,
                          icon: Icons.description_outlined,
                          bg: const Color(0xFFEAF9F1),
                          color: const Color(0xFF15803D),
                        ),
                      if (details.precaution != null &&
                          details.precaution!.isNotEmpty)
                        ExpandableHtmlSection(
                          title: "Precaution Guidelines",
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
                      if (details.directionOfUse != null &&
                          details.directionOfUse!.isNotEmpty)
                        ExpandableHtmlSection(
                          title: "Pre Care & Post Care Surgery",
                          htmlContent: details.directionOfUse!,
                          icon: Icons.assignment_outlined,
                          bg: const Color(0xFFEFF6FF),
                          color: const Color(0xFF1D4ED8),
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildVariantsTable() {
    final item = _currentSurgery;

    // When is_variant==true, show allMixVariants (the actual variant list from API)
    if (item.isVariant && item.allMixVariants.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.list_alt,
                      color: Color(0xFF9333EA), size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Surgery Variants",
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("Available options and pricing",
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                horizontalMargin: 0,
                headingRowHeight: 40,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                columns: [
                  DataColumn(label: _tableHeader("VARIANT NAME")),
                  DataColumn(label: _tableHeader("PRICE")),
                  DataColumn(label: _tableHeader("SELLING PRICE")),
                ],
                rows: item.allMixVariants.map((v) {
                  return DataRow(cells: [
                    DataCell(Text(v.name,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937)))),
                    DataCell(Text(
                      v.price != null && v.price! > 0
                          ? v.price!.toRupeeFormat()
                          : 'Contact for price',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: v.price != null && v.price! > 0
                              ? const Color(0xFF374151)
                              : Colors.grey),
                    )),
                    DataCell(Text(
                      v.discountPrice != null && v.discountPrice! > 0
                          ? v.discountPrice!.toRupeeFormat()
                          : (v.price != null && v.price! > 0
                              ? v.price!.toRupeeFormat()
                              : '-'),
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF15803D)),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }

    // When is_variant==false, show variantDetails (the old table)
    final variants = item.variantDetails;
    if (variants.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.list_alt,
                    color: Color(0xFF9333EA), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Surgery Variants",
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Available options and pricing",
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 24,
              horizontalMargin: 0,
              headingRowHeight: 40,
              dataRowMinHeight: 48,
              dataRowMaxHeight: 56,
              columns: [
                DataColumn(label: _tableHeader("VARIANT NAME")),
                DataColumn(label: _tableHeader("PRICE")),
                DataColumn(label: _tableHeader("SELLING PRICE")),
                DataColumn(label: _tableHeader("STATUS")),
              ],
              rows: variants.map((v) {
                final tvMatch =
                    _currentSurgery.details.tabletVariants.firstWhere(
                  (tv) => tv.id == v.variantId,
                  orElse: () => SurgeryTabletVariant(
                      id: v.variantId,
                      tabletId: '',
                      name: 'Option',
                      price: v.price,
                      files: const []),
                );

                double sellingPrice = v.discountPrice;
                if (v.discountType == 'percentage') {
                  sellingPrice = v.price - (v.price * v.discountPrice / 100);
                } else if (v.discountPrice <= 0) {
                  sellingPrice = v.price;
                }

                return DataRow(cells: [
                  DataCell(Text(tvMatch.name,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937)))),
                  DataCell(Text(v.price.toRupeeFormat(),
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151)))),
                  DataCell(Text(sellingPrice.toRupeeFormat(),
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF15803D)))),
                  DataCell(_tableStatusBadge(v.status)),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF9CA3AF),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _tableStatusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'active' : 'inactive',
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isActive ? const Color(0xFF16A34A) : Colors.grey[600],
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

  String _getSurgeryImageUrl(String url) {
    if (url.isEmpty) return "";
    if (url.startsWith('http')) return url;
    final cleanPath = url.startsWith('/') ? url : '/$url';
    return "https://api.medicompares.com$cleanPath";
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
