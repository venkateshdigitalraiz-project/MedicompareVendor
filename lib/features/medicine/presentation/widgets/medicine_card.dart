// ignore_for_file: dead_null_aware_expression, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:MediCompare/core/utils/permission_handler.dart';
import '../../data/models/medicine_model.dart';
import 'package:MediCompare/core/constants/app_colors.dart';

class MedicineCard extends StatelessWidget {
  final MedicineItem item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicineCard({
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
    final String rawImageUrl = (details.tabletVariants.isNotEmpty &&
            details.tabletVariants.first.files.isNotEmpty)
        ? details.tabletVariants.first.files.first
        : ((details.imageUrl != null && details.imageUrl.isNotEmpty)
            ? details.imageUrl.first
            : (details.tabletImageUrl ?? ""));
    final String imageUrl = _getImageUrl(rawImageUrl);

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
              // Medicine Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        cacheWidth:
                            150, // Optimize memory by resizing image at decode time
                        cacheHeight: 150,
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
                      maxLines: 1,
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
                        _statusBadge(item.status ?? 'inactive'),
                        if (!(item.isStock ?? true)) ...[
                          const SizedBox(width: 8),
                          _outOfStockBadge(),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (PermissionHandler()
                          .hasPermission('medicine', 'edit')) ...[
                        _actionIcon(Icons.edit_outlined, Colors.indigo, onEdit),
                        const SizedBox(width: 4),
                      ],
                      _actionIcon(Icons.delete_outline, Colors.red, onDelete),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (_calculateFinalPrice() < _calculateOriginalPrice() &&
                          _calculateOriginalPrice() > 0)
                        Text(
                          "₹${_calculateOriginalPrice().toStringAsFixed(0)}",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[500],
                          ),
                        ),
                      Text(
                        "₹${_calculateFinalPrice().toStringAsFixed(0)}",
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
            ],
          ),
        ),
      ),
    );
  }

  double _calculateFinalPrice() {
    double price = item.price;
    double discount = item.discountPrice;
    String type = item.discountType;

    // 1st Priority: Vendor specific variants
    if (price == 0 && item.variantDetails.isNotEmpty) {
      final v = item.variantDetails.first;
      price = v.price;
      discount = v.discountPrice;
      type = v.discountType;
    }
    // 2nd Priority: Base variants (common in list responses)
    else if (price == 0 && item.details.tabletVariants.isNotEmpty) {
      price = item.details.tabletVariants.first.price;
      discount = 0; // Usually base variants don't have discount info
    }

    if (type == 'percentage') {
      return price - (price * discount / 100);
    }
    return discount > 0 ? discount : price;
  }

  double _calculateOriginalPrice() {
    double price = item.price;
    if (price == 0 && item.variantDetails.isNotEmpty) {
      price = item.variantDetails.first.price;
    } else if (price == 0 && item.details.tabletVariants.isNotEmpty) {
      price = item.details.tabletVariants.first.price;
    }
    return price;
  }

  Widget _placeholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[100],
      child: const Icon(Icons.medication_outlined, color: Colors.grey),
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

  Widget _outOfStockBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Text(
        "OUT OF STOCK",
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.red,
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
