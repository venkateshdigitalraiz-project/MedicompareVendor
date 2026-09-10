import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/delivery_order_entity.dart';

class DeliveryOrderCard extends StatelessWidget {
  final DeliveryOrderEntity item;
  final VoidCallback onTap;

  const DeliveryOrderCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;
        if (isMobile) {
          return _buildMobileCard(context);
        }
        return _buildDesktopRow(context);
      },
    );
  }

  Widget _buildDesktopRow(BuildContext context) {
    final formattedDate = item.orderDate != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(item.orderDate!)
        : 'N/A';

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFF1F5F9)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          // ORDER ITEM ID
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.orderItemId.startsWith('#')
                      ? item.orderItemId
                      : '#${item.orderItemId}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                if (item.itemName != null && item.itemName!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.itemName!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // CUSTOMER
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.customerName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E1B4B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.customerPhone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.customerPhone,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // DELIVERY ADDRESS
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.deliveryAddress,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF334155),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ASSIGNED PERSONNEL
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.assignedPersonnelName,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: item.assignedPersonnelName.toLowerCase() ==
                            'unassigned'
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF1E1B4B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.assignedPersonnelPhone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.assignedPersonnelPhone,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // STATUS
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusBadge(item.status),
            ),
          ),

          // ORDER DATE
          Expanded(
            flex: 2,
            child: Text(
              formattedDate,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ),

          // ACTIONS
          IconButton(
            icon: const Icon(Icons.visibility_outlined,
                size: 18, color: Color(0xFF3B82F6)),
            onPressed: onTap,
            tooltip: 'View Order Details',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(6),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildMobileCard(BuildContext context) {
    final formattedDate = item.orderDate != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(item.orderDate!)
        : 'N/A';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.orderItemId.startsWith('#')
                          ? item.orderItemId
                          : '#${item.orderItemId}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    _buildStatusBadge(item.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Customer: ${item.customerName} ${item.customerPhone.isNotEmpty ? '(${item.customerPhone})' : ''}",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.deliveryAddress,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Personnel: ${item.assignedPersonnelName}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String rawStatus) {
    final status = rawStatus.toLowerCase().replaceAll('-', '_');
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'delivered':
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF16A34A);
        label = 'Delivered';
        break;
      case 'in_transit':
      case 'out_for_delivery':
        bg = const Color(0xFFDBEAFE);
        fg = const Color(0xFF2563EB);
        label = 'In-Transit';
        break;
      case 'assigned':
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF4338CA);
        label = 'Assigned';
        break;
      case 'cancelled':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        label = 'Cancelled';
        break;
      case 'pending':
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        label = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
