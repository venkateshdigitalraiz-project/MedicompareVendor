import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:MediCompare/features/subscription/presentation/bloc/subscription_event.dart';
import 'package:MediCompare/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/invoice_generator.dart';
import '../../../../core/utils/price_formatter.dart';

class LeadPlanHistoryPage extends StatelessWidget {
  const LeadPlanHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "Lead Plan History",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SubscriptionLoaded) {
            final currentPack = state.history.currentPack;
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<SubscriptionBloc>()
                    .add(LoadSubscriptionDataEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    if (currentPack != null) ...[
                      _buildActivePlanSection(currentPack),
                      const SizedBox(height: 32),
                    ],
                    _buildPreviousPlansHeader(),
                    const SizedBox(height: 16),
                    ...state.history.planHistory
                        .map((history) => _buildPreviousPlanCard(history))
                        .toList(),
                    if (state.history.planHistory.isEmpty) _buildEmptyHistory(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          } else if (state is SubscriptionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<SubscriptionBloc>()
                          .add(LoadSubscriptionDataEvent()),
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lead Plan Overview",
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Monitor your active subscription and usage metrics in real-time.",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlanSection(dynamic pack) {
    final int limit = pack.plan?.limit ?? 1;
    final int usage = pack.usage ?? 0;
    final double progress = limit > 0 ? (usage / limit).clamp(0.0, 1.0) : 0.0;
    final String startDate = DateFormat('dd MMM, yyyy').format(pack.createdAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${pack.plan?.name ?? 'Lead'} Plan",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    Text(
                      "Active since $startDate",
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              _statusBadge("Active"),
            ],
          ),
          const SizedBox(height: 28),
          _buildUsageBar(usage, limit, progress),
          const SizedBox(height: 28),
          const Divider(height: 1),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 2.8,
            children: [
              _infoTile("MONTHLY COST",
                  (pack.plan?.price as num? ?? 0).toRupeeFormat()),
              _infoTile("BILLING CYCLE", "Monthly"),
              _infoTile("AUTO RENEW", "Enabled"),
              _infoTile("PAYMENT", "Razorpay"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageBar(int usage, int limit, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Lead Quota Consumption",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
              ),
            ),
            Text(
              "$usage / $limit leads",
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 10,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 10,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(Icons.info_outline, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 6),
            Text(
              "${(progress * 100).toInt()}% of your monthly limit used",
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[400],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviousPlansHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Subscription History",
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          Text(
            "Access your past invoices and billing statements.",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviousPlanCard(dynamic item) {
    final date = DateFormat('dd MMM, yyyy').format(item.createdAt);
    final month = DateFormat('MMMM yyyy').format(item.createdAt);
    final String invNo = item.id.substring(item.id.length - 6).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.plan?.name ?? "Lead Plan",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Invoice #INV-$invNo",
                    style: GoogleFonts.inter(
                        fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              _statusBadge("Completed"),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _historyDetail("BILLING PERIOD", month),
              _historyDetail("AMOUNT PAID",
                  (item.plan?.price as num? ?? 0).toRupeeFormat()),
              _historyDetail("DATE", date),
            ],
          ),
          const SizedBox(height: 16),
          _buildUsedLeadsBar(item),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () =>
                  InvoiceGenerator.generateAndDownloadInvoice(item),
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: Text("Download Invoice",
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primary.withOpacity(0.05),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsedLeadsBar(dynamic item) {
    final int limit = item.plan?.limit ?? 0;
    final int usage = item.usage ?? 0;
    final double progress = limit > 0 ? (usage / limit).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Used Leads",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4B5563),
              ),
            ),
            Text(
              "$usage / $limit leads",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  height: 8,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _historyDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400]),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151)),
        ),
      ],
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toLowerCase(),
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF059669),
        ),
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.history_outlined, size: 48, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text(
              "No history available yet",
              style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
