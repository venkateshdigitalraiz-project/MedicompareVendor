import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/lab_test_package_model.dart';

class LabTestPackageCard extends StatelessWidget {
  final LabTestPackageItem package;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const LabTestPackageCard({
    super.key,
    required this.package,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String name = package.name;
    final int testsCount = package.products.length;
    final String imageUrl = package.files.isNotEmpty ? package.files.first : "";
    
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
            crossAxisAlignment: CrossAxisAlignment.center, // Center vertically since it's more like a list item
            children: [
              // Package Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _placeholderImage(),
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
                      "$testsCount Tests Included",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                     _statusBadge(package.status),
                  ],
                ),
              ),
              
              // Action Buttons & Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      // _actionIcon(Icons.remove_red_eye_outlined, Colors.blue, onTap),
                      // const SizedBox(width: 4),
                      _actionIcon(Icons.edit_outlined, Colors.indigo, onEdit),
                      const SizedBox(width: 4),
                      _actionIcon(Icons.delete_outline, Colors.red, onDelete),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "₹${package.price.toInt()}",
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
      child: const Icon(Icons.inventory_2_outlined, color: Colors.grey),
    );
  }

  Widget _statusBadge(String status) {
    final bool isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle_outline : Icons.error_outline,
            size: 10,
            color: isActive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.green : Colors.red,
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
