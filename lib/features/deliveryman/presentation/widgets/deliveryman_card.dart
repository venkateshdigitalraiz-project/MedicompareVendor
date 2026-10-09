import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/deliveryman_entity.dart';

class DeliverymanCard extends StatelessWidget {
  final DeliverymanEntity item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DeliverymanCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 750;

        if (isMobile) {
          return _buildMobileCard(context);
        }

        return _buildDesktopRow(context);
      },
    );
  }

  Widget _buildDesktopRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // DELIVERYMAN
          Expanded(
            flex: 3,
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.fullName,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E1B4B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.vehicleType.toLowerCase() == 'car'
                                ? Icons.directions_car_outlined
                                : Icons.two_wheeler_outlined,
                            size: 14,
                            color: const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              "${item.vehicleType} ${item.vehicleNumber}".trim(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // CONTACT INFO
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.email.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mail_outline, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          item.email,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF334155),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (item.email.isNotEmpty && item.phone.isNotEmpty)
                  const SizedBox(height: 4),
                if (item.phone.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 6),
                      Text(
                        item.phone,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // STATUS
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusBadge(),
            ),
          ),

          // TOTAL DELIVERIES
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Icon(
                  Icons.local_shipping_outlined,
                  size: 16,
                  color: Color(0xFF475569),
                ),
                const SizedBox(width: 6),
                Text(
                  "${item.totalDeliveries}",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
              ],
            ),
          ),

          // ACTIONS
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF3B82F6)),
                onPressed: onEdit,
                tooltip: 'Edit Deliveryman',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                onPressed: onDelete,
                tooltip: 'Delete Deliveryman',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.fullName,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          item.vehicleType.toLowerCase() == 'car'
                              ? Icons.directions_car_outlined
                              : Icons.two_wheeler_outlined,
                          size: 13,
                          color: const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${item.vehicleType} ${item.vehicleNumber}".trim(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: const Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          if (item.email.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.mail_outline, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.email,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF334155),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          if (item.phone.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 6),
                Text(
                  item.phone,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF334155),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping_outlined,
                    size: 16,
                    color: Color(0xFF475569),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Deliveries: ${item.totalDeliveries}",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF3B82F6)),
                    onPressed: onEdit,
                    tooltip: 'Edit',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                    onPressed: onDelete,
                    tooltip: 'Delete',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.group_outlined,
        color: Color(0xFF6366F1),
        size: 20,
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isActive = item.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? "Active" : "Inactive",
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
            ),
          ),
        ],
      ),
    );
  }
}
