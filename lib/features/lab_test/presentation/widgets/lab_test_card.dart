import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:MediCompare/core/utils/permission_handler.dart';

import '../../data/models/lab_test_model.dart';

class LabTestCard extends StatelessWidget {
  final LabTestItem item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LabTestCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final details = item.details;
    final String name = details.name;
    final String category = details.subcategory?.name ?? "No Category";
    final isFasting = details.isFasting?.toLowerCase() == 'yes';
    final String imageUrl = details.files.isNotEmpty
        ? details.files.first.startsWith('http')
            ? details.files.first
            : "https://api.medicompares.com${details.files.first}"
        : "";

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lab Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _placeholderImage(),
                      )
                    : _placeholderImage(),
              ),
              const SizedBox(width: 12),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1B4B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // _statusBadge(item.status),
                        // const SizedBox(width: 8),
                        _fastingBadge(isFasting),
                        if (details.sampleType != null &&
                            details.sampleType!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          _sampleTypeBadge(details.sampleType!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons & Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (PermissionHandler()
                          .hasPermission('lab-tests', 'edit')) ...[
                        _actionIcon(Icons.edit_outlined, Colors.indigo, onEdit),
                        const SizedBox(width: 4),
                      ],
                      _actionIcon(Icons.delete_outline, Colors.red, onDelete),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "₹${item.discountPrice.toInt()}",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[100],
      child: const Icon(Icons.science_outlined, color: Colors.grey),
    );
  }

  // Widget _statusBadge(String status) {
  //   final bool isActive = status.toLowerCase() == 'active';
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //     decoration: BoxDecoration(
  //       color: (isActive ? Colors.green : Colors.red).withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(12),
  //     ),
  //     child: Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(
  //           isActive ? Icons.check_circle_outline : Icons.error_outline,
  //           size: 10,
  //           color: isActive ? Colors.green : Colors.red,
  //         ),
  //         const SizedBox(width: 4),
  //         Text(
  //           status.toUpperCase(),
  //           style: GoogleFonts.inter(
  //             fontSize: 9,
  //             fontWeight: FontWeight.bold,
  //             color: isActive ? Colors.green : Colors.red,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _fastingBadge(bool isFasting) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isFasting ? Colors.orange : Colors.blue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isFasting
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            size: 10,
            color: isFasting ? Colors.orange : Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            isFasting ? "Fasting" : "No Fasting",
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isFasting ? Colors.orange : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sampleTypeBadge(String sampleType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bloodtype_outlined,
            size: 10,
            color: Colors.purple,
          ),
          const SizedBox(width: 4),
          Text(
            sampleType,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
