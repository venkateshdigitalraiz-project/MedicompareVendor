import 'package:flutter/material.dart';
import '../widgets/payout_filter_tabs.dart';
import '../widgets/payout_history_card.dart';
import '../widgets/payout_section_header.dart';

class PayoutHistoryPage extends StatefulWidget {
  const PayoutHistoryPage({super.key});

  @override
  State<PayoutHistoryPage> createState() => _PayoutHistoryPageState();
}

class _PayoutHistoryPageState extends State<PayoutHistoryPage> {
  PayoutFilter _selectedFilter = PayoutFilter.all;

  final List<_PayoutItem> _allPayouts = const [
    _PayoutItem(
      id: '#PAY10234',
      status: PayoutStatus.completed,
      amount: '₹12,450',
      period: 'Jan 1–7, 2024',
      bank: 'HDFC Bank ****3456',
      cycle: 'T+2 Days',
      creditedOn: 'Jan 9, 2024 at 2:30 PM',
      month: 'this',
    ),
    _PayoutItem(
      id: '#PAY10233',
      status: PayoutStatus.pending,
      amount: '₹8,920',
      period: 'Jan 8–14, 2024',
      bank: 'HDFC Bank ****3456',
      cycle: 'T+2 Days',
      expectedOn: 'Jan 16, 2024',
      month: 'this',
    ),
    _PayoutItem(
      id: '#PAY10230',
      status: PayoutStatus.failed,
      amount: '₹11,290',
      period: 'Dec 11–17, 2023',
      bank: 'HDFC Bank ****3456',
      cycle: 'T+2 Days',
      expectedOn: 'Dec 19, 2023',
      month: 'this',
    ),
    _PayoutItem(
      id: '#PAY10232',
      status: PayoutStatus.completed,
      amount: '₹15,680',
      period: 'Dec 25–31, 2023',
      bank: 'HDFC Bank ****3456',
      cycle: 'T+2 Days',
      creditedOn: 'Jan 2, 2024 at 11:15 AM',
      month: 'last',
    ),
  ];

  List<_PayoutItem> get _filteredPayouts {
    if (_selectedFilter == PayoutFilter.all) {
      return _allPayouts;
    }
    return _allPayouts.where((p) {
      return p.status.name == _selectedFilter.name;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final thisMonth =
        _filteredPayouts.where((e) => e.month == 'this').toList();
    final lastMonth =
        _filteredPayouts.where((e) => e.month == 'last').toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7B4EE4),
        foregroundColor: Colors.white,
        title: const Text('Payout History'),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Heading + calendar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payout History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.calendar_today_outlined),
                ),
              ],
            ),

            const SizedBox(height: 4),
            const Text(
              'All settlements from medicine orders',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),

            const SizedBox(height: 16),

            /// FILTERS
            PayoutFilterTabs(
              selected: _selectedFilter,
              onChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),

            const SizedBox(height: 20),

            if (thisMonth.isNotEmpty) ...[
              const PayoutSectionHeader(
                title: 'This Month',
                amount: '₹45,280 total',
              ),
              const SizedBox(height: 12),
              ...thisMonth.map(_buildCard),
            ],

            if (lastMonth.isNotEmpty) ...[
              const SizedBox(height: 20),
              const PayoutSectionHeader(
                title: 'Last Month',
                amount: '₹38,940 total',
              ),
              const SizedBox(height: 12),
              ...lastMonth.map(_buildCard),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCard(_PayoutItem item) {
    return PayoutHistoryCard(
      payoutId: item.id,
      status: item.status,
      amount: item.amount,
      period: item.period,
      bank: item.bank,
      cycle: item.cycle,
      creditedOn: item.creditedOn,
      expectedOn: item.expectedOn,
    );
  }
}

/// INTERNAL MODEL (UI only)
class _PayoutItem {
  final String id;
  final PayoutStatus status;
  final String amount;
  final String period;
  final String bank;
  final String cycle;
  final String? creditedOn;
  final String? expectedOn;
  final String month;

  const _PayoutItem({
    required this.id,
    required this.status,
    required this.amount,
    required this.period,
    required this.bank,
    required this.cycle,
    this.creditedOn,
    this.expectedOn,
    required this.month,
  });
}
