import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text.dart';

class OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final String imagePath;
  final Color chipColor;
  final Color chipTextColor;

  const OverviewCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.imagePath,
    required this.chipColor,
    required this.chipTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),

          /// IMAGE + CHANGE CHIP
          Row(
            children: [
              Image.asset(
                imagePath,
                height: 24,
                width: 24,
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  change,
                  style: AppText.small.copyWith(color: chipTextColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// VALUE
          Text(
            value,
            style: AppText.largeTitle,
          ),

          /// TITLE
          Text(
            title,
            style: AppText.small.copyWith(color: AppColors.black),
          ),
        ],
      ),
    );
  }
}
