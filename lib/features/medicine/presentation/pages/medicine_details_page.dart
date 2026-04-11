import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/medicine/medicine_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../data/models/medicine_model.dart';

class MedicineDetailsPage extends StatefulWidget {
  final MedicineItem medicine;

  const MedicineDetailsPage({super.key, required this.medicine});

  @override
  State<MedicineDetailsPage> createState() => _MedicineDetailsPageState();
}

class _MedicineDetailsPageState extends State<MedicineDetailsPage> {
  bool isExpanded = false;
  late MedicineItem _currentMedicine;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentMedicine = widget.medicine;
    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    try {
      final service = MedicineInjection.provideMedicineService();
      final fullMedicineJson = await service.getVendorMedicineDetails(widget.medicine.id);
      if (mounted) {
        setState(() {
          _currentMedicine = MedicineItem.fromJson(fullMedicineJson);
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

  double _calculateFinalPrice() {
    final item = _currentMedicine;
    double discount = item.discountPrice;
    double price = item.price;
    String type = item.discountType;

    if (price == 0 && item.variantDetails.isNotEmpty) {
      final v = item.variantDetails.first;
      price = v.price;
      discount = v.discountPrice;
      type = v.discountType;
    }

    if (type == 'percentage') {
      return price - (price * discount / 100);
    }
    return discount > 0 ? discount : price;
  }

  double _calculateOriginalPrice() {
    final item = _currentMedicine;
    double price = item.price;

    if (price == 0 && item.variantDetails.isNotEmpty) {
      price = item.variantDetails.first.price;
    }
    return price;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text("Medicine Details", style: GoogleFonts.poppins(color: Colors.white)),
          leading: const BackButton(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
       return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Text("Error", style: GoogleFonts.poppins(color: Colors.white)),
          leading: const BackButton(color: Colors.white),
        ),
        body: Center(child: Text(_error!)),
      );
    }

    final details = _currentMedicine.details;
    final String rawImageUrl = (details.tabletVariants.isNotEmpty &&
            details.tabletVariants.first.files.isNotEmpty)
        ? details.tabletVariants.first.files.first
        : (details.imageUrl.isNotEmpty
            ? details.imageUrl.first
            : (details.tabletImageUrl ?? ""));
    final String imageUrl = _getImageUrl(rawImageUrl);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FB),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Medicine Details",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
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
                            border: Border.all(color: Colors.grey[100]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: imageUrl.isNotEmpty
                              ? Image.network(imageUrl, fit: BoxFit.contain)
                              : const Icon(Icons.medication,
                                  size: 30, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Name and Price
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              details.name,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B1B1B),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0FDF4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Selling Price: ",
                                        style: GoogleFonts.poppins(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF166534)),
                                      ),
                                      if (_calculateFinalPrice() <
                                              _calculateOriginalPrice() &&
                                          _calculateOriginalPrice() > 0) ...[
                                        Text(
                                          "₹${_calculateOriginalPrice().toStringAsFixed(0)}",
                                          style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: const Color(0xFF166534)
                                                  .withOpacity(0.5)),
                                        ),
                                        const SizedBox(width: 4),
                                      ],
                                      Text(
                                        "₹${_calculateFinalPrice().toStringAsFixed(0)}",
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF15803D)),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!widget.medicine.isStock) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          Border.all(color: Colors.red[100]!),
                                    ),
                                    child: Text(
                                      "Out of Stock",
                                      style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red[500]),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Badges (Full width wrap)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _badge(Icons.business, details.manufacture?.name ?? "N/A",
                          const Color(0xFFE8EEFF), const Color(0xFF506CCF)),
                      // _badge(Icons.layers, details.form ?? "N/A", const Color(0xFFF3E8FF), const Color(0xFF9333EA)),
                      // _badge(Icons.label_important_outline, details.subcategory?.name ?? "N/A", const Color(0xFFE6FFFA), const Color(0xFF0D9488)),
                      _badge(
                          Icons.science_outlined,
                          details.composition ?? "N/A",
                          const Color(0xFFFFF7ED),
                          const Color(0xFFC2410C)),
                      if (widget.medicine.returnDetails != null &&
                          widget.medicine.returnDetails!.isNotEmpty)
                        _badge(
                            Icons.history_outlined,
                            "Return: ${widget.medicine.returnDetails} days",
                            const Color(0xFFFEF2F2),
                            const Color(0xFFB91C1C)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Grid Info Cards
                  Row(
                    children: [
                      _infoCard("CATEGORY", details.subcategory?.name ?? "N/A",
                          const Color(0xFFE8F1FF), Icons.category_outlined),
                      const SizedBox(width: 12),
                      _infoCard("FORM", details.form ?? "N/A",
                          const Color(0xFFF5EAFC), Icons.table_chart_outlined),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _infoCard("STRENGTH", details.strength ?? "N/A",
                          const Color(0xFFFFF6E5), Icons.fitness_center),
                      const SizedBox(width: 12),
                      _infoCard(
                          "MANUFACTURER",
                          details.manufacture?.name ?? "N/A",
                          const Color(0xFFEAF9F1),
                          Icons.domain),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            _buildVariantsTable(),

            // Description Section
            Container(
              margin: const EdgeInsets.all(12),
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
                      Row(
                        children: [
                          _iconBox(Icons.description_outlined,
                              const Color(0xFFEAF9F1), const Color(0xFF15803D)),
                          const SizedBox(width: 12),
                          Text(
                            "Description",
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () =>
                            setState(() => isExpanded = !isExpanded),
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
                            Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                size: 16,
                                color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: isExpanded ? double.infinity : 160,
                    ),
                    child: ClipRect(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: HtmlWidget(
                          details.description ?? "No description available.",
                          textStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: const Color(0xFF4B5563),
                              height: 1.6),
                          renderMode: RenderMode.column,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              label,
              style: GoogleFonts.poppins(
                  fontSize: 11, fontWeight: FontWeight.w500, color: text),
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

  Widget _iconBox(IconData icon, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildVariantsTable() {
    final variants = _currentMedicine.variantDetails;
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
              _iconBox(Icons.list_alt, const Color(0xFFF3E8FF),
                  const Color(0xFF9333EA)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Variant Details",
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("Available variants and pricing",
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
                DataColumn(label: _tableHeader("STOCK")),
                DataColumn(label: _tableHeader("STATUS")),
              ],
              rows: variants.map((v) {
                final tvMatch =
                    _currentMedicine.details.tabletVariants.firstWhere(
                  (tv) => tv.id == v.variantId,
                  orElse: () => const TabletVariant(
                      id: '',
                      tabletId: '',
                      name: 'Unknown',
                      price: 0,
                      files: []),
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
                  DataCell(Text("₹${v.price.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF374151)))),
                  DataCell(Text("₹${sellingPrice.toStringAsFixed(0)}",
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600, // Emphasis on selling price
                          color: const Color(0xFF15803D)))),
                  DataCell(Text("${v.stock ?? 0}",
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: const Color(0xFF374151)))),
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

  String _getImageUrl(String url) {
    if (url.isEmpty) return "";
    if (url.startsWith('http')) return url;
    final cleanPath = url.startsWith('/') ? url : '/$url';
    return "https://api.medicompares.com$cleanPath";
  }
}
