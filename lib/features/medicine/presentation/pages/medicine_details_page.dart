import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

  @override
  Widget build(BuildContext context) {
    final details = widget.medicine.details;
    final imageUrl = details.imageUrl.isNotEmpty
        ? details.imageUrl.first
        : (details.tabletImageUrl ?? "");

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
                              : const Icon(Icons.medication, size: 30, color: Colors.grey),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "SELLING PRICE: ",
                                    style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.w600, color: const Color(0xFF166534)),
                                  ),
                                  Text(
                                    "₹${widget.medicine.price.toInt()}",
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF15803D)),
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
                  // Badges (Full width wrap)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _badge(Icons.business, details.manufacture?.name ?? "N/A", const Color(0xFFE8EEFF), const Color(0xFF506CCF)),
                      // _badge(Icons.layers, details.form ?? "N/A", const Color(0xFFF3E8FF), const Color(0xFF9333EA)),
                      // _badge(Icons.label_important_outline, details.subcategory?.name ?? "N/A", const Color(0xFFE6FFFA), const Color(0xFF0D9488)),
                      _badge(Icons.science_outlined, details.composition ?? "N/A", const Color(0xFFFFF7ED), const Color(0xFFC2410C)),
                      // _badge(Icons.history, "Return Date: 7 Days", const Color(0xFFFEF2F2), const Color(0xFFB91C1C)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Grid Info Cards
                  Row(
                    children: [
                      _infoCard("CATEGORY", details.subcategory?.name ?? "N/A", const Color(0xFFE8F1FF), Icons.category_outlined),
                      const SizedBox(width: 12),
                      _infoCard("FORM", details.form ?? "N/A", const Color(0xFFF5EAFC), Icons.table_chart_outlined),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _infoCard("STRENGTH", "N/A", const Color(0xFFFFF6E5), Icons.fitness_center),
                      const SizedBox(width: 12),
                      _infoCard("MANUFACTURER", details.manufacture?.name ?? "N/A", const Color(0xFFEAF9F1), Icons.domain),
                    ],
                  ),
                ],
              ),
            ),

            // Medicine Information Section
            // Container(
            //   margin: const EdgeInsets.symmetric(horizontal: 12),
            //   padding: const EdgeInsets.all(20),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(16),
            //   ),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Row(
            //         children: [
            //           _iconBox(Icons.info_outline, const Color(0xFFF3E8FF), const Color(0xFF9333EA)),
            //           const SizedBox(width: 12),
            //           Column(
            //             crossAxisAlignment: CrossAxisAlignment.start,
            //             children: [
            //               Text("Medicine Information", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            //               Text("Complete details about the medicine", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
            //             ],
            //           ),
            //         ],
            //       ),
            //       const SizedBox(height: 24),
            //       _detailField("MEDICINE NAME", details.name, Icons.link, const Color(0xFFEFF6FF)),
            //       const SizedBox(height: 12),
            //       Row(
            //        children: [
            //           Expanded(child: _detailField("CREATED DATE", details.createdAt != null ? DateFormat('MMMM d, yyyy').format(details.createdAt!) : "N/A", Icons.calendar_today, const Color(0xFFFEF2F2))),
            //        ],
            //       ),
            //       const SizedBox(height: 12),
            //       _detailField("COMPOSITION", details.composition ?? "N/A", Icons.science_outlined, const Color(0xFFFAF5FF)),
            //     ],
            //   ),
            // ),

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
                          _iconBox(Icons.description_outlined, const Color(0xFFEAF9F1), const Color(0xFF15803D)),
                          const SizedBox(width: 12),
                          Text(
                            "Description",
                            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => setState(() => isExpanded = !isExpanded),
                        child: Row(
                          children: [
                            Text(
                              isExpanded ? "Show Less" : "Show More",
                              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 16, color: AppColors.primary),
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
                          textStyle: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF4B5563), height: 1.6),
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
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: text),
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
                Icon(icon, size: 14, color: Colors.indigo[900]?.withOpacity(0.5)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.indigo[900]?.withOpacity(0.6)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF1E1B4B)),
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
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _detailField(String label, String value, IconData icon, Color bg) {
    return Container(
      width: double.infinity,
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
              Icon(icon, size: 14, color: AppColors.primary.withOpacity(0.6)),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary.withOpacity(0.7)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1E1B4B)),
          ),
        ],
      ),
    );
  }
}
