import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/deliveryman_entity.dart';
import '../bloc/deliveryman_bloc.dart';
import '../bloc/deliveryman_event.dart';
import '../bloc/deliveryman_state.dart';
import '../widgets/deliveryman_stat_cards.dart';
import '../widgets/deliveryman_search_filter_bar.dart';
import '../widgets/deliveryman_card.dart';
import '../widgets/deliveryman_pagination_bar.dart';
import '../../deliveryman_injection.dart';

class DeliverymanPage extends StatelessWidget {
  const DeliverymanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliverymanInjection.provideDeliverymanBloc()
        ..add(const LoadDeliverymenEvent(page: 1, limit: 10)),
      child: const DeliverymanView(),
    );
  }
}

class DeliverymanView extends StatelessWidget {
  const DeliverymanView({super.key});

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
                Icons.local_shipping_outlined,
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
                    "Deliverymen",
                    style: GoogleFonts.inter(
                      color: const Color(0xFF1E1B4B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    "Manage your delivery personnel",
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final res = await context.push('/add-deliveryman');
                  if (res == true && context.mounted) {
                    context.read<DeliverymanBloc>().add(
                          const LoadDeliverymenEvent(
                              page: 1, limit: 10, isRefresh: true),
                        );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E1B4B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, size: 15),
                label: Text(
                  "Add Deliveryman",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFF1F5F9)),
        ),
      ),
      body: BlocConsumer<DeliverymanBloc, DeliverymanState>(
        listener: (context, state) {
          if (state is DeliverymanLoaded && state.actionMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionMessage!),
                backgroundColor: const Color(0xFF1E1B4B),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DeliverymanLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E1B4B)),
              ),
            );
          }

          if (state is DeliverymanError) {
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
                        context.read<DeliverymanBloc>().add(
                            const LoadDeliverymenEvent(page: 1, limit: 10));
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

          if (state is DeliverymanLoaded) {
            return RefreshIndicator(
              color: const Color(0xFF1E1B4B),
              onRefresh: () async {
                context.read<DeliverymanBloc>().add(LoadDeliverymenEvent(
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
                    DeliverymanStatCards(summary: state.summary),
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
                            child: DeliverymanSearchFilterBar(
                              initialSearch: state.searchQuery,
                              selectedStatus: state.statusFilter,
                              onSearchChanged: (query) {
                                context
                                    .read<DeliverymanBloc>()
                                    .add(SearchDeliverymenEvent(query));
                              },
                              onStatusFilterChanged: (status) {
                                context
                                    .read<DeliverymanBloc>()
                                    .add(FilterDeliverymenEvent(status));
                              },
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),

                          // Table Columns Header for Wide Screen
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isMobile = constraints.maxWidth < 750;
                              if (isMobile) return const SizedBox.shrink();

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                color: const Color(0xFFF8FAFC),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        "DELIVERYMAN",
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
                                        "CONTACT INFO",
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
                                        "TOTAL DELIVERIES",
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

                          // Deliveryman List / Empty State
                          if (state.items.isEmpty)
                            _buildEmptyState()
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.items.length,
                              itemBuilder: (context, index) {
                                final item = state.items[index];
                                return DeliverymanCard(
                                  item: item,
                                  onEdit: () =>
                                      _showEditPlaceholder(context, item),
                                  onDelete: () => _confirmDelete(context, item),
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
                                  .read<DeliverymanBloc>()
                                  .add(ChangeDeliverymenPageEvent(page));
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
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.people_outline,
              size: 30,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "No delivery personnel found",
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Try adjusting your search or filters",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, DeliverymanEntity item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          "Delete Deliveryman",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Text(
          "Are you sure you want to delete ${item.fullName}?",
          style:
              GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              "Cancel",
              style: GoogleFonts.inter(color: const Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context
                  .read<DeliverymanBloc>()
                  .add(DeleteDeliverymanEvent(item.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditPlaceholder(
      BuildContext context, DeliverymanEntity item) async {
    final res = await context.push('/edit-deliveryman/${item.id}');
    if (res == true && context.mounted) {
      context.read<DeliverymanBloc>().add(
            const LoadDeliverymenEvent(page: 1, limit: 10, isRefresh: true),
          );
    }
  }
}

