import 'package:MediCompare/features/home/presentation/widgets/overview_grid.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_text.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/recent_medicine_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String currentDate;

  final List<Map<String, String>> recentMedicines = const [
    {
      "name": "Paracetamol 500mg",
      "qty": "Pain Relief • 150 units",
      "status": "In Stock",
    },
    {
      "name": "Amoxicillin 250mg",
      "qty": "Antibiotics • 5 units",
      "status": "Low Stock",
    },
    {
      "name": "Ibuprofen 400mg",
      "qty": "Pain Relief • 89 units",
      "status": "In Stock",
    },
  ];

  @override
  void initState() {
    super.initState();
    currentDate =
        DateFormat('EEE, dd MMM yyyy • hh:mm a').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi, Arun",
                  style: AppText.title.copyWith(color: Colors.white)),
              Text(currentDate,
                  style: AppText.small.copyWith(color: Colors.white70)),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.support_agent), // or settings
                color: Colors.white,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),

                onPressed: () {
                  context.push('/support-ticket');
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications),
                color: Colors.white,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  context.push('/notification');
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Today's Overview", style: AppText.sectionTitle),
            const SizedBox(height: 12),
            const OverviewGrid(),
            const SizedBox(height: 20),
            Row(
              children: [
                Text("Recent Medicines", style: AppText.sectionTitle),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/medicines'),
                  child: const Text("View All"),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentMedicines.length,
              itemBuilder: (_, i) {
                final item = recentMedicines[i];
                return RecentMedicineTile(
                  name: item["name"]!,
                  quantity: item["qty"]!,
                  status: item["status"]!,
                );
              },
            ),
            const SizedBox(height: 20),
            Text("Quick Actions", style: AppText.sectionTitle),
            const SizedBox(height: 16),
            const QuickActionsGrid(),
          ],
        ),
      ),
    );
  }
}
