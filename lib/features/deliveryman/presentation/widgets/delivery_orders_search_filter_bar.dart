import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliveryOrdersSearchFilterBar extends StatefulWidget {
  final String initialSearch;
  final String selectedStatus;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusFilterChanged;

  const DeliveryOrdersSearchFilterBar({
    super.key,
    required this.initialSearch,
    required this.selectedStatus,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
  });

  @override
  State<DeliveryOrdersSearchFilterBar> createState() =>
      _DeliveryOrdersSearchFilterBarState();
}

class _DeliveryOrdersSearchFilterBarState
    extends State<DeliveryOrdersSearchFilterBar> {
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch);
  }

  @override
  void didUpdateWidget(covariant DeliveryOrdersSearchFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSearch != widget.initialSearch &&
        _searchController.text != widget.initialSearch) {
      _searchController.text = widget.initialSearch;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      widget.onSearchChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;
        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchInput(),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildFilterChips(),
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: _buildSearchInput()),
            const SizedBox(width: 16),
            _buildFilterChips(),
          ],
        );
      },
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearch,
        style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1E1B4B)),
        decoration: InputDecoration(
          hintText: "Search by order ID, customer, address...",
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF94A3B8),
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 20,
            color: Color(0xFF94A3B8),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    _searchController.clear();
                    widget.onSearchChanged('');
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFilterChip("All", "all"),
        const SizedBox(width: 6),
        _buildFilterChip("Pending", "pending"),
        const SizedBox(width: 6),
        _buildFilterChip("Assigned", "assigned"),
        const SizedBox(width: 6),
        _buildFilterChip("In-Transit", "in_transit"),
        const SizedBox(width: 6),
        _buildFilterChip("Delivered", "delivered"),
        const SizedBox(width: 6),
        _buildFilterChip("Cancelled", "cancelled"),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected =
        widget.selectedStatus.toLowerCase().replaceAll('-', '_') ==
            value.toLowerCase().replaceAll('-', '_');

    return InkWell(
      onTap: () => widget.onStatusFilterChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E1B4B) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
