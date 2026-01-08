import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

enum PayoutStatus { completed, pending, failed }

class PayoutHistoryCard extends StatelessWidget {
  final String payoutId;
  final String amount;
  final String period;
  final String bank;
  final String cycle;
  final String? creditedOn;
  final String? expectedOn;
  final PayoutStatus status;

  const PayoutHistoryCard({
    super.key,
    required this.payoutId,
    required this.amount,
    required this.period,
    required this.bank,
    required this.cycle,
    required this.status,
    this.creditedOn,
    this.expectedOn,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = _statusStyle(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ID + Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                payoutId,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusData.bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusData.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusData.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            amount,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          _infoRow('Settlement Period', period),
          _infoRow('Bank Account', bank),
          _infoRow('Settlement Cycle', cycle),

          if (creditedOn != null) _infoRow('Credited On', creditedOn!),

          if (expectedOn != null)
            _infoRow(
              'Expected On',
              expectedOn!,
              valueColor: Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value,
      {Color valueColor = const Color(0xFF374151)}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.grey600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(PayoutStatus status) {
    switch (status) {
      case PayoutStatus.completed:
        return _StatusStyle(
          'Completed',
          const Color(0xFFDFF7E3),
          const Color(0xFF2E7D32),
        );
      case PayoutStatus.pending:
        return _StatusStyle(
          'Pending',
          const Color(0xFFFFEFD6),
          const Color(0xFFB45309),
        );
      case PayoutStatus.failed:
        return _StatusStyle(
          'Failed',
          const Color(0xFFFDE2E2),
          const Color(0xFFB91C1C),
        );
    }
  }
}

class _StatusStyle {
  final String label;
  final Color bg;
  final Color text;

  _StatusStyle(this.label, this.bg, this.text);
}
