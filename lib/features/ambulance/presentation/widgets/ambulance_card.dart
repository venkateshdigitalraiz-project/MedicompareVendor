import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:MediCompare/core/utils/permission_handler.dart';
import '../../domain/entities/ambulance_entity.dart';
import 'package:MediCompare/core/constants/app_colors.dart';

class AmbulanceCard extends StatelessWidget {
  final AmbulanceEntity item;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AmbulanceCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
              // Ambulance Icon Placeholder or Image if available
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.files.isNotEmpty
                    ? Image.network(
                        _getAmbulanceImageUrl(item.files.first),
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
                      item.name,
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
                      item.ambulanceType.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item.facilities.length} Facilities",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _statusBadge(item.status),
                  ],
                ),
              ),

              // Action Buttons & Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      if (PermissionHandler()
                          .hasPermission('ambulance', 'edit')) ...[
                        _actionIcon(Icons.edit_outlined, Colors.indigo, onEdit),
                        const SizedBox(width: 8),
                      ],
                      _actionIcon(Icons.delete_outline, Colors.red, onDelete),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (item.discountPrice > 0 &&
                          item.discountPrice < item.price)
                        Text(
                          "₹${item.price.toInt()}",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                      Text(
                        "₹${(item.discountPrice > 0 ? item.discountPrice : item.price).toInt()}/km",
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

  Widget _statusBadge(String status) {
    final bool isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (isActive ? Colors.green : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle_outline : Icons.error_outline,
            size: 10,
            color: isActive ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.green : Colors.orange,
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

  Widget _placeholderImage() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.blue[50],
      child: const Icon(Icons.airport_shuttle_outlined,
          color: Colors.blue, size: 30),
    );
  }

  String _getAmbulanceImageUrl(String url) {
    if (url.isEmpty) return "";
    if (url.startsWith('http')) return url;
    final cleanPath = url.startsWith('/') ? url : '/$url';
    return "https://api.medicompares.com$cleanPath";
  }
}
