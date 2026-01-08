import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'overview_card.dart';

class OverviewGrid extends StatelessWidget {
  const OverviewGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 165.5 / 118,
      ),
      children: const [
        OverviewCard(
          title: "Total Medicines",
          value: "1,247",
          change: "+12%",
          imagePath: "assets/Medicines.png",
          chipColor: AppColors.successBg ,
          chipTextColor: AppColors.success ,
        ),
        OverviewCard(
          title: "Earnings",
          value: "24",
          change: "+2",
          imagePath: "assets/Earnings.png",
          chipColor: AppColors.successBg ,
          chipTextColor: AppColors.success,
        ),
        OverviewCard(
          title: "Low Stock",
          value: "18",
          change: "+5",
          imagePath: "assets/stock.png",
          chipColor: AppColors.orangeBg,
          chipTextColor: AppColors.orange,
        ),
        OverviewCard(
          title: "Expiring Soon",
          value: "7",
          change: "+3",
          imagePath: "assets/Expiring.png",
          chipColor: AppColors.redBg,
          chipTextColor: AppColors.red,
        ),
      ],
    );
  }
}
