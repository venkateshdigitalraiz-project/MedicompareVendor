import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliverymanPaginationBar extends StatelessWidget {
  final int page;
  final int totalPages;
  final int total;
  final int limit;
  final int itemCount;
  final ValueChanged<int> onPageChanged;

  const DeliverymanPaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.limit,
    required this.itemCount,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentPage = page > 0 ? page : 1;
    final maxPages = totalPages > 0 ? totalPages : 1;
    final totalCount = total > 0 ? total : itemCount;
    final perPage = limit > 0 ? limit : 10;

    final start = totalCount == 0 ? 0 : (currentPage - 1) * perPage + 1;
    final end = (currentPage * perPage) > totalCount
        ? totalCount
        : (currentPage * perPage);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Showing $start-$end of $totalCount",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              if (isMobile) const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // First page button
                  _buildNavButton(
                    icon: Icons.keyboard_double_arrow_left,
                    enabled: currentPage > 1,
                    onTap: () => onPageChanged(1),
                  ),
                  const SizedBox(width: 4),
                  // Prev button
                  _buildNavButton(
                    icon: Icons.chevron_left,
                    enabled: currentPage > 1,
                    onTap: () => onPageChanged(currentPage - 1),
                  ),
                  const SizedBox(width: 6),
                  // Page number buttons
                  ..._buildPageNumbers(currentPage, maxPages),
                  const SizedBox(width: 6),
                  // Next button
                  _buildNavButton(
                    icon: Icons.chevron_right,
                    enabled: currentPage < maxPages,
                    onTap: () => onPageChanged(currentPage + 1),
                  ),
                  const SizedBox(width: 4),
                  // Last page button
                  _buildNavButton(
                    icon: Icons.keyboard_double_arrow_right,
                    enabled: currentPage < maxPages,
                    onTap: () => onPageChanged(maxPages),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildPageNumbers(int currentPage, int maxPages) {
    List<Widget> pages = [];
    int startPage = (currentPage - 1).clamp(1, maxPages);
    int endPage = (currentPage + 1).clamp(1, maxPages);

    for (int i = startPage; i <= endPage; i++) {
      final isCurrent = i == currentPage;
      pages.add(
        InkWell(
          onTap: isCurrent ? null : () => onPageChanged(i),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrent ? const Color(0xFF1E1B4B) : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              "$i",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                color: isCurrent ? Colors.white : const Color(0xFF475569),
              ),
            ),
          ),
        ),
      );
      if (i < endPage) {
        pages.add(const SizedBox(width: 4));
      }
    }
    return pages;
  }

  Widget _buildNavButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: Icon(
          icon,
          size: 16,
          color: enabled ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
        ),
      ),
    );
  }
}
