import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/ambulance_entity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AmbulanceDetailsPage extends StatelessWidget {
  final AmbulanceEntity ambulance;

  const AmbulanceDetailsPage({super.key, required this.ambulance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4FB),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Ambulance Details",
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
            // Top Card
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
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: const Icon(Icons.airport_shuttle, size: 40, color: Colors.blue),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ambulance.name,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1B1B1B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            _badge(Icons.category, ambulance.ambulanceType.toUpperCase(), Colors.purple[50]!, Colors.purple),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Pricing Information",
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _priceInfo("MRP PRICE", "₹${ambulance.price.toInt()}/km", Colors.grey[100]!, Colors.grey[700]!),
                      const SizedBox(width: 12),
                      _priceInfo("SELLING PRICE", "₹${(ambulance.discountPrice > 0 ? ambulance.discountPrice : ambulance.price).toInt()}/km", const Color(0xFFF0FDF4), const Color(0xFF15803D)),
                    ],
                  ),
                ],
              ),
            ),

            // Facilities Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.medical_services_outlined, color: Colors.orange, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "Included Facilities",
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ambulance.facilities.map((f) => Chip(
                      label: Text(f.name, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500)),
                      backgroundColor: Colors.grey[50],
                      side: BorderSide(color: Colors.grey[200]!),
                      avatar: const Icon(Icons.check_circle, size: 14, color: Colors.green),
                    )).toList(),
                  ),
                  if (ambulance.facilities.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text("No specific facilities listed", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                    ),
                ],
              ),
            ),
            
            // Status Section
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Service Status", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold)),
                  _badge(
                    ambulance.status.toLowerCase() == 'active' ? Icons.check_circle : Icons.error,
                    ambulance.status.toUpperCase(),
                    ambulance.status.toLowerCase() == 'active' ? Colors.green[50]! : Colors.orange[50]!,
                    ambulance.status.toLowerCase() == 'active' ? Colors.green : Colors.orange,
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
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: text),
          ),
        ],
      ),
    );
  }

  Widget _priceInfo(String label, String value, Color bg, Color text) {
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
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600, color: text.withOpacity(0.7)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: text),
            ),
          ],
        ),
      ),
    );
  }
}
