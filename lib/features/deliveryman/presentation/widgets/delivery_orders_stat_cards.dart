import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/delivery_order_entity.dart';

class DeliveryOrdersStatCards extends StatelessWidget {
  final DeliveryOrdersSummaryEntity summary;

  const DeliveryOrdersStatCards({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        if (isMobile) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: "Total Orders",
                      value: "${summary.totalOrders}",
                      valueColor: const Color(0xFF1E1B4B),
                      icon: Icons.shopping_cart_outlined,
                      iconColor: const Color(0xFF6366F1),
                      iconBgColor: const Color(0xFFEEF2FF),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: "Delivered",
                      value: "${summary.delivered}",
                      valueColor: const Color(0xFF16A34A),
                      icon: Icons.inventory_2_outlined,
                      iconColor: const Color(0xFF22C55E),
                      iconBgColor: const Color(0xFFDCFCE7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: "In Transit",
                      value: "${summary.inTransit}",
                      valueColor: const Color(0xFF2563EB),
                      icon: Icons.access_time_outlined,
                      iconColor: const Color(0xFF3B82F6),
                      iconBgColor: const Color(0xFFDBEAFE),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      title: "Assigned / Pending",
                      value: "${summary.assignedPending}",
                      valueColor: const Color(0xFFD97706),
                      icon: Icons.person_outline,
                      iconColor: const Color(0xFFF59E0B),
                      iconBgColor: const Color(0xFFFEF3C7),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "Total Orders",
                value: "${summary.totalOrders}",
                valueColor: const Color(0xFF1E1B4B),
                icon: Icons.shopping_cart_outlined,
                iconColor: const Color(0xFF6366F1),
                iconBgColor: const Color(0xFFEEF2FF),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "Delivered",
                value: "${summary.delivered}",
                valueColor: const Color(0xFF16A34A),
                icon: Icons.inventory_2_outlined,
                iconColor: const Color(0xFF22C55E),
                iconBgColor: const Color(0xFFDCFCE7),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "In Transit",
                value: "${summary.inTransit}",
                valueColor: const Color(0xFF2563EB),
                icon: Icons.access_time_outlined,
                iconColor: const Color(0xFF3B82F6),
                iconBgColor: const Color(0xFFDBEAFE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "Assigned / Pending",
                value: "${summary.assignedPending}",
                valueColor: const Color(0xFFD97706),
                icon: Icons.person_outline,
                iconColor: const Color(0xFFF59E0B),
                iconBgColor: const Color(0xFFFEF3C7),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color valueColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ],
      ),
    );
  }
}
