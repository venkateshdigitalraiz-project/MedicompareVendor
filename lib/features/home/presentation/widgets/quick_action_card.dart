import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_QuickActionItem> actions = [
      _QuickActionItem(
        title: "Add Medicine",
        subtitle: "Add new inventory medicines",
        icon: "assets/inventory.png",
        route: "/add-medicine",
      ),
      _QuickActionItem(
        title: "Bulk Upload",
        subtitle: "Upload multiple medicines",
        icon: "assets/bulk upload.png",
        route: "/bulk-upload",
      ),
      _QuickActionItem(
        title: "Low Stock",
        subtitle: "View low stock items",
        icon: "assets/low stock.png",
        route: "/low-stock",
      ),
      _QuickActionItem(
        title: "Reports",
        subtitle: "Generate inventory reports",
        icon: "assets/report.png",
        route: "/reports",
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 13.5,
        mainAxisSpacing: 13.5,
        childAspectRatio: 164 / 108,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final item = actions[index];

        return Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => context.push(item.route),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.greyBackground,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),

                  /// ICON
                  Image.asset(
                    item.icon,
                    height: 22,
                    width: 22,
                  ),

                  const SizedBox(height: 6),

                  /// TITLE + ARROW
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.section,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 22,
                        color: AppColors.black,
                      ),
                    ],
                  ),

                  /// SUBTITLE
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.small,
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// MODEL (PRIVATE)
class _QuickActionItem {
  final String title;
  final String subtitle;
  final String icon;
  final String route;

  const _QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}
