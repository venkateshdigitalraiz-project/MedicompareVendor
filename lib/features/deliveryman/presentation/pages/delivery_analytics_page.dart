import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/delivery_analytics_entity.dart';
import '../bloc/delivery_analytics_bloc.dart';
import '../bloc/delivery_analytics_event.dart';
import '../bloc/delivery_analytics_state.dart';
import '../../deliveryman_injection.dart';

class DeliveryAnalyticsPage extends StatelessWidget {
  const DeliveryAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliverymanInjection.provideDeliveryAnalyticsBloc()
        ..add(const LoadDeliveryAnalyticsEvent(range: '7days')),
      child: const DeliveryAnalyticsView(),
    );
  }
}

class DeliveryAnalyticsView extends StatelessWidget {
  const DeliveryAnalyticsView({super.key});

  static const Map<String, String> _rangeOptions = {
    '7days': 'Last 7 Days',
    'today': 'Today',
    '30days': 'Last 30 Days',
    'this_month': 'This Month',
    '90days': 'Last 90 Days',
    'all': 'All Time',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 64,
        titleSpacing: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E1B4B)),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: Color(0xFF6366F1),
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Delivery Analytics",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1E1B4B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "Track and analyze delivery performance",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          BlocBuilder<DeliveryAnalyticsBloc, DeliveryAnalyticsState>(
            builder: (context, state) {
              final currentRange = state is DeliveryAnalyticsLoaded
                  ? state.selectedRange
                  : (state is DeliveryAnalyticsLoading
                      ? state.selectedRange
                      : (state is DeliveryAnalyticsError
                          ? state.selectedRange
                          : '7days'));

              return Padding(
                padding: const EdgeInsets.only(right: 14.0),
                child: Center(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _rangeOptions.containsKey(currentRange)
                            ? currentRange
                            : '7days',
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E1B4B),
                        ),
                        onChanged: (newVal) {
                          if (newVal != null && newVal != currentRange) {
                            context
                                .read<DeliveryAnalyticsBloc>()
                                .add(ChangeDeliveryAnalyticsRangeEvent(newVal));
                          }
                        },
                        items: _rangeOptions.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(
                              entry.value,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1E1B4B),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
        ),
      ),
      body: BlocBuilder<DeliveryAnalyticsBloc, DeliveryAnalyticsState>(
        builder: (context, state) {
          if (state is DeliveryAnalyticsLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E1B4B)),
              ),
            );
          }

          if (state is DeliveryAnalyticsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.error_outline,
                          color: Color(0xFFEF4444), size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Failed to Load Analytics",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: const Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<DeliveryAnalyticsBloc>().add(
                              LoadDeliveryAnalyticsEvent(
                                  range: state.selectedRange),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1B4B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            );
          }

          final analytics = state is DeliveryAnalyticsLoaded
              ? state.analytics
              : const DeliveryAnalyticsEntity();
          final currentRange =
              state is DeliveryAnalyticsLoaded ? state.selectedRange : '7days';

          return RefreshIndicator(
            onRefresh: () async {
              context.read<DeliveryAnalyticsBloc>().add(
                    LoadDeliveryAnalyticsEvent(
                        range: currentRange, isRefresh: true),
                  );
            },
            color: const Color(0xFF1E1B4B),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 4 Stat Cards
                  _buildStatCards(analytics),
                  const SizedBox(height: 16),

                  // Lower Section: Order Status Distribution & Top Personnel
                  _buildLowerSection(analytics),
                  const SizedBox(height: 16),

                  // Delivery Partners Directory Card
                  _buildDeliveryPartnersDirectoryCard(context, analytics),
                ],
              ),
            ),
          );

        },
      ),
    );
  }

  Widget _buildStatCards(DeliveryAnalyticsEntity analytics) {
    final cards = [
      _buildStatCard(
        title: "Total Orders",
        value: "${analytics.totalOrders}",
        icon: Icons.inventory_2_outlined,
        iconColor: const Color(0xFF3B82F6),
        iconBgColor: const Color(0xFFEFF6FF),
      ),
      _buildStatCard(
        title: "Delivered",
        value: "${analytics.deliveredOrders}",
        subtitle: "↗ ${analytics.deliveredRate.toStringAsFixed(0)}% rate",
        subtitleColor: const Color(0xFF16A34A),
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF16A34A),
        iconBgColor: const Color(0xFFDCFCE7),
      ),
      _buildStatCard(
        title: "In Transit",
        value: "${analytics.inTransitOrders}",
        icon: Icons.access_time_rounded,
        iconColor: const Color(0xFFCA8A04),
        iconBgColor: const Color(0xFFFEF9C3),
      ),
      _buildStatCard(
        title: "Active Deliverymen",
        value: "${analytics.activeDeliverymen}",
        subtitle: "↗ of ${analytics.totalDeliverymen} total",
        subtitleColor: const Color(0xFF16A34A),
        icon: Icons.people_outline_rounded,
        iconColor: const Color(0xFF9333EA),
        iconBgColor: const Color(0xFFF3E8FF),
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 12),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 12),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    Color? subtitleColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E1B4B),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: subtitleColor ?? const Color(0xFF16A34A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowerSection(DeliveryAnalyticsEntity analytics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        final statusCard =
            _buildOrderStatusDistributionCard(analytics.statusDistribution);
        final topPersonnelCard =
            _buildTopDeliveryPersonnelCard(analytics.topDeliveryPersonnel);

        if (isMobile) {
          return Column(
            children: [
              statusCard,
              const SizedBox(height: 16),
              topPersonnelCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: statusCard),
            const SizedBox(width: 16),
            Expanded(child: topPersonnelCard),
          ],
        );
      },
    );
  }

  Widget _buildOrderStatusDistributionCard(
      OrderStatusDistributionEntity distribution) {
    final items = [
      {
        'label': 'Delivered',
        'percentage': distribution.deliveredPercentage,
        'color': const Color(0xFF16A34A),
      },
      {
        'label': 'In Transit',
        'percentage': distribution.inTransitPercentage,
        'color': const Color(0xFFCA8A04),
      },
      {
        'label': 'Assigned',
        'percentage': distribution.assignedPercentage,
        'color': const Color(0xFF3B82F6),
      },
      {
        'label': 'Cancelled',
        'percentage': distribution.cancelledPercentage,
        'color': const Color(0xFFEF4444),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Order Status Distribution",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Breakdown of order status",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart_outlined,
                  color: Color(0xFF9333EA),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...items.map((item) {
            final label = item['label'] as String;
            final perc = (item['percentage'] as num).toDouble();
            final color = item['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      Text(
                        "${perc.toStringAsFixed(0)}%",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E1B4B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      height: 6,
                      width: double.infinity,
                      color: const Color(0xFFF1F5F9),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (perc / 100).clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTopDeliveryPersonnelCard(
      List<TopDeliveryPersonnelEntity> personnelList) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Top Delivery Personnel",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E1B4B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Highest rated delivery partners",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: Color(0xFFCA8A04),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (personnelList.isEmpty)
            _buildPersonnelItem(
              rank: 1,
              name: "Mahesh",
              deliveries: 0,
              rating: "N/A",
            )
          else
            ...List.generate(personnelList.length, (index) {
              final p = personnelList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: _buildPersonnelItem(
                  rank: index + 1,
                  name: p.name,
                  deliveries: p.deliveries,
                  rating: p.rating,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPersonnelItem({
    required int rank,
    required String name,
    required int deliveries,
    required String rating,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE9FE),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              "#$rank",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6366F1),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                Text(
                  "$deliveries deliveries",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, size: 13, color: Color(0xFFCA8A04)),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF854D0E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryPartnersDirectoryCard(
    BuildContext context,
    DeliveryAnalyticsEntity analytics,
  ) {
    final list = analytics.topDeliveryPersonnel.isNotEmpty
        ? analytics.topDeliveryPersonnel
        : [
            const TopDeliveryPersonnelEntity(
              id: '1',
              name: 'Mahesh',
              phone: '9381559642',
              deliveries: 0,
              rating: 'N/A',
            )
          ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Delivery Partners Directory (${list.length})",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Performance stats for active personnel",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  await context.push('/deliveryman');
                  if (context.mounted) {
                    final state = context.read<DeliveryAnalyticsBloc>().state;
                    final range = state is DeliveryAnalyticsLoaded
                        ? state.selectedRange
                        : '7days';
                    context.read<DeliveryAnalyticsBloc>().add(
                          LoadDeliveryAnalyticsEvent(
                            range: range,
                            isRefresh: true,
                          ),
                        );
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Manage All",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_outward,
                        size: 14,
                        color: Color(0xFF6366F1),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Responsive Table with Horizontal Scroll
          LayoutBuilder(
            builder: (context, constraints) {
              const minTableWidth = 580.0;
              final tableWidth = constraints.maxWidth < minTableWidth
                  ? minTableWidth
                  : constraints.maxWidth;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      // Table Column Headers
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                "PARTNER NAME",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                "PHONE",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                "TOTAL DELIVERIES",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "RATING",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),

                      // Table Rows
                      ...list.map((partner) {
                        return InkWell(
                          onTap: () async {
                            await context.push('/deliveryman');
                            if (context.mounted) {
                              final state =
                                  context.read<DeliveryAnalyticsBloc>().state;
                              final range = state is DeliveryAnalyticsLoaded
                                  ? state.selectedRange
                                  : '7days';
                              context.read<DeliveryAnalyticsBloc>().add(
                                    LoadDeliveryAnalyticsEvent(
                                      range: range,
                                      isRefresh: true,
                                    ),
                                  );
                            }
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 12),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFFF8FAFC),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Partner Name + Avatar
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEDE9FE),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.people_outline_rounded,
                                          size: 16,
                                          color: Color(0xFF6366F1),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          partner.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFF1E1B4B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Phone
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    partner.phone.isNotEmpty
                                        ? partner.phone
                                        : "9381559642",
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),

                                // Total Deliveries
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.local_shipping_outlined,
                                        size: 15,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "${partner.deliveries}",
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1E1B4B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Rating
                                Expanded(
                                  flex: 2,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF9C3),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            size: 12,
                                            color: Color(0xFFCA8A04),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            partner.rating,
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF854D0E),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

