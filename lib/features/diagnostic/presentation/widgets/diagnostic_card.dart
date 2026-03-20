import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/diagnostic_model.dart';

class DiagnosticCard extends StatelessWidget {
  final DiagnosticItem item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DiagnosticCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final details = item.details;
    final baseUrl = 'https://api.medicompares.com';
    String? imageUrl;
    if (details.files.isNotEmpty) {
      final f = details.files.first;
      imageUrl = f.startsWith('http') ? f : '$baseUrl$f';
      imageUrl = Uri.encodeFull(imageUrl);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          details.name,
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _statusBadge(item.status),
                    ],
                  ),
                  if (details.subcategory != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      details.subcategory!.name,
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (details.bodyPart != null) ...[
                        _chip(Icons.location_on_outlined, details.bodyPart!, Colors.blue),
                        const SizedBox(width: 6),
                      ],
                      if (details.isContrast != null)
                        _chip(
                          Icons.contrast,
                          details.isContrast!.toLowerCase() == 'yes' ? 'Contrast' : 'No Contrast',
                          details.isContrast!.toLowerCase() == 'yes' ? Colors.orange : Colors.green,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.price > 0)
                            Text(
                              '₹${item.price.toInt()}',
                              style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[400], decoration: TextDecoration.lineThrough),
                            ),
                          Text(
                            '₹${item.discountPrice.toInt()}',
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      // Actions
                      Row(
                        children: [
                          _actionBtn(Icons.edit_outlined, AppColors.primary, onEdit),
                          const SizedBox(width: 8),
                          _actionBtn(Icons.delete_outline, Colors.red, onDelete),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(12)),
      child: const Icon(Icons.biotech_outlined, color: AppColors.primary, size: 28),
    );
  }

  Widget _statusBadge(String status) {
    final isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.grey).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? Colors.green[700] : Colors.grey[600]),
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
