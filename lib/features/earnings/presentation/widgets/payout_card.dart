// import 'package:flutter/material.dart';

// class PayoutCard extends StatelessWidget {
//   final String amount;
//   final String status;
//   final String bank;

//   const PayoutCard({
//     super.key,
//     required this.amount,
//     required this.status,
//     required this.bank,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isCompleted = status == 'Completed';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             amount,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
//           ),
//           const SizedBox(height: 8),
//           Text(bank, style: const TextStyle(color: Colors.grey)),
//           const SizedBox(height: 10),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: isCompleted
//                   ? const Color(0xFFE6F8EC)
//                   : const Color(0xFFFFEFE5),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               status,
//               style: TextStyle(
//                 fontSize: 12,
//                 color:
//                     isCompleted ? const Color(0xFF2E7D32) : Colors.orange,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
