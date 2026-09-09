import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../bloc/delivery_orders_bloc.dart';
import '../bloc/delivery_orders_event.dart';
import '../bloc/delivery_orders_state.dart';
import '../widgets/delivery_orders_stat_cards.dart';
import '../widgets/delivery_orders_search_filter_bar.dart';
import '../widgets/delivery_order_card.dart';
import '../widgets/deliveryman_pagination_bar.dart';
import '../../deliveryman_injection.dart';

class DeliveryOrdersPage extends StatelessWidget {
  const DeliveryOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliverymanInjection.provideDeliveryOrdersBloc()
        ..add(const LoadDeliveryOrdersEvent(page: 1, limit: 10)),
      child: const DeliveryOrdersView(),
    );
  }
}

class DeliveryOrdersView extends StatelessWidget {
  const DeliveryOrdersView({super.key});

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
                Icons.shopping_cart_outlined,
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
                    "Delivery Orders",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1E1B4B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "Manage and track all delivery orders",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
        ),
      ),
      body: BlocBuilder<DeliveryOrdersBloc, DeliveryOrdersState>(
        builder: (context, state) {
          if (state is DeliveryOrdersLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E1B4B)),
              ),
            );
          }

          if (state is DeliveryOrdersError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Something went wrong",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<DeliveryOrdersBloc>().add(
                            const LoadDeliveryOrdersEvent(page: 1, limit: 10));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1B4B),
                        foregroundColor: Colors.white,
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

          if (state is DeliveryOrdersLoaded) {
            return RefreshIndicator(
              color: const Color(0xFF1E1B4B),
              onRefresh: () async {
                context.read<DeliveryOrdersBloc>().add(LoadDeliveryOrdersEvent(
                      page: state.pagination.page,
                      limit: state.pagination.limit,
                      search: state.searchQuery,
                      status: state.statusFilter,
                      isRefresh: true,
                    ));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stat summary cards
                    DeliveryOrdersStatCards(summary: state.summary),
                    const SizedBox(height: 16),

                    // Main List Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Search and Filter Bar
                          Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: DeliveryOrdersSearchFilterBar(
                              initialSearch: state.searchQuery,
                              selectedStatus: state.statusFilter,
                              onSearchChanged: (query) {
                                context
                                    .read<DeliveryOrdersBloc>()
                                    .add(SearchDeliveryOrdersEvent(query));
                              },
                              onStatusFilterChanged: (status) {
                                context
                                    .read<DeliveryOrdersBloc>()
                                    .add(FilterDeliveryOrdersEvent(status));
                              },
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),

                          // Table Columns Header for Wide Screen
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 850;
                              if (isMobile) return const SizedBox.shrink();

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                color: const Color(0xFFF8FAFC),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "ORDER ITEM ID",
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
                                        "CUSTOMER",
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
                                        "DELIVERY ADDRESS",
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
                                        "ASSIGNED PERSONNEL",
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
                                        "STATUS",
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
                                        "ORDER DATE",
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF64748B),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "ACTIONS",
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF64748B),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Delivery Orders List / Empty State
                          if (state.items.isEmpty)
                            _buildEmptyState()
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.items.length,
                              itemBuilder: (context, index) {
                                final item = state.items[index];
                                return DeliveryOrderCard(
                                  item: item,
                                  onTap: () {
                                    if (item.orderId.isNotEmpty) {
                                      context.push('/order-details/${item.orderId}');
                                    }
                                  },
                                );
                              },
                            ),

                          // Pagination Bar Footer
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          DeliverymanPaginationBar(
                            page: state.pagination.page,
                            totalPages: state.pagination.totalPages,
                            total: state.pagination.total,
                            limit: state.pagination.limit,
                            itemCount: state.items.length,
                            onPageChanged: (page) {
                              context
                                  .read<DeliveryOrdersBloc>()
                                  .add(ChangeDeliveryOrdersPageEvent(page));
                            },
                          ),
                        ],
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
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 54, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(27),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 26,
              color: Color(0xFF818CF8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No delivery orders found",
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Orders assigned for delivery will appear here.",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
