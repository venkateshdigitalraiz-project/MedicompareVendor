import 'package:MediCompare/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/token_storage.dart';

import '../../../../core/constants/app_colors.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardError && state.message == 'UNAUTHORIZED_ACCESS_401') {
          debugPrint('Dashboard: Unauthorized access detected. Redirecting to login...');
          // Clear token and navigate to login
          TokenStorage.clearAll().then((_) {
            if (context.mounted) {
              context.go('/login');
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FF),
        body: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DashboardLoaded) {
              return _buildDashboardContent(context, state.dashboard);
            } else if (state is DashboardError) {
              final isAuthError = state.message == 'UNAUTHORIZED_ACCESS_401';
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        isAuthError ? "Session Expired or Invalid Token" : "Request Error",
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAuthError ? "Please login again to refresh your session." : state.message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            if (isAuthError) {
                              context.go('/login');
                            } else {
                              context.read<DashboardBloc>().add(GetDashboardEvent());
                            }
                          },
                          child: Text(
                            isAuthError ? "Go to Login" : "Retry",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(
      BuildContext context, DashboardEntity dashboard) {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, d MMMM y hh:mm:ss a');
    final dateStr = '${formatter.format(now)} IST';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dateStr,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),

                const Stack(
                  children: [
                    Icon(Icons.notifications_none_outlined,
                        size: 24, color: Colors.grey),
                    // Positioned(
                    //   right: 0,
                    //   top: 0,
                    //   child:
                    //       CircleAvatar(radius: 4, backgroundColor: Colors.red),
                    // ),
                  ],
                ),
                // const SizedBox(width: 12),
                // Row(
                //   children: [
                //     CircleAvatar(
                //       radius: 16,
                //       backgroundImage: dashboard.user.profileImageUrl != null
                //           ? NetworkImage(dashboard.user.profileImageUrl!)
                //           : const AssetImage('assets/profile.png')
                //               as ImageProvider,
                //     ),
                //     const SizedBox(width: 8),
                //     Text(
                //       dashboard.user.firstName,
                //       style: GoogleFonts.inter(
                //         fontSize: 14,
                //         fontWeight: FontWeight.w600,
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
            const SizedBox(height: 24),

            // Text(
            //   "Dashboard",
            //   style: GoogleFonts.inter(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black,
            //   ),
            // ),
            // Text(
            //   "Welcome back! Here's what's happening with your inventory.",
            //   style: GoogleFonts.inter(
            //     fontSize: 14,
            //     color: Colors.grey[600],
            //   ),
            // ),
            // const SizedBox(height: 24),

            /// TOTAL STATS
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildStatCard(
                  "Total Balance",
                  "₹${dashboard.revenue.totalAmount.toStringAsFixed(2)}",
                  Icons.attach_money,
                  Colors.blue,
                ),
                _buildStatCard(
                  "Total Orders",
                  dashboard.orderCount.totalOrder.toString(),
                  Icons.shopping_cart_outlined,
                  Colors.green,
                ),
                _buildStatCard(
                  "Total Leads",
                  dashboard.leads.totalLeads.toString(),
                  Icons.group_outlined,
                  Colors.purple,
                ),
                _buildStatCard(
                  "Total Rated",
                  dashboard.rating.totalRating.toString(),
                  Icons.star_outline,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 32),

            /// MONTH WISE COMPARISON
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Month Wise Comparison",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildComparisonCard(
                    "This Month Orders",
                    dashboard.orderCount.currentMonthOrders.toString(),
                    dashboard.orderCount.orderPercentageChange,
                    dashboard.orderCount.orderStatus,
                    Icons.shopping_cart_outlined,
                    Colors.green,
                  ),
                  _buildComparisonCard(
                    "This Month Revenue",
                    "₹${dashboard.revenue.currentMonthAmount.toStringAsFixed(2)}",
                    dashboard.revenue.amountPercentageChange,
                    dashboard.revenue.amountStatus,
                    Icons.attach_money,
                    Colors.blue,
                  ),
                  _buildComparisonCard(
                    "This Month Leads",
                    dashboard.leads.currentMonthLeads.toString(),
                    dashboard.leads.leadPercentageChange,
                    dashboard.leads.leadStatus,
                    Icons.group_outlined,
                    Colors.purple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            /// TOP SELLING & RECENT LEADS
            LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    _buildSectionHeader("Top Selling Orders", () {}),
                    const SizedBox(height: 12),
                    ...dashboard.topProducts
                        .take(5)
                        .map((product) => _buildTopProductItem(product)),
                    const SizedBox(height: 32),
                    _buildSectionHeader("Recent Leads", () {}),
                    const SizedBox(height: 12),
                    ...dashboard.recentLeads
                        .take(5)
                        .map((lead) => _buildRecentLeadItem(lead)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
    String title,
    String value,
    double percentage,
    String status,
    IconData icon,
    Color color,
  ) {
    final isIncrease = status == 'increase';
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                "${isIncrease ? '+' : ''}$percentage%",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: isIncrease ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "from last month",
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              title.contains("Selling")
                  ? Icons.inventory_2_outlined
                  : Icons.group_outlined,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: onViewAll,
          child: Row(
            children: [
              Text(
                "View All",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(Icons.chevron_right,
                  size: 16, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductItem(TopProductEntity product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_cart_outlined,
                color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Text(
                  product.category,
                  style:
                      GoogleFonts.inter(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                product.orderCount.toString(),
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "orders",
                style: GoogleFonts.inter(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLeadItem(RecentLeadEntity lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.group_outlined,
                color: Colors.purple, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.serviceName,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      lead.name,
                      style: GoogleFonts.inter(
                          color: Colors.grey[500], fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(lead.createdAt),
                      style: GoogleFonts.inter(
                          color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "New",
              style: GoogleFonts.inter(
                color: Colors.blue,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return "${diff.inDays} days ago";
    if (diff.inHours > 0) return "${diff.inHours} hrs ago";
    if (diff.inMinutes > 0) return "${diff.inMinutes} mins ago";
    return "just now";
  }
}
