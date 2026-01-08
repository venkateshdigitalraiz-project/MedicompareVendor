import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/earnings_chart.dart';
import '../widgets/earnings_stat_card.dart';
import '../widgets/order_earning_card.dart';
import '../widgets/payout_details_card.dart';

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        title: const Text('Earnings'),
        leading: const BackButton(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.88,
              children: const [
                EarningsStatCard(
                  title: 'Total Earnings',
                  amount: '₹24,560',
                  subtitle: 'Total medicine sales revenue',
                  color: Color(0xFFE6FAEC),
                  icon: Icons.currency_rupee_rounded,
                  iconColor: Color(0xFF2E7D32),
                ),
                EarningsStatCard(
                  title: "Today's Earnings",
                  amount: '₹2,150',
                  subtitle: 'Revenue from medicines today',
                  color: Color(0xFFE8F0FF),
                  icon: Icons.calendar_today_rounded,
                  iconColor: Color(0xFF3B5BDB),
                ),
                EarningsStatCard(
                  title: 'Pending Settlement',
                  amount: '₹3,800',
                  subtitle: 'Amount yet to be credited',
                  color: Color(0xFFFFF1E6),
                  icon: Icons.schedule_rounded,
                  iconColor: Color(0xFFD97706),
                ),
                EarningsStatCard(
                    title: 'Settled Amount',
                    amount: '₹20,760',
                    subtitle: 'Transferred to bank',
                    color: Color(0xFFF1EBFF),
                    icon: Icons.check_circle_rounded,
                    iconColor: AppColors.primary),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Earnings Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // filter action later
                  },
                  icon: const Icon(
                    Icons.tune,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const EarningsChart(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Earnings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                GestureDetector(
                  onTap: () {
                    context.push('/recent-earnings');
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const OrderEarningCard(
              orderId: '#ORD45891',
              dateTime: 'Today, 11:20 AM',
              medicines: '5 medicines sold',
              paymentMode: 'COD',
              orderValue: '₹890',
              earnings: '₹801',
              status: 'Pending',
            ),
            const OrderEarningCard(
              orderId: '#ORD45890',
              dateTime: 'Yesterday, 6:15 PM',
              medicines: '12 medicines sold',
              paymentMode: 'Online',
              orderValue: '₹2,340',
              earnings: '₹2,106',
              status: 'Completed',
            ),
            const SizedBox(height: 24),
            const PayoutDetailsCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
