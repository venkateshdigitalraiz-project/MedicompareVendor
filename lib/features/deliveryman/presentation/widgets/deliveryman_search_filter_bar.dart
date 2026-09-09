import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeliverymanSearchFilterBar extends StatefulWidget {
  final String initialSearch;
  final String selectedStatus;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusFilterChanged;

  const DeliverymanSearchFilterBar({
    super.key,
    required this.initialSearch,
    required this.selectedStatus,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
  });

  @override
  State<DeliverymanSearchFilterBar> createState() =>
      _DeliverymanSearchFilterBarState();
}

class _DeliverymanSearchFilterBarState
    extends State<DeliverymanSearchFilterBar> {
  late TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch);
  }

  @override
  void didUpdateWidget(covariant DeliverymanSearchFilterBar oldWidget) {
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
        final isMobile = constraints.maxWidth < 650;
        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSearchInput(),
              const SizedBox(height: 12),
              _buildFilterChips(),
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
          hintText: "Search by name, email, or phone...",
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Filter: ",
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 6),
        _buildFilterChip("All", "all"),
        const SizedBox(width: 6),
        _buildFilterChip("Active", "active"),
        const SizedBox(width: 6),
        _buildFilterChip("Inactive", "inactive"),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = widget.selectedStatus.toLowerCase() == value.toLowerCase();

    return InkWell(
      onTap: () => widget.onStatusFilterChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
