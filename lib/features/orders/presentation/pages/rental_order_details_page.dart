import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../domain/entities/order_details_response_entity.dart';
import '../bloc/order_details_bloc.dart';
import '../bloc/order_details_event.dart';
import '../bloc/order_details_state.dart';

class RentalOrderDetailsPage extends StatefulWidget {
  final String orderId;

  const RentalOrderDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  State<RentalOrderDetailsPage> createState() => _RentalOrderDetailsPageState();
}

class _RentalOrderDetailsPageState extends State<RentalOrderDetailsPage> {
  final String _selectedDeliveryPartner = 'medicompares';
  final int _selectedParcelTime = 30;

  int _selectedDeliveryTab = 0; // 0: Medicompares, 1: Our Deliveryman
  String? _selectedDeliveryPartnerId;
  String _selectedReadyTime = '30 min';
  final List<String> _readyTimeOptions = [
    '15 min',
    '30 min',
    '45 min',
    '60 min',
    '90 min',
  ];
  final TextEditingController _partnerSearchController =
      TextEditingController();
  final ScrollController _partnerScrollController = ScrollController();

  bool _isPendingStatus(String status) {
    final s = status.trim().toLowerCase();
    return s == 'pending' || s == 'new' || s.isEmpty;
  }

  bool _isConfirmedStatus(String status) {
    final s = status.trim().toLowerCase().replaceAll(' ', '_');
    return s == 'confirmed' ||
        s == 'order_confirmed' ||
        s == 'accepted' ||
        s == 'order_accepted' ||
        s == 'processing';
  }

  bool _isAssignedStatus(String status) {
    final s = status.trim().toLowerCase().replaceAll(' ', '_');
    return s == 'assigned' ||
        s == 'assigned_deliveryman' ||
        s == 'assigned_delivery_partner' ||
        s == 'assigned_technician' ||
        s == 'shipped' ||
        s == 'out_for_delivery';
  }

  @override
  void initState() {
    super.initState();
    _partnerScrollController.addListener(_onPartnerScroll);
    context
        .read<OrderDetailsBloc>()
        .add(GetOrderDetailsEvent(widget.orderId, orderType: 'rental'));
  }

  void _onPartnerScroll() {
    if (!_partnerScrollController.hasClients) return;
    final state = context.read<OrderDetailsBloc>().state;
    if (state is! OrderDetailsLoaded) return;

    if (state.deliveryPartners.length >= 10 &&
        state.hasMorePartners &&
        !state.isLoadingMorePartners &&
        !state.isLoadingPartners) {
      if (_partnerScrollController.position.pixels >=
          _partnerScrollController.position.maxScrollExtent - 40) {
        final nextPage = state.partnersPage + 1;
        context.read<OrderDetailsBloc>().add(
              GetOrderDeliveryPartnersEvent(
                search: _partnerSearchController.text.trim(),
                page: nextPage,
                isLoadMore: true,
              ),
            );
      }
    }
  }

  @override
  void dispose() {
    _partnerScrollController.removeListener(_onPartnerScroll);
    _partnerScrollController.dispose();
    _partnerSearchController.dispose();
    super.dispose();
  }

  void _handleUpdateStatus(String status, {String? rejectionReason}) {
    final state = context.read<OrderDetailsBloc>().state;
    if (state is OrderDetailsLoaded) {
      final orderDetails = state.orderDetails;
      final effectiveItemId =
          orderDetails.id.isNotEmpty ? orderDetails.id : widget.orderId;
      final effectiveOrderId = orderDetails.orderId.isNotEmpty
          ? orderDetails.orderId
          : effectiveItemId;

      final payload = {
        "deliveryManType": "admin",
        "deliveryPartner": _selectedDeliveryPartner,
        "deliveryPartnerId": null,
        "orderId": effectiveOrderId,
        "orderStatus": status,
        "packageIds": [],
        "productIds": [],
        "readyTime": _selectedParcelTime.toString(),
        "rejectionReason": rejectionReason,
        "status": status,
      };

      context.read<OrderDetailsBloc>().add(UpdateOrderStatusEvent(
            orderItemId: effectiveItemId,
            payload: payload,
          ));
    }
  }

  void _showCancelOrderDialog() {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Cancel Order",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please provide a reason for cancelling this rental order.",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter cancellation reason...",
                hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "Close",
              style: GoogleFonts.inter(
                  color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a cancellation reason"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              _handleUpdateStatus('cancelled', rejectionReason: reason);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              "Cancel Order",
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAppBarButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          minimumSize: const Size(0, 30),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarActions() {
    return BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
      builder: (context, state) {
        if (state is OrderActionLoading) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }

        if (state is! OrderDetailsLoaded) {
          return const SizedBox.shrink();
        }

        final details = state.orderDetails;
        final orderStatus = details.orderStatus.trim().toLowerCase();
        final isPending = _isPendingStatus(orderStatus);

        if (!isPending) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCompactAppBarButton(
              label: "Cancel Order",
              color: const Color(0xFFDC2626),
              onTap: () => _showCancelOrderDialog(),
            ),
            const SizedBox(width: 6),
            _buildCompactAppBarButton(
              label: "Accept Order",
              color: AppColors.primary,
              onTap: () => _handleUpdateStatus('confirmed'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 36,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Rental Order Details",
              style: GoogleFonts.inter(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              "ID: ${widget.orderId.length > 12 ? '${widget.orderId.substring(0, 12)}...' : widget.orderId}",
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          _buildAppBarActions(),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<OrderDetailsBloc, OrderDetailsState>(
        listener: (context, state) {
          if (state is OrderDetailsLoaded) {
            final orderDetails = state.orderDetails;
            if (_isConfirmedStatus(orderDetails.orderStatus) &&
                !state.hasLoadedPartners &&
                !state.isLoadingPartners) {
              context.read<OrderDetailsBloc>().add(
                    const GetOrderDeliveryPartnersEvent(
                      search: '',
                      forceRefresh: true,
                    ),
                  );
            }
          } else if (state is OrderStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
            context
                .read<OrderDetailsBloc>()
                .add(GetOrderDetailsEvent(widget.orderId, orderType: 'rental'));
          } else if (state is OrderDetailsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is OrderDetailsLoading || state is OrderActionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrderDetailsLoaded) {
            final orderDetails = state.orderDetails;

            return LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;
              final deliverySection =
                  _buildDeliverySection(state, orderDetails);
              final hasDeliverySection = deliverySection is! SizedBox;

              final leftColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildRentalOrderItemsSection(orderDetails),
                  const SizedBox(height: 16),
                  _buildOrderSummarySection(orderDetails),
                ],
              );

              final rightColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCustomerInformationSection(orderDetails),
                  if (orderDetails.installmentList.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildInstallmentListSection(orderDetails),
                  ],
                  const SizedBox(height: 16),
                  _buildShippingAddressSection(),
                  const SizedBox(height: 16),
                  _buildBillingAddressSection(),
                ],
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// 🌟 DELIVERY SECTION (ON TOP)
                    if (hasDeliverySection) ...[
                      deliverySection,
                      const SizedBox(height: 16),
                    ],

                    /// 🌟 TOP SECTION (STAT CARDS)
                    _buildTopHeaderCard(orderDetails),
                    const SizedBox(height: 16),

                    /// MAIN CONTENT (RESPONSIVE GRID / COLUMN)
                    isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 3, child: leftColumn),
                              const SizedBox(width: 16),
                              Expanded(flex: 2, child: rightColumn),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              leftColumn,
                              const SizedBox(height: 16),
                              rightColumn,
                            ],
                          ),
                  ],
                ),
              );
            });
          } else if (state is OrderDetailsError) {
            return Center(
                child:
                    Text(state.message, style: const TextStyle(fontSize: 12)));
          }
          return const Center(child: Text("Preparing details..."));
        },
      ),
    );
  }

  /// ================= 🌟 TOP HEADER CARD =================
  Widget _buildTopHeaderCard(OrderDetailsResponseEntity orderDetails) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: _buildThreeStatCards(orderDetails),
    );
  }

  /// ================= 3 STAT CARDS =================
  Widget _buildThreeStatCards(OrderDetailsResponseEntity orderDetails) {
    final statusLower = orderDetails.orderStatus.trim().toLowerCase();
    final paymentStatusLower = orderDetails.paymentStatus.trim().toLowerCase();

    final IconData statusIcon;
    final Color statusIconColor;

    switch (statusLower) {
      case 'pending':
      case 'new':
        statusIcon = Icons.schedule_outlined;
        statusIconColor = const Color(0xFFD97706);
        break;
      case 'confirmed':
        statusIcon = Icons.check_circle_outline;
        statusIconColor = const Color(0xFF0284C7);
        break;
      case 'assigned':
      case 'shipped':
      case 'out_for_delivery':
        statusIcon = Icons.local_shipping_outlined;
        statusIconColor = const Color(0xFF059669);
        break;
      case 'delivered':
      case 'completed':
        statusIcon = Icons.check_circle_outline;
        statusIconColor = const Color(0xFF16A34A);
        break;
      case 'failed':
      case 'cancelled':
      case 'rejected':
      default:
        statusIcon = Icons.error_outline;
        statusIconColor = (statusLower == 'failed' ||
                statusLower == 'cancelled' ||
                statusLower == 'rejected')
            ? const Color(0xFFDC2626)
            : const Color(0xFF64748B);
        break;
    }

    final isPaymentFailed =
        paymentStatusLower == 'failed' || paymentStatusLower == 'cancelled';
    final isPaymentPaid = paymentStatusLower == 'paid' ||
        paymentStatusLower == 'completed' ||
        paymentStatusLower == 'success';

    final orderStatusText = orderDetails.orderStatus.isNotEmpty
        ? orderDetails.orderStatus[0].toUpperCase() +
            orderDetails.orderStatus.substring(1).toLowerCase()
        : 'Pending';

    final formattedDate = DateFormat('d MMM yyyy, hh:mm a')
        .format(orderDetails.createdAt.toLocal());

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 600;

      final card1 = _buildStatCardItem(
        icon: Icons.shopping_cart_outlined,
        iconColor: Colors.grey.shade600,
        label: "ORDER STATUS",
        valueWidget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              statusIcon,
              size: 16,
              color: statusIconColor,
            ),
            const SizedBox(width: 6),
            Text(
              orderStatusText,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      );

      final card2 = _buildStatCardItem(
        icon: Icons.credit_card_outlined,
        iconColor: const Color(0xFF059669),
        label: "PAYMENT STATUS",
        valueWidget: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: isPaymentFailed
                ? const Color(0xFFFEE2E2)
                : (isPaymentPaid
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFFEF3C7)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            paymentStatusLower.isNotEmpty ? paymentStatusLower : 'pending',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPaymentFailed
                  ? const Color(0xFFEF4444)
                  : (isPaymentPaid
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFD97706)),
            ),
          ),
        ),
      );

      final card3 = _buildStatCardItem(
        icon: Icons.calendar_today_outlined,
        iconColor: const Color(0xFF2563EB),
        label: "ORDER DATE",
        valueWidget: Text(
          formattedDate,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
      );

      if (isNarrow) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: card1),
                const SizedBox(width: 8),
                Expanded(child: card2),
              ],
            ),
            const SizedBox(height: 8),
            card3,
          ],
        );
      }

      return Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 12),
          Expanded(child: card2),
          const SizedBox(width: 12),
          Expanded(child: card3),
        ],
      );
    });
  }

  Widget _buildStatCardItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Widget valueWidget,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          valueWidget,
        ],
      ),
    );
  }

  /// ================= DELIVERY SECTION =================
  Widget _buildDeliverySection(
      OrderDetailsState state, OrderDetailsResponseEntity order) {
    final status = order.orderStatus.trim().toLowerCase();
    if (_isConfirmedStatus(status)) {
      return _buildDeliveryAssignmentSection(state, order);
    }

    if (_isAssignedStatus(status) || order.deliveries.isNotEmpty) {
      return _buildAssignedDeliveryPartnerSection(
        order.deliveries.isNotEmpty ? order.deliveries.first : null,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDeliveryAssignmentSection(
      OrderDetailsState state, OrderDetailsResponseEntity order) {
    final loadedState = state is OrderDetailsLoaded ? state : null;
    final partners = loadedState?.deliveryPartners ?? [];
    final ownPartner = loadedState?.ownDeliveryPartner;
    final isLoadingPartners = loadedState?.isLoadingPartners ?? false;
    final isLoadingMorePartners = loadedState?.isLoadingMorePartners ?? false;
    final partnersError = loadedState?.partnersError;
    final isAssigning = loadedState?.isAssigningPartner ?? false;

    if (_selectedDeliveryPartnerId == null && partners.isNotEmpty) {
      _selectedDeliveryPartnerId = partners.first.id;
    }

    return _buildCard(
      title: "Delivery Assignment",
      icon: Icons.local_shipping_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Segmented Tabs: Medicompares vs Our Deliveryman
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDeliveryTab = 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedDeliveryTab == 0
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: _selectedDeliveryTab == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Medicompares",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: _selectedDeliveryTab == 0
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _selectedDeliveryTab == 0
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDeliveryTab = 1;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedDeliveryTab == 1
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: _selectedDeliveryTab == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                )
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Our Deliveryman",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: _selectedDeliveryTab == 1
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: _selectedDeliveryTab == 1
                              ? const Color(0xFF1E293B)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab content
          if (_selectedDeliveryTab == 0) ...[
            // Search Input
            Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _partnerSearchController,
                decoration: InputDecoration(
                  hintText: "Search Medicompares partner...",
                  hintStyle: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF94A3B8),
                  ),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  suffixIcon: _partnerSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              size: 16, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            _partnerSearchController.clear();
                            context.read<OrderDetailsBloc>().add(
                                  const GetOrderDeliveryPartnersEvent(
                                      search: '', forceRefresh: true),
                                );
                          },
                        )
                      : null,
                ),
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF1E293B)),
                onSubmitted: (value) {
                  context.read<OrderDetailsBloc>().add(
                        GetOrderDeliveryPartnersEvent(
                            search: value.trim(), forceRefresh: true),
                      );
                },
                onChanged: (value) {
                  if (value.isEmpty) {
                    context.read<OrderDetailsBloc>().add(
                          const GetOrderDeliveryPartnersEvent(
                              search: '', forceRefresh: true),
                        );
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // Delivery Partner List
            if (isLoadingPartners && partners.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (partnersError != null && partners.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        partnersError,
                        style: GoogleFonts.inter(
                            fontSize: 12, color: Colors.red.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          context.read<OrderDetailsBloc>().add(
                                const GetOrderDeliveryPartnersEvent(
                                    forceRefresh: true),
                              );
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              )
            else if (partners.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text(
                    "No active delivery partners found",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 280),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Scrollbar(
                  controller: _partnerScrollController,
                  thumbVisibility: partners.length > 3,
                  child: ListView.separated(
                    controller: _partnerScrollController,
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount:
                        partners.length + (isLoadingMorePartners ? 1 : 0),
                    separatorBuilder: (_, __) =>
                        Divider(color: Colors.grey.shade100, height: 1),
                    itemBuilder: (context, index) {
                      if (index == partners.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        );
                      }
                      final partner = partners[index];
                      final isSelected =
                          _selectedDeliveryPartnerId == partner.id;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDeliveryPartnerId = partner.id;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.06)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(
                                    color: AppColors.primary.withOpacity(0.4),
                                    width: 1)
                                : Border.all(
                                    color: Colors.transparent, width: 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      partner.name,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    if (partner.phone.isNotEmpty)
                                      Text(
                                        partner.phone,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "ID: ${partner.partnerId}",
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star,
                                      size: 15, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    partner.rating > 0
                                        ? partner.rating.toStringAsFixed(1)
                                        : '4.5',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Ready In Dropdown
            Row(
              children: [
                Text(
                  "Ready in: ",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedReadyTime,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          size: 18, color: Color(0xFF64748B)),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                      items: _readyTimeOptions.map((opt) {
                        return DropdownMenuItem<String>(
                          value: opt,
                          child: Text(opt),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedReadyTime = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Assign Medicompares Partner Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isAssigning
                    ? null
                    : () {
                        if (_selectedDeliveryPartnerId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  "Please select a delivery partner to assign"),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }
                        final readyMinutes =
                            _selectedReadyTime.replaceAll(' min', '');
                        final effectiveId = order.id.isNotEmpty
                            ? order.id
                            : widget.orderId;
                        context.read<OrderDetailsBloc>().add(
                              AssignOrderDeliveryPartnerEvent(
                                orderId: effectiveId,
                                deliveryPartnerId: _selectedDeliveryPartnerId!,
                                deliveryManType: 'admin',
                                deliveryPartner: 'medicompares',
                                readyTime: readyMinutes,
                              ),
                            );
                      },
                child: isAssigning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Assign Medicompares Partner",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            // Assign Own Deliveryman Button (Visible in Medicompares tab)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isAssigning
                    ? null
                    : () {
                        final readyMinutes =
                            _selectedReadyTime.replaceAll(' min', '');
                        final effectiveId = order.id.isNotEmpty
                            ? order.id
                            : widget.orderId;
                        context.read<OrderDetailsBloc>().add(
                              AssignOrderDeliveryPartnerEvent(
                                orderId: effectiveId,
                                deliveryPartnerId: ownPartner?.id ?? '',
                                deliveryManType: 'vendor',
                                deliveryPartner: 'vendor',
                                readyTime: readyMinutes,
                              ),
                            );
                      },
                child: isAssigning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Assign Own Deliveryman",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
          ] else ...[
            // Own Deliveryman tab
            if (isLoadingPartners && ownPartner == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (ownPartner != null)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8F0),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: ownPartner.profileImage != null &&
                              ownPartner.profileImage!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.network(
                                ownPartner.profileImage!,
                                width: 44,
                                height: 44,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Text(
                                  ownPartner.name.isNotEmpty
                                      ? ownPartner.name[0].toUpperCase()
                                      : 'O',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              ownPartner.name.isNotEmpty
                                  ? ownPartner.name[0].toUpperCase()
                                  : 'O',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  ownPartner.name,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xFFA7F3D0)),
                                ),
                                child: Text(
                                  "Internal",
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          if (ownPartner.phone.isNotEmpty)
                            Text(
                              ownPartner.phone,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            "Vendor ID: ${ownPartner.partnerId}",
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Text(
                    "Self-delivery / internal delivery personnel will be assigned.",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Ready In Dropdown
            Row(
              children: [
                Text(
                  "Ready in: ",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedReadyTime,
                      icon: const Icon(Icons.keyboard_arrow_down,
                          size: 18, color: Color(0xFF64748B)),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w500,
                      ),
                      items: _readyTimeOptions.map((opt) {
                        return DropdownMenuItem<String>(
                          value: opt,
                          child: Text(opt),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedReadyTime = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Assign Own Deliveryman Button (Visible in Our Deliveryman tab)
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isAssigning
                    ? null
                    : () {
                        final readyMinutes =
                            _selectedReadyTime.replaceAll(' min', '');
                        final effectiveId = order.id.isNotEmpty
                            ? order.id
                            : widget.orderId;
                        context.read<OrderDetailsBloc>().add(
                              AssignOrderDeliveryPartnerEvent(
                                orderId: effectiveId,
                                deliveryPartnerId: ownPartner?.id ?? '',
                                deliveryManType: 'vendor',
                                deliveryPartner: 'vendor',
                                readyTime: readyMinutes,
                              ),
                            );
                      },
                child: isAssigning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "Assign Own Deliveryman",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ================= ASSIGNED DELIVERY PARTNER SECTION =================
  Widget _buildAssignedDeliveryPartnerSection(OrderDeliveryEntity? delivery) {
    String formattedAssignedDate = 'N/A';
    if (delivery?.deliveryAssignedAt != null) {
      formattedAssignedDate = DateFormat('MMM d, yyyy, hh:mm a')
          .format(delivery!.deliveryAssignedAt!);
    }

    final partner = delivery?.deliveryPartnerDetails;
    final partnerName =
        partner?.name.isNotEmpty == true ? partner!.name : 'Delivery Partner';
    final initialLetter =
        partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'M';
    final vehicleNumber = partner?.vehicleNumber.isNotEmpty == true
        ? partner!.vehicleNumber
        : 'N/A';
    final phone = partner?.phone.isNotEmpty == true ? partner!.phone : 'N/A';
    final email = partner?.email.isNotEmpty == true ? partner!.email : 'N/A';
    final otp = delivery?.deliveryOtp.isNotEmpty == true
        ? delivery!.deliveryOtp
        : 'N/A';

    return _buildCard(
      title: "Assigned Delivery Partner",
      icon: Icons.local_shipping_outlined,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              "Our Deliveryman",
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF059669),
              ),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: partner?.profileImage != null &&
                        partner!.profileImage!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          partner.profileImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            initialLetter,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                      )
                    : Text(
                        initialLetter,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partnerName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Vehicle: $vehicleNumber",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "DELIVERY OTP",
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD97706),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      otp,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFB45309),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phone_outlined,
                          size: 15, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          phone,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 15, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          email,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF334155),
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Assigned At: $formattedAssignedDate",
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= EXISTING CARDS & SECTIONS =================
  Widget _buildCard({
    String? title,
    Widget? titleWidget,
    IconData? icon,
    Widget? trailing,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: (title == null || title.isEmpty) && titleWidget == null
          ? child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: AppColors.primary, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: titleWidget ??
                                Text(
                                  title ?? '',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                        ],
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      trailing,
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                child,
              ],
            ),
    );
  }

  Widget _buildRentalOrderItemsSection(
      OrderDetailsResponseEntity orderDetails) {
    if (orderDetails.items.isEmpty) return const SizedBox.shrink();

    final item = orderDetails.items.first;
    final product = item.productDetails;
    final rentalDetails = item.rentalDetails;
    final productName =
        (product.tabletDetails != null && product.tabletDetails is Map)
            ? (product.tabletDetails['name'] ?? product.name)
            : (product.name.isNotEmpty
                ? product.name
                : (rentalDetails?.productSnapshot?.tabletName ??
                    rentalDetails?.productSnapshot?.name ??
                    'Unknown Product'));

    final snapshotImageUrls = rentalDetails?.productSnapshot?.imageUrl ?? [];
    final rawImageUrl = snapshotImageUrls.isNotEmpty
        ? snapshotImageUrls.first
        : (product.imageUrl.isNotEmpty ? product.imageUrl.first : '');
    final imageUrl = ApiEndpoints.getImageUrl(rawImageUrl);

    final perDayPrice =
        item.price > 0 ? item.price : (rentalDetails?.basePricePerDay ?? 0.0);
    final quantity = item.quantity > 0
        ? item.quantity
        : (rentalDetails?.rentalDuration ?? 1);

    return _buildCard(
      title: "Items (${orderDetails.items.length})",
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image_outlined,
                                  color: Colors.grey)))
                      : const Icon(Icons.image_outlined, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              productName,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black87),
                            ),
                          ),
                          Text(
                            "₹ $perDayPrice per day",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Item ID: ${item.orderItemId}",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildChip("Type: ${item.type.toLowerCase()}"),
                          _buildChip(
                              "Booking: ${item.bookingType.toLowerCase()}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey[200], height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Quantity",
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text("$quantity",
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Total Days",
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text("${rentalDetails?.totalDays ?? 0} days",
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Price / Day",
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(perDayPrice.toRupeeFormat(),
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
            fontSize: 11, color: Colors.grey[700], fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildOrderSummarySection(OrderDetailsResponseEntity orderDetails) {
    final firstItem =
        orderDetails.items.isNotEmpty ? orderDetails.items.first : null;
    final rentalDetails = firstItem?.rentalDetails;

    final basePrice = (firstItem != null && firstItem.price > 0)
        ? firstItem.price
        : (rentalDetails?.basePricePerDay ?? 0.0);
    final totalDays =
        (rentalDetails != null && rentalDetails.totalDays > 0)
            ? rentalDetails.totalDays
            : (rentalDetails != null && rentalDetails.rentalDuration > 0
                ? rentalDetails.rentalDuration
                : 1);

    final subtotal = orderDetails.subtotal > 0
        ? orderDetails.subtotal
        : (orderDetails.billingSummary.subtotal > 0
            ? orderDetails.billingSummary.subtotal
            : (basePrice * totalDays));

    final serviceCharges = rentalDetails?.serviceCharges ?? 0.0;
    final returnCharges = rentalDetails?.returnCharges ?? 0.0;
    final deposit = rentalDetails?.deposit ?? 0.0;
    final adminCommission = firstItem?.vendorCommissionAmount ?? 0.0;

    final gst = orderDetails.billingSummary.gstAmount;
    final couponType = orderDetails.billingSummary.couponType;
    final couponDiscount = orderDetails.billingSummary.couponDiscount;
    final totalRentalValue =
        subtotal + serviceCharges + returnCharges + deposit;
    final totalEarned = totalRentalValue;
    final firstInstallmentAmount = totalRentalValue;
    final installmentAmount =
        (rentalDetails != null && rentalDetails.installmentAmount > 0)
            ? rentalDetails.installmentAmount
            : (orderDetails.installmentList.isNotEmpty &&
                    orderDetails.installmentList.first.amount > 0)
                ? orderDetails.installmentList.first.amount
                : 0.0;

    return _buildCard(
      title: "Order Summary",
      child: Column(
        children: [
          _buildSummaryRow("Subtotal (Inclusive of All Taxes)",
              "${subtotal.toRupeeFormat()} ($basePrice x $totalDays days)"),
          const SizedBox(height: 12),
          _buildSummaryRow("GST", gst.toRupeeFormat()),
          if (couponType != null) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              "Coupon Discount",
              "-${couponDiscount.toRupeeFormat()}",
              valueColor: Colors.green,
              labelColor: Colors.green,
            ),
          ],
          const SizedBox(height: 12),
          _buildSummaryRow("Service Charges", serviceCharges.toRupeeFormat()),
          const SizedBox(height: 12),
          _buildSummaryRow("Return Charges", returnCharges.toRupeeFormat()),
          const SizedBox(height: 12),
          _buildSummaryRow("Deposit (Returnable)", deposit.toRupeeFormat()),
          if (adminCommission > 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
                "Admin Commission", "-${adminCommission.toRupeeFormat()}",
                valueColor: Colors.red, labelColor: Colors.red),
          ],
          const Divider(height: 32),
          _buildSummaryRow(
              "Total Rental Value", totalRentalValue.toRupeeFormat(),
              isBold: true),
          const SizedBox(height: 16),
          _buildSummaryRow("Total Earned", totalEarned.toRupeeFormat(),
              isBold: true, valueColor: AppColors.primary),
          const Divider(height: 32),
          _buildSummaryRow(
              "1st Installment Amount", firstInstallmentAmount.toRupeeFormat(),
              isBold: true, valueColor: AppColors.primary),
          const SizedBox(height: 16),
          Builder(
            builder: (context) {
              final pm = orderDetails.paymentMethod.isNotEmpty
                  ? orderDetails.paymentMethod
                  : rentalDetails?.paymentMethod;
              final paymentStr = (pm != null && pm.isNotEmpty)
                  ? pm[0].toUpperCase() + pm.substring(1).toLowerCase()
                  : 'Online';
              return _buildSummaryRow("Payment Method: $paymentStr", "",
                  isBold: false, labelSize: 11);
            },
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final pt = rentalDetails?.paymentType;
              final typeStr = (pt != null && pt.isNotEmpty)
                  ? pt[0].toUpperCase() + pt.substring(1).toLowerCase()
                  : 'Onetimepayment';
              return _buildSummaryRow("Payment Type: $typeStr", "",
                  isBold: false, labelSize: 11);
            },
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
              "Rental Plan: ${rentalDetails?.rentalPlan ?? 'Monthly'}", "",
              isBold: false, labelSize: 11),
          const SizedBox(height: 8),
          Builder(builder: (context) {
            final dateFormatter = DateFormat('dd/MM/yyyy');
            final startDateStr = rentalDetails?.startDate != null
                ? dateFormatter.format(rentalDetails!.startDate!)
                : '';
            final endDateStr = rentalDetails?.endDate != null
                ? dateFormatter.format(rentalDetails!.endDate!)
                : '';
            final rentalPeriod =
                startDateStr.isNotEmpty && endDateStr.isNotEmpty
                    ? '$startDateStr - $endDateStr'
                    : 'N/A';
            return _buildSummaryRow("Rental Period: $rentalPeriod", "",
                isBold: false, labelSize: 11);
          }),
          const SizedBox(height: 8),
          _buildSummaryRow(
              "Installment Amount: ${installmentAmount.toRupeeFormat()}", "",
              isBold: false, labelSize: 11),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color? labelColor,
      Color? valueColor,
      bool isBold = false,
      double labelSize = 12}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: labelColor ?? (isBold ? Colors.black87 : Colors.grey[600]),
              fontSize: labelSize,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                color: valueColor ?? (isBold ? Colors.black87 : Colors.black87),
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCustomerInformationSection(
      OrderDetailsResponseEntity orderDetails) {
    final user = orderDetails.userDetails;
    return _buildCard(
      title: "Customer Information",
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person_outline,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user != null &&
                              "${user.firstName} ${user.lastName}"
                                  .trim()
                                  .isNotEmpty
                          ? "${user.firstName} ${user.lastName}".trim()
                          : "Unknown",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    Text(
                      "Customer ID: ${user != null && user.custId.isNotEmpty ? user.custId.toUpperCase() : (user != null && user.id.isNotEmpty ? (user.id.length > 10 ? user.id.substring(user.id.length - 10).toUpperCase() : user.id.toUpperCase()) : '-')}",
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Age",
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
              Text("${user?.age ?? '-'} years",
                  style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Gender",
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.grey)),
              Text(user?.gender ?? "-",
                  style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstallmentListSection(OrderDetailsResponseEntity orderDetails) {
    final installments = orderDetails.installmentList;
    if (installments.isEmpty) return const SizedBox.shrink();

    final firstItem =
        orderDetails.items.isNotEmpty ? orderDetails.items.first : null;
    final rentalPlan = firstItem?.rentalDetails?.rentalPlan ?? 'Monthly';

    return _buildCard(
      title: "Installment List",
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xFFF9FAFB)),
            horizontalMargin: 16,
            columnSpacing: 24,
            headingRowHeight: 40,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 52,
            columns: [
              DataColumn(
                label: Text(
                  "S.no",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Amount",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Due Date",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Plan",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Status",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  "Type",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
            rows: installments.map((inst) {
              final dueDateStr = inst.dueDate != null
                  ? DateFormat('dd/MM/yyyy').format(inst.dueDate!)
                  : '-';
              final paymentTypeStr = inst.paymentMethod.isNotEmpty
                  ? inst.paymentMethod[0].toUpperCase() +
                      inst.paymentMethod.substring(1).toLowerCase()
                  : '-';

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      "${inst.installmentNumber}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      inst.amount.toRupeeFormat(),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      dueDateStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      rentalPlan,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  DataCell(
                    _buildInstallmentStatusBadge(inst.status),
                  ),
                  DataCell(
                    Text(
                      paymentTypeStr,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildInstallmentStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'paid':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        break;
      case 'pending':
        bgColor = const Color(0xFFFFF3E0);
        textColor = const Color(0xFFEF6C00);
        break;
      case 'overdue':
      case 'failed':
        bgColor = const Color(0xFFFFEBEE);
        textColor = const Color(0xFFC62828);
        break;
      default:
        bgColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.isNotEmpty
            ? status[0].toUpperCase() + status.substring(1).toLowerCase()
            : '-',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildShippingAddressSection() {
    return _buildCard(
      title: "Shipping Address",
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.local_shipping_outlined,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LULU Mall Beside panipuri bandi",
                    style: GoogleFonts.inter(fontSize: 12)),
                const SizedBox(height: 4),
                Text("JNTU Road", style: GoogleFonts.inter(fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  "Survey No. 1050, Balanagar Mandal, Rd Number 3, Kukatpally Housing Board Colony, K P H B Phase 3, Kukatpally, Hyderabad, Telangana 500072, India",
                  style:
                      GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                ),
                Row(
                  children: [
                    const Icon(Icons.business, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("Work",
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingAddressSection() {
    return _buildCard(
      title: "Billing Address",
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_outlined,
              color: AppColors.primary, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("LULU Mall Beside panipuri bandi",
                    style: GoogleFonts.inter(fontSize: 12)),
                const SizedBox(height: 4),
                Text("JNTU Road", style: GoogleFonts.inter(fontSize: 12)),
                const SizedBox(height: 8),
                Text(
                  "Survey No. 1050, Balanagar Mandal, Rd Number 3, Kukatpally Housing Board Colony, K P H B Phase 3, Kukatpally, Hyderabad, Telangana 500072, India",
                  style:
                      GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                ),
                Row(
                  children: [
                    const Icon(Icons.business, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text("Work",
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
