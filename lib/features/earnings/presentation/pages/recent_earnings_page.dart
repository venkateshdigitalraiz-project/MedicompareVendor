import 'package:flutter/material.dart';

import '../widgets/order_earning_card.dart';

class RecentEarningsPage extends StatelessWidget {
  const RecentEarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B4EE4),
        foregroundColor: Colors.white,
        title: const Text('Recent Earnings'),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title + subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Recent Earnings',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Medicine orders',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
            
                /// Filter icon
                IconButton(
                  onPressed: () {
                    // filter action later
                  },
                  icon: const Icon(
                    Icons.tune,
                    size: 22,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OrderEarningCard(
              orderId: '#ORD45891',
              dateTime: 'Today, 11:20 AM',
              medicines: '5 medicines sold',
              paymentMode: 'COD',
              orderValue: '₹890',
              earnings: '₹801',
              status: 'Pending',
            ),
            OrderEarningCard(
              orderId: '#ORD45890',
              dateTime: 'Yesterday, 6:15 PM',
              medicines: '12 medicines sold',
              paymentMode: 'Online',
              orderValue: '₹2,340',
              earnings: '₹2,106',
              status: 'Completed',
            ),
            OrderEarningCard(
              orderId: '#ORD45891',
              dateTime: 'Today, 11:20 AM',
              medicines: '5 medicines sold',
              paymentMode: 'COD',
              orderValue: '₹890',
              earnings: '₹801',
              status: 'Pending',
            ),
            OrderEarningCard(
              orderId: '#ORD45890',
              dateTime: 'Yesterday, 6:15 PM',
              medicines: '12 medicines sold',
              paymentMode: 'Online',
              orderValue: '₹2,340',
              earnings: '₹2,106',
              status: 'Completed',
            ),
            OrderEarningCard(
              orderId: '#ORD45891',
              dateTime: 'Today, 11:20 AM',
              medicines: '5 medicines sold',
              paymentMode: 'COD',
              orderValue: '₹890',
              earnings: '₹801',
              status: 'Pending',
            ),
          ],
        ),
      ),
    );
  }
}
