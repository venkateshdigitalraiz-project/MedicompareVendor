import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text.dart';

class RecentMedicineTile extends StatelessWidget {
  final String name;
  final String quantity;
  final String status;

  const RecentMedicineTile({
    super.key,
    required this.name,
    required this.quantity,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isLow = status == "Low Stock";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppText.body.copyWith(fontSize: 16)),
                Text(quantity, style: AppText.small),
              ],
            ),
          ),
          const Icon(LineIcons.edit),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (isLow ? AppColors.warning : AppColors.success)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: AppText.small.copyWith(
                color: isLow ? AppColors.warning : AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
