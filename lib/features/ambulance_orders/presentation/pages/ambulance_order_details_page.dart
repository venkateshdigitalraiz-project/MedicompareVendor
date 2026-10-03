import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../domain/entities/ambulance_order_entity.dart';
import '../bloc/ambulance_order_details_bloc.dart';
import '../bloc/ambulance_order_details_event.dart';
import '../bloc/ambulance_order_details_state.dart';

class AmbulanceOrderDetailsPage extends StatefulWidget {
  final String orderId;
  final AmbulanceOrderEntity? initialOrder;

  const AmbulanceOrderDetailsPage({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<AmbulanceOrderDetailsPage> createState() =>
      _AmbulanceOrderDetailsPageState();
}

class _AmbulanceOrderDetailsPageState extends State<AmbulanceOrderDetailsPage> {
  AmbulanceOrderEntity? _cachedOrder;
  int _selectedDeliveryTab = 0; // 0: Medicompares, 1: Own Deliveryman
  String? _selectedDeliveryPartnerId;
  String _selectedReadyTime = '30 min';
  final List<String> _readyTimeOptions = [
    '15 min',
    '30 min',
    '45 min',
    '60 min',
    '90 min',
    '120 min',
  ];
  final TextEditingController _partnerSearchController =
      TextEditingController();
  final ScrollController _partnerScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _partnerScrollController.addListener(_onPartnerScroll);
    _cachedOrder = widget.initialOrder;
    final effectiveId = widget.orderId.isNotEmpty
        ? widget.orderId
        : (widget.initialOrder?.id ?? '');
    if (effectiveId.isNotEmpty) {
      context
          .read<AmbulanceOrderDetailsBloc>()
          .add(GetAmbulanceOrderDetailsEvent(effectiveId));
    }
  }

  void _onPartnerScroll() {
    if (!_partnerScrollController.hasClients) return;
    final state = context.read<AmbulanceOrderDetailsBloc>().state;
    if (state is! AmbulanceOrderDetailsLoaded) return;

    // If list length is more than 10 (or >= 10), then increase page number
    if (state.deliveryPartners.length >= 10 &&
        state.hasMorePartners &&
        !state.isLoadingMorePartners &&
        !state.isLoadingPartners) {
      if (_partnerScrollController.position.pixels >=
          _partnerScrollController.position.maxScrollExtent - 40) {
        final nextPage = state.partnersPage + 1;
        context.read<AmbulanceOrderDetailsBloc>().add(
              GetAmbulanceDeliveryPartnersEvent(
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

  bool _isPendingStatus(String status) {
    final s = status.trim().toLowerCase();
    return s == 'pending' || s == 'new' || s.isEmpty;
  }

  bool _isConfirmedStatus(String status) {
    final s = status.trim().toLowerCase();
    return s == 'confirmed';
  }

  bool _isAssignedStatus(String status) {
    final s = status.trim().toLowerCase();
    return s == 'assigned' ||
        s == 'assigned_driver' ||
        s == 'assigned_delivery' ||
        s == 'intransit' ||
        s == 'in_transit' ||
        s == 'on_the_way';
  }

  Color _getStatusColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'confirmed':
        return const Color(0xFF0284C7);
      case 'intransit':
      case 'assigned':
        return const Color(0xFF4F46E5);
      case 'cancelled':
      case 'rejected':
      case 'failed':
        return const Color(0xFFDC2626);
      case 'pending':
      default:
        return const Color(0xFFEF6C00);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.trim().toLowerCase()) {
      case 'completed':
        return const Color(0xFFE8F5E9);
      case 'confirmed':
        return const Color(0xFFE0F2FE);
      case 'intransit':
      case 'assigned':
        return const Color(0xFFEEF2FF);
      case 'cancelled':
      case 'rejected':
      case 'failed':
        return const Color(0xFFFEE2E2);
      case 'pending':
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  Widget _buildAppBarActions(String bookingStatus, String resolvedOrderId) {
    return BlocBuilder<AmbulanceOrderDetailsBloc, AmbulanceOrderDetailsState>(
      builder: (context, state) {
        if (state is AmbulanceBookingStatusUpdatingState) {
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

        // Only show Cancel & Accept buttons when bookingStatus is pending
        final isPending = _isPendingStatus(bookingStatus);
        if (!isPending) {
          return const SizedBox.shrink();
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCompactAppBarButton(
              label: "Reject",
              color: const Color(0xFFDC2626),
              onTap: () => _showRejectOrderDialog(resolvedOrderId),
            ),
            const SizedBox(width: 6),
            _buildCompactAppBarButton(
              label: "Accept",
              color: AppColors.primary,
              onTap: () {
                context.read<AmbulanceOrderDetailsBloc>().add(
                      UpdateAmbulanceBookingStatusEvent(
                        orderId: resolvedOrderId,
                        bookingStatus: 'confirmed',
                      ),
                    );
              },
            ),
          ],
        );
      },
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

  void _showRejectOrderDialog(String orderId) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Reject Order",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please provide a reason for rejecting this ambulance booking.",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter rejection reason...",
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
                    content: Text("Please enter a rejection reason"),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(ctx);
              context.read<AmbulanceOrderDetailsBloc>().add(
                    UpdateAmbulanceBookingStatusEvent(
                      orderId: orderId,
                      bookingStatus: 'cancelled',
                      reason: reason,
                    ),
                  );
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
              "Reject Order",
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AmbulanceOrderDetailsBloc, AmbulanceOrderDetailsState>(
      listener: (context, state) {
        if (state is AmbulanceOrderDetailsLoaded) {
          _cachedOrder = state.order;
        } else if (state is AmbulanceBookingStatusUpdatedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          final effectiveId = widget.orderId.isNotEmpty
              ? widget.orderId
              : (_cachedOrder?.id ?? '');
          if (effectiveId.isNotEmpty) {
            context
                .read<AmbulanceOrderDetailsBloc>()
                .add(GetAmbulanceOrderDetailsEvent(effectiveId));
          }
        } else if (state is AmbulanceBookingStatusUpdateErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AmbulanceOrderDetailsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final order = state is AmbulanceOrderDetailsLoaded
            ? state.order
            : (_cachedOrder ?? widget.initialOrder);

        if (state is AmbulanceOrderDetailsLoading && order == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9FAFB),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (order == null) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9FAFB),
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const BackButton(color: Colors.black87),
              title: Text(
                "Ambulance Order Details",
                style: GoogleFonts.inter(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
            ),
            body: Center(
              child: Text(
                "Order details not found",
                style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 14),
              ),
            ),
          );
        }

        final customer = order.customer;
        final product = order.product;
        final resolvedOrderId = order.id.isNotEmpty
            ? order.id
            : (order.bookingId.isNotEmpty ? order.bookingId : widget.orderId);
        final displayId =
            order.bookingId.isNotEmpty ? order.bookingId : resolvedOrderId;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leadingWidth: 36,
            leading: IconButton(
              icon:
                  const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Ambulance Order Details",
                  style: GoogleFonts.inter(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "ID: ${displayId.length > 16 ? '${displayId.substring(0, 16)}...' : displayId}",
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            actions: [
              _buildAppBarActions(order.bookingStatus, resolvedOrderId),
              const SizedBox(width: 8),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Delivery Assignment Section (When confirmed) ─────────────────
                    if (_isConfirmedStatus(order.bookingStatus)) ...[
                      _buildDeliveryAssignmentSection(
                          state, order, resolvedOrderId),
                      const SizedBox(height: 24),
                    ] else if (_isAssignedStatus(order.bookingStatus) ||
                        order.driver != null) ...[
                      // ── Assigned Delivery Driver Section (When assigned) ───────────
                      _buildAssignedDriverSection(order.driver),
                      const SizedBox(height: 24),
                    ],

                    // ── Order Information ────────────────────────────
                    _buildOrderInformationSection(order, isWide),
                    const SizedBox(height: 24),

                    // ── Ambulance Service Details ────────────────────
                    if (product != null) ...[
                      _buildAmbulanceDetailsSection(order, product),
                      const SizedBox(height: 24),
                    ],

                    // ── Patient / Customer Information ──────────────
                    if (customer != null) ...[
                      _buildPatientInfoSection(customer),
                      const SizedBox(height: 24),
                    ],

                    // ── Trip & Route Details ─────────────────────────
                    _buildTripDetailsSection(order),
                    const SizedBox(height: 24),

                    // ── Fare & Billing Summary ───────────────────────
                    _buildFareSummarySection(order),
                    const SizedBox(height: 24),

                    // ── Business Contact ─────────────────────────────
                    if (product?.businessName != null &&
                        product!.businessName!.isNotEmpty) ...[
                      _buildBusinessContactSection(product),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Assigned Delivery Driver Section ────────────────────────────────
  Widget _buildAssignedDriverSection(AmbulanceDriverEntity? driver) {
    String formattedAssignedDate = 'N/A';
    if (driver?.assignedAt != null) {
      formattedAssignedDate =
          DateFormat('MMM d, yyyy, hh:mm a').format(driver!.assignedAt!);
    }

    final driverName = (driver?.name.trim().isNotEmpty == true)
        ? driver!.name
        : 'Test Delivery Man';
    final initialLetter =
        driverName.isNotEmpty ? driverName[0].toUpperCase() : 'T';
    final vehicleNumber = (driver?.vehicleNumber.trim().isNotEmpty == true)
        ? driver!.vehicleNumber
        : 'TG12EC1346';
    final driverId = (driver?.driverId.trim().isNotEmpty == true)
        ? driver!.driverId
        : 'DP20260002';
    final phone = (driver?.phone.trim().isNotEmpty == true)
        ? driver!.phone
        : '7850453609';
    final email =
        (driver?.email.trim().isNotEmpty == true) ? driver!.email : 'a@a.com';
    final otp = (driver?.otp.trim().isNotEmpty == true) ? driver!.otp : '8358';
    final rawType = driver?.driverType;
    final driverType = (rawType != null && rawType.trim().isNotEmpty)
        ? rawType
        : 'Medicompares Partner';

    return _buildCard(
      title: "Assigned Delivery Driver",
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
              driverType,
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
                child: driver?.profileImage != null &&
                        driver!.profileImage!.startsWith('http')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          driver.profileImage!,
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
                      driverName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Vehicle: $vehicleNumber \n• ID: $driverId",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //   padding:
              //       const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              //   decoration: BoxDecoration(
              //     color: const Color(0xFFFFFBEB),
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: const Color(0xFFFDE68A)),
              //   ),
              //   child: Column(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Text(
              //         "DELIVERY OTP",
              //         style: GoogleFonts.inter(
              //           fontSize: 9,
              //           fontWeight: FontWeight.w700,
              //           color: const Color(0xFFD97706),
              //           letterSpacing: 0.5,
              //         ),
              //       ),
              //       const SizedBox(height: 2),
              //       Text(
              //         otp,
              //         style: GoogleFonts.inter(
              //           fontSize: 15,
              //           fontWeight: FontWeight.bold,
              //           color: const Color(0xFFB45309),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
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
          if (formattedAssignedDate != 'N/A') ...[
            const SizedBox(height: 12),
            Text(
              "Assigned At: $formattedAssignedDate",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Delivery Assignment Section (With Tabs) ─────────────────────────
  Widget _buildDeliveryAssignmentSection(
    AmbulanceOrderDetailsState state,
    AmbulanceOrderEntity order,
    String resolvedOrderId,
  ) {
    final loadedState = state is AmbulanceOrderDetailsLoaded ? state : null;
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
          // Segmented Tabs: Medicompares vs Own Deliveryman
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
                        "Own Deliveryman",
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
                            context.read<AmbulanceOrderDetailsBloc>().add(
                                  const GetAmbulanceDeliveryPartnersEvent(
                                      search: '', forceRefresh: true),
                                );
                          },
                        )
                      : null,
                ),
                style: GoogleFonts.inter(
                    fontSize: 13, color: const Color(0xFF1E293B)),
                onSubmitted: (value) {
                  context.read<AmbulanceOrderDetailsBloc>().add(
                        GetAmbulanceDeliveryPartnersEvent(
                            search: value.trim(), forceRefresh: true),
                      );
                },
                onChanged: (value) {
                  if (value.isEmpty) {
                    context.read<AmbulanceOrderDetailsBloc>().add(
                          const GetAmbulanceDeliveryPartnersEvent(
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
                          context.read<AmbulanceOrderDetailsBloc>().add(
                                const GetAmbulanceDeliveryPartnersEvent(
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
                            _selectedReadyTime.replaceAll(' min', '').trim();
                        context.read<AmbulanceOrderDetailsBloc>().add(
                              AssignAmbulanceDeliveryPartnerEvent(
                                orderId: resolvedOrderId,
                                deliveryPartnerId: _selectedDeliveryPartnerId!,
                                deliveryManType: 'admin',
                                deliveryPartner: 'medicompares',
                                readyTime: readyMinutes.isNotEmpty
                                    ? readyMinutes
                                    : '30',
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
          ] else ...[
            // Own Deliveryman tab
            if (isLoadingPartners && ownPartner == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (ownPartner != null) ...[
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
                              ownPartner.profileImage!.startsWith('http')
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

              // Assign Own Deliveryman Button
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
                          context.read<AmbulanceOrderDetailsBloc>().add(
                                AssignAmbulanceDeliveryPartnerEvent(
                                  orderId: resolvedOrderId,
                                  deliveryPartnerId: ownPartner.id,
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
            ] else ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.person_pin_circle_outlined,
                        size: 40, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      "Own Deliveryman",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "No internal delivery personnel registered.",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ── Order Information Section ────────────────────────────────────────
  Widget _buildOrderInformationSection(
      AmbulanceOrderEntity order, bool isWide) {
    final String formattedDate =
        DateFormat('MMM dd, yyyy, hh:mm a').format(order.createdAt);
    final String emergencyType = order.emergencyType.isNotEmpty
        ? _capitalize(
            order.emergencyType.replaceAll('nonemergency', 'Non-Emergency'))
        : 'Standard';

    final column1 = [
      _buildInfoBlock("Booking ID",
          order.bookingId.isNotEmpty ? order.bookingId : order.id),
      _buildInfoBlock("Order Date", formattedDate),
      _buildInfoBlock("Emergency Type", emergencyType),
    ];

    final column2 = [
      _buildInfoBlock(
        "Payment Method",
        order.paymentMethod.isNotEmpty
            ? (order.paymentMethod.toLowerCase() == 'cod'
                ? 'Cash on Delivery'
                : _capitalize(order.paymentMethod))
            : 'Online',
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Booking Status",
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            _statusPill(order.bookingStatus),
          ],
        ),
      ),
    ];

    return _buildCard(
      title: "Order Information",
      icon: Icons.inventory_2_outlined,
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: column1,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: column2,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...column1,
                ...column2,
              ],
            ),
    );
  }

  // ── Ambulance Service Details Section ────────────────────────────────
  Widget _buildAmbulanceDetailsSection(
      AmbulanceOrderEntity order, AmbulanceOrderProductDetail product) {
    return _buildCard(
      title: "Ambulance Details",
      icon: Icons.airport_shuttle_outlined,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child:
                product.imageUrl != null && product.imageUrl!.startsWith('http')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _ambulancePlaceholder(),
                        ),
                      )
                    : _ambulancePlaceholder(),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.serviceName.isNotEmpty
                      ? product.serviceName
                      : "Ambulance Service",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (product.ambulanceType != null &&
                    product.ambulanceType!.isNotEmpty)
                  Text(
                    "Type: ${_capitalize(product.ambulanceType!)}",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                if (product.businessName != null &&
                    product.businessName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.business_center_outlined,
                          size: 13, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product.businessName!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      product.discountPrice.toRupeeFormat(decimalDigits: 2),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    if (product.price > product.discountPrice &&
                        product.discountPrice > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        product.price.toRupeeFormat(decimalDigits: 2),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Patient Info Section ─────────────────────────────────────────────
  Widget _buildPatientInfoSection(AmbulanceOrderUser customer) {
    final initialLetter =
        customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : 'P';

    return _buildCard(
      title: "Patient Information",
      icon: Icons.person_outline_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: customer.profileImage != null &&
                        customer.profileImage!.startsWith('http')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(23),
                        child: Image.network(
                          customer.profileImage!,
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            initialLetter,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        initialLetter,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.fullName.isNotEmpty
                          ? customer.fullName
                          : "Customer",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    if (customer.age != null || customer.gender != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (customer.age != null) 'Age: ${customer.age}',
                          if (customer.gender != null &&
                              customer.gender!.isNotEmpty)
                            _capitalize(customer.gender!),
                        ].join(' • '),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 14),
          if (customer.phone.isNotEmpty)
            _contactTile(
                Icons.phone_outlined, customer.phone, const Color(0xFF0EA5E9)),
          if (customer.email.isNotEmpty) ...[
            const SizedBox(height: 8),
            _contactTile(Icons.email_outlined, customer.email, Colors.purple),
          ],
          if (customer.medicalConditions != null &&
              customer.medicalConditions!.trim().isNotEmpty &&
              customer.medicalConditions!.trim().toLowerCase() != 'null') ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.red, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'MEDICAL CONDITIONS',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customer.medicalConditions!,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.red.shade900,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Trip & Route Details Section ─────────────────────────────────────
  Widget _buildTripDetailsSection(AmbulanceOrderEntity order) {
    return _buildCard(
      title: "Trip Details",
      icon: Icons.map_outlined,
      child: Column(
        children: [
          _tripStop(
            dotColor: Colors.green,
            label: 'PICKUP',
            address: order.pickupLocation.address.isNotEmpty
                ? order.pickupLocation.address
                : 'Address not available',
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Container(width: 2, height: 32, color: Colors.grey.shade300),
              ],
            ),
          ),
          _tripStop(
            dotColor: Colors.red,
            label: 'DROPOFF',
            address: order.dropoffLocation.address.isNotEmpty
                ? order.dropoffLocation.address
                : 'Address not available',
          ),
          const SizedBox(height: 16),
          if (order.bookingDateTime != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Booking Date & Time: ',
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.grey.shade600),
                      ),
                      // Expanded(
                      //   child: Text(
                      //     DateFormat('MMM dd, yyyy, hh:mm a')
                      //         .format(order.bookingDateTime!),
                      //     style: GoogleFonts.inter(
                      //       fontSize: 13,
                      //       fontWeight: FontWeight.bold,
                      //       color: AppColors.primary,
                      //     ),
                      //     maxLines: 1,
                      //     overflow: TextOverflow.ellipsis,
                      //   ),
                      // ),
                    ],
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy, hh:mm a')
                        .format(order.bookingDateTime!),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.social_distance_outlined,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Total Distance: ',
                  style: GoogleFonts.inter(
                      fontSize: 13, color: Colors.grey.shade600),
                ),
                Text(
                  '${order.distance.toStringAsFixed(1)} km',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Fare & Billing Summary Section ───────────────────────────────────
  Widget _buildFareSummarySection(AmbulanceOrderEntity order) {
    final isPaid = order.paymentStatus.toLowerCase() == 'paid';
    final isVendorCoupon = order.couponType.trim().toLowerCase() == 'vendor';
    final effectiveCoupon = isVendorCoupon ? order.couponAmount : 0.0;
    final couponLabel = order.couponCode.isNotEmpty
        ? "Coupon Discount (${order.couponCode})"
        : "Coupon Discount (DIGIHidden)";

    // Grand total:
    // when "coupontype": "vendor" -> basic fare - admin commision - Coupon Discount
    // when coupontype any type -> basic fare - admin commision
    final double calculatedTotal =
        order.subtotal - order.adminCommission - effectiveCoupon;
    final double total = calculatedTotal;

    return _buildCard(
      title: "Billing Summary",
      icon: Icons.receipt_long_outlined,
      child: Column(
        children: [
          _buildSummaryRow(
            "Payment Status",
            _capitalize(order.paymentStatus),
            valueColor: isPaid ? Colors.green : Colors.orange,
          ),
          const Divider(height: 20),
          _buildSummaryRow(
            "Base Fare(Inclusive of all taxes)",
            order.subtotal.toRupeeFormat(decimalDigits: 2),
          ),
          if (isVendorCoupon &&
              (order.couponAmount > 0 || order.couponType.isNotEmpty))
            _buildSummaryRow(
              couponLabel,
              "-${order.couponAmount.toRupeeFormat(decimalDigits: 2)}",
              valueColor: Colors.red,
              labelColor: Colors.red,
            ),
          _buildSummaryRow(
            "Admin Commission",
            order.adminCommission > 0
                ? "-${order.adminCommission.toRupeeFormat(decimalDigits: 2)}"
                : "-${0.0.toRupeeFormat(decimalDigits: 2)}",
            valueColor: Colors.red,
            labelColor: Colors.red,
          ),
          _buildSummaryRow(
            "GST",
            order.gst.toRupeeFormat(decimalDigits: 2),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Grand Total",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                total < 0
                    ? "-${total.abs().toRupeeFormat(decimalDigits: 2)}"
                    : total.toRupeeFormat(decimalDigits: 2),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: total < 0 ? Colors.red : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  order.paymentMethod.toLowerCase() == 'cod'
                      ? Icons.money_outlined
                      : Icons.credit_card_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  order.paymentMethod.toLowerCase() == 'cod'
                      ? 'Cash on Delivery'
                      : 'Online Payment',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Business Contact Section ─────────────────────────────────────────
  Widget _buildBusinessContactSection(AmbulanceOrderProductDetail product) {
    return _buildCard(
      title: "Business Contact",
      icon: Icons.business_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.businessName ?? '',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          if (product.businessPhone != null &&
              product.businessPhone!.isNotEmpty)
            _contactTile(
                Icons.phone_outlined, product.businessPhone!, Colors.green),
          if (product.businessEmail != null &&
              product.businessEmail!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _contactTile(
                Icons.email_outlined, product.businessEmail!, Colors.purple),
          ],
          if (product.businessAddress != null &&
              product.businessAddress!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _contactTile(Icons.location_on_outlined, product.businessAddress!,
                Colors.red),
          ],
        ],
      ),
    );
  }

  // ── Reusable Component Helpers (matching AppointmentDetailsPage) ────

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }

  Widget _buildInfoBlock(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF94A3B8), // slate 400
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B), // slate 800
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    Color? labelColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: labelColor ?? Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String status) {
    final color = _getStatusColor(status);
    final bg = _getStatusBgColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            _capitalize(status),
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tripStop({
    required Color dotColor,
    required String label,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: dotColor.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: dotColor, width: 2),
          ),
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF1E293B),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contactTile(IconData icon, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF374151),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _ambulancePlaceholder() => Container(
        color: const Color(0xFFEEF2FF),
        child: const Icon(
          Icons.airport_shuttle_rounded,
          color: AppColors.primary,
          size: 28,
        ),
      );
}
