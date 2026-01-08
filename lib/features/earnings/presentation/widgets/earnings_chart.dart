import 'package:flutter/material.dart';

class EarningsChart extends StatelessWidget {
  const EarningsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header: Title + Filter icon
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     const Text(
          //       'Earnings\nOverview',
          //       style: TextStyle(
          //         fontSize: 18,
          //         fontWeight: FontWeight.w700,
          //         height: 1.3,
          //       ),
          //     ),
          //     IconButton(
          //       onPressed: () {
          //         // filter action later
          //       },
          //       icon: const Icon(
          //         Icons.tune,
          //         color: Colors.black,
          //       ),
          //     ),
          //   ],
          // ),

          const SizedBox(height: 12),

          /// Chart Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/earnings_chart.png',
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
}
