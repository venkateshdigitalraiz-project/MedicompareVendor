import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/core/utils/price_formatter.dart';
import '../../domain/entities/lab_test_visit_fee.dart';

class LabTestVisitFeeCard extends StatelessWidget {
  final LabTestVisitFee fee;

  const LabTestVisitFeeCard({super.key, required this.fee});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      color: AppColors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science_outlined, color: AppColors.primaryDark),
                const SizedBox(width: 8),
                Text(
                  "Lab Tests",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.border),
            Text(
              "Visit Charges",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.greyText,
              ),
            ),
            const SizedBox(height: 12),
            _buildRow("Visit Type", fee.visitType.toUpperCase()),
            _buildRow("Home Visit Fee", fee.homeVisitFee.toRupeeFormat()),
            _buildRow("Urgent Surcharge", fee.urgentSurcharge.toRupeeFormat()),
            _buildRow("Maximum Radius", "${fee.maxRadius.toStringAsFixed(0)} km"),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.greyText,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
