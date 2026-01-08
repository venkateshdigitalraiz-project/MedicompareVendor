import 'package:flutter/material.dart';

class OrderEarningCard extends StatelessWidget {
  final String orderId;
  final String dateTime;
  final String medicines;
  final String paymentMode; // Online / COD
  final String orderValue;
  final String earnings;
  final String status; // Completed / Pending

  const OrderEarningCard({
    super.key,
    required this.orderId,
    required this.dateTime,
    required this.medicines,
    required this.paymentMode,
    required this.orderValue,
    required this.earnings,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = status == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Order ID + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderId,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFDFF7E3)
                      : const Color(0xFFFFEFD6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// Date & Time
          Text(
            dateTime,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 14),

          /// Medicines + Payment Mode
          Row(
            children: [
              const Icon(
                Icons.medication_outlined,
                size: 18,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 6),
              Text(
                medicines,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF374151),
                ),
              ),
              const Spacer(),
              Text(
                paymentMode,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// Divider
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          const SizedBox(height: 14),

          /// Order Value + Earnings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                  children: [
                    const TextSpan(text: 'Order Value: '),
                    TextSpan(
                      text: orderValue,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Your Earnings $earnings',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF7B4EE4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
