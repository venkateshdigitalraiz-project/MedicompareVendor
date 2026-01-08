import 'package:flutter/material.dart';

enum PayoutFilter { all, completed, pending, failed }

class PayoutFilterTabs extends StatelessWidget {
  final PayoutFilter selected;
  final ValueChanged<PayoutFilter> onChanged;

  const PayoutFilterTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _tab('All', PayoutFilter.all),
          _tab('Completed', PayoutFilter.completed),
          _tab('Pending', PayoutFilter.pending),
          _tab('Failed', PayoutFilter.failed),
        ],
      ),
    );
  }

  Widget _tab(String label, PayoutFilter value) {
    final isSelected = selected == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF7B4EE4) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
          ),
        ),
      ),
    );
  }
}
