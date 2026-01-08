import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class PayoutSectionHeader extends StatelessWidget {
  final String title;
  final String amount;

  const PayoutSectionHeader({
    super.key,
    required this.title,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          amount,
          style: const TextStyle(fontSize: 13, color: AppColors.grey600),
        ),
      ],
    );
  }
}
