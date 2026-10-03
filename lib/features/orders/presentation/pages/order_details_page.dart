import 'dart:developer';

import 'package:MediCompare/features/orders/domain/entities/order_details_response_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../bloc/order_details_bloc.dart';
import '../bloc/order_details_event.dart';
import '../bloc/order_details_state.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;
  final String orderType;

  const OrderDetailPage({
    super.key,
    required this.orderId,
    this.orderType = 'normal',
  });

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  // Keeping delivery state for updates even if hidden from this UI view for now
  final String _selectedDeliveryPartner = 'medicompares';
  final int _selectedParcelTime = 30;

  int _selectedDeliveryTab = 0;
  String? _selectedDeliveryPartnerId;
  String _selectedReadyTime = '30 min';
  final List<String> _readyTimeOptions = [
    '15 min',
    '30 min',
    '45 min',
    '60 min',
  ];
  final TextEditingController _partnerSearchController =
      TextEditingController();
  final ScrollController _partnerScrollController = ScrollController();
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _partnerScrollController.addListener(_onPartnerScroll);
    context
        .read<OrderDetailsBloc>()
        .add(GetOrderDetailsEvent(widget.orderId, orderType: widget.orderType));
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
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            SizedBox(width: 30),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order Details",
                  style: GoogleFonts.inter(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
                  builder: (context, state) {
                    String displayId = widget.orderId;
                    if (state is OrderDetailsLoaded) {
                      displayId = state.orderDetails.orderRef;
                    }
                    return Text(
                      "ID: ${displayId.length > 15 && !displayId.startsWith('ORD') ? '${displayId.substring(0, 15)}...' : displayId}",
                      style: GoogleFonts.inter(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
            builder: (context, state) {
              if (state is OrderDetailsLoaded) {
                final orderDetails = state.orderDetails;
                final status = orderDetails.orderStatus.toLowerCase();
                if (status == 'new' || status == 'pending') {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCompactActionButton(
                          "Cancel", Colors.red, () => _showRejectionDialog()),
                      _buildCompactActionButton("Accept", AppColors.primary,
                          () => _showAcceptOrderDialog(orderDetails)),
                    ],
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<OrderDetailsBloc, OrderDetailsState>(
        listener: (context, state) {
          if (state is OrderStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
            context
                .read<OrderDetailsBloc>()
                .add(GetOrderDetailsEvent(widget.orderId));
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
                  if (orderDetails.otpEnable == 'yes' && orderDetails.otpStatus == 'pending') ...[
                    _buildOtpVerificationSection(orderDetails),
                    const SizedBox(height: 16),
                  ],
                  _buildOrderItemsSection(orderDetails),
                  const SizedBox(height: 16),
                  _buildOrderSummarySection(orderDetails),
                ],
              );

              final rightColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  deliverySection,
                  if (hasDeliverySection) const SizedBox(height: 16),
                  _buildOrderInformationSection(orderDetails),
                  const SizedBox(height: 16),
                  _buildCustomerInformationSection(orderDetails),
                  const SizedBox(height: 16),
                  _buildShippingAddressSection(orderDetails),
                  if (orderDetails.shippingAddressDetails != null)
                    const SizedBox(height: 16),
                  _buildBillingAddressSection(orderDetails),
                ],
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: isWide
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
                          if (orderDetails.otpEnable == 'yes' && orderDetails.otpStatus == 'pending') ...[
                            _buildOtpVerificationSection(orderDetails),
                            const SizedBox(height: 16),
                          ],
                          deliverySection,
                          if (hasDeliverySection) const SizedBox(height: 16),
                          _buildOrderItemsSection(orderDetails),
                          const SizedBox(height: 16),
                          _buildOrderInformationSection(orderDetails),
                          const SizedBox(height: 16),
                          _buildCustomerInformationSection(orderDetails),
                          const SizedBox(height: 16),
                          _buildOrderSummarySection(orderDetails),
                          const SizedBox(height: 16),
                          _buildShippingAddressSection(orderDetails),
                          if (orderDetails.shippingAddressDetails != null)
                            const SizedBox(height: 16),
                          //    _buildBillingAddressSection(orderDetails),
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

  void _handleUpdateStatus(String status, {String? rejectionReason}) {
    final state = context.read<OrderDetailsBloc>().state;
    if (state is OrderDetailsLoaded) {
      final orderDetails = state.orderDetails;
      if (orderDetails.items.isEmpty) return;
      final payload = {
        "deliveryManType": "admin",
        "deliveryPartner": _selectedDeliveryPartner,
        "deliveryPartnerId": null,
        "orderId": orderDetails.id,
        "orderStatus": status,
        "packageIds": [],
        "productIds": [],
        "readyTime": _selectedParcelTime.toString(),
        "rejectionReason": rejectionReason,
        "status": status,
      };

      context.read<OrderDetailsBloc>().add(UpdateOrderStatusEvent(
            orderItemId: orderDetails.id,
            payload: payload,
          ));
    }
  }

  void _showAcceptOrderDialog(OrderDetailsResponseEntity orderDetails) {
    showDialog(
      context: context,
      builder: (ctx) => _AcceptOrderDialog(
        orderDetails: orderDetails,
        onAccept: (status, {rejectionReason}) {
          _handleUpdateStatus(status, rejectionReason: rejectionReason);
        },
      ),
    );
  }

  void _showRejectionDialog() {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Cancel Order",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please provide a reason for cancelling this order.",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter cancellation reason...",
                hintStyle: GoogleFonts.inter(fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              style: GoogleFonts.inter(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Close",
              style: GoogleFonts.inter(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _handleUpdateStatus('cancelled',
                    rejectionReason: reasonController.text.trim());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please enter a reason for cancellation"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Cancel Order",
              style: GoogleFonts.inter(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactActionButton(
      String label, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          minimumSize: const Size(60, 32),
        ),
        child: Text(label,
            style:
                GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildOrderItemsSection(OrderDetailsResponseEntity orderDetails) {
    return _buildCard(
      title: "Order Items (${orderDetails.items.length})",
      child: Column(
        children: orderDetails.items.map((item) {
          final product = item.productDetails;
          final tablet = product.tabletDetails;
          final productName =
              tablet != null ? tablet['name'] ?? product.name : product.name;
          List<String> imageUrls = [];
          if (product.variantDetails != null &&
              product.variantDetails['tabletVariant'] != null) {
            final vImgUrl = product.variantDetails['tabletVariant']
                    ['imageUrl'] ??
                product.variantDetails['tabletVariant']['imageurl'];
            if (vImgUrl is List && vImgUrl.isNotEmpty) {
              imageUrls = vImgUrl
                  .map((e) => e.toString())
                  .where((e) => e.trim().isNotEmpty)
                  .toList();
            } else if (vImgUrl is String && vImgUrl.trim().isNotEmpty) {
              imageUrls = [vImgUrl];
            }
          }

          if (imageUrls.isEmpty) {
            if (product.imageUrl.isNotEmpty) {
              imageUrls =
                  product.imageUrl.where((e) => e.trim().isNotEmpty).toList();
            } else if (product.files.isNotEmpty) {
              imageUrls =
                  product.files.where((e) => e.trim().isNotEmpty).toList();
            } else if (tablet != null) {
              final tImgUrl = tablet['imageUrl'] ?? tablet['imageurl'];
              final tFiles = tablet['files'];
              if (tImgUrl is List && tImgUrl.isNotEmpty) {
                imageUrls = tImgUrl
                    .map((e) => e.toString())
                    .where((e) => e.trim().isNotEmpty)
                    .toList();
              } else if (tImgUrl is String && tImgUrl.trim().isNotEmpty) {
                imageUrls = [tImgUrl];
              } else if (tFiles is List && tFiles.isNotEmpty) {
                imageUrls = tFiles
                    .map((e) => e.toString())
                    .where((e) => e.trim().isNotEmpty)
                    .toList();
              } else if (tFiles is String && tFiles.trim().isNotEmpty) {
                imageUrls = [tFiles];
              }
            }
          }
          log("imageUrls : $imageUrls");

          //  final gst = item.billingSummary.gstAmount;

          return Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: imageUrls.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(imageUrls.first,
                                  fit: BoxFit.cover))
                          : const Icon(Icons.image_outlined,
                              color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(productName,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text("ID: ${item.orderItemId}",
                                  style: GoogleFonts.inter(
                                      fontSize: 11, color: Colors.grey[600])),
                              if (product.variantDetails != null &&
                                  product.variantDetails['tabletVariant'] !=
                                      null &&
                                  product.variantDetails['tabletVariant']
                                          ['name'] !=
                                      null)
                                Text(
                                    "Variant: ${product.variantDetails['tabletVariant']['name']}",
                                    style: GoogleFonts.inter(
                                        fontSize: 11, color: Colors.grey[600]))
                              else if (tablet != null &&
                                  tablet['variant'] != null)
                                Text("Variant: ${tablet['variant']}",
                                    style: GoogleFonts.inter(
                                        fontSize: 11, color: Colors.grey[600])),
                              Text("Type: ${item.type.toLowerCase()}",
                                  style: GoogleFonts.inter(
                                      fontSize: 11, color: Colors.grey[600])),
                              Text("Booking: ${item.bookingType.toLowerCase()}",
                                  style: GoogleFonts.inter(
                                      fontSize: 11, color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.grey[200], height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Commission",
                            style: GoogleFonts.inter(
                                fontSize: 10, color: Colors.grey[500])),
                        const SizedBox(height: 2),
                        Text(
                            item.vendorCommissionAmount
                                .toRupeeFormat(decimalDigits: 2),
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("GST",
                            style: GoogleFonts.inter(
                                fontSize: 10, color: Colors.grey[500])),
                        const SizedBox(height: 2),
                        Text(
                            item.billingSummary.gstAmount
                                .toRupeeFormat(decimalDigits: 2),
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("Total (x${item.quantity})",
                            style: GoogleFonts.inter(
                                fontSize: 10, color: Colors.grey[500])),
                        const SizedBox(height: 2),
                        Text(
                            (item.billingSummary.finalAmount -
                                    item.billingSummary.gstAmount)
                                .toRupeeFormat(decimalDigits: 2),
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.black87)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderInformationSection(
      OrderDetailsResponseEntity orderDetails) {
    String branchName = "-";
    if (orderDetails.branchDetails != null) {
      if (orderDetails.branchDetails is Map) {
        branchName = orderDetails.branchDetails['name']?.toString() ??
            orderDetails.branchDetails['branchName']?.toString() ??
            "-";
      } else if (orderDetails.branchDetails is String) {
        branchName = orderDetails.branchDetails;
      }
    }

    final formattedDate = DateFormat('dd MMM yyyy, hh:mm a')
        .format(orderDetails.createdAt.toLocal());

    return _buildCard(
      title: "Order Information",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoItemCard(
                  icon: Icons.storefront_outlined,
                  iconColor: AppColors.primary,
                  label: "Branch",
                  value: branchName,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoItemCard(
                  icon: Icons.receipt_long_outlined,
                  iconColor: Colors.orange,
                  label: "Order Status",
                  valueWidget: _buildStatusBadge(orderDetails.orderStatus),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildInfoItemCard(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: Colors.green,
                  label: "Payment Status",
                  valueWidget:
                      _buildPaymentStatusBadge(orderDetails.paymentStatus),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildInfoItemCard(
                  icon: Icons.calendar_today_outlined,
                  iconColor: Colors.blueGrey,
                  label: "Order Date",
                  value: formattedDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildInfoItemCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    String? value,
    Widget? valueWidget,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                if (valueWidget != null)
                  valueWidget
                else
                  Text(
                    value ?? "-",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'new':
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
      case 'accepted':
      case 'delivered':
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.isEmpty ? "N/A" : status.toUpperCase(),
        style: GoogleFonts.inter(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(String paymentStatus) {
    final isPaid = paymentStatus.toLowerCase() == 'paid' ||
        paymentStatus.toLowerCase() == 'completed';
    final color = isPaid ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        paymentStatus.isEmpty ? "N/A" : paymentStatus.toUpperCase(),
        style: GoogleFonts.inter(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCustomerInformationSection(
      OrderDetailsResponseEntity orderDetails) {
    final user = orderDetails.userDetails;
    if (user == null) return const SizedBox.shrink();

    return _buildCard(
      title: "Customer Information",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person_outline,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${user.firstName} ${user.lastName}",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87)),
                    Text(
                        "Customer ID: ${user.custId.isNotEmpty ? user.custId.toUpperCase() : (user.id.length > 10 ? user.id.substring(user.id.length - 10).toUpperCase() : user.id.toUpperCase())}",
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Age",
                  style:
                      GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
              Text("${user.age} years",
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Gender",
                  style:
                      GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
              Text(
                  user.gender.isNotEmpty
                      ? user.gender[0].toUpperCase() + user.gender.substring(1)
                      : "Unknown",
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection(OrderDetailsResponseEntity details) {
    final gst = details.billingSummary.gstAmount;
    final adminCommission = details.items
        .fold<double>(0.0, (sum, item) => sum + item.vendorCommissionAmount);
    final couponType = details.billingSummary.couponType;
    final couponDiscount = details.billingSummary.couponDiscount;
    final totalEarnings = couponType == "vendor"
        ? details.billingSummary.baseAmount -
            adminCommission -
            couponDiscount +
            details.billingSummary.deliveryCharges
        : details.billingSummary.baseAmount -
            adminCommission +
            details.billingSummary.deliveryCharges;

    return _buildCard(
      title: "Order Summary",
      child: Column(
        children: [
          _buildSummaryRow(
              "Subtotal (Inclusive of all taxes)",
              details.billingSummary.baseAmount
                  .toRupeeFormat(decimalDigits: 2)),
          const SizedBox(height: 16),
          _buildSummaryRow("GST", gst.toRupeeFormat(decimalDigits: 2)),
          const SizedBox(height: 16),
          _buildSummaryRow("Admin Commission",
              "-${adminCommission.toRupeeFormat(decimalDigits: 2)}",
              valueColor: Colors.red, labelColor: Colors.red),
          const SizedBox(height: 16),
          if (couponType == "vendor") ...[
            _buildSummaryRow(
              "Coupon Discount",
              "-${couponDiscount.toRupeeFormat(decimalDigits: 2)}",
              valueColor: Colors.green,
              labelColor: Colors.green,
            ),
            const SizedBox(height: 16),
          ],
          if (details.billingSummary.deliveryCharges > 0) ...[
            _buildSummaryRow(
              "Delivery Charge",
              details.billingSummary.deliveryCharges
                  .toRupeeFormat(decimalDigits: 2),
              valueColor: Colors.black87,
            ),
          ],
          //    const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          _buildSummaryRow(
              "Total Earnings", totalEarnings.toRupeeFormat(decimalDigits: 2),
              isTotal: true),
          const SizedBox(height: 16),
          Row(
            children: [
              Text("Payment Method: ",
                  style:
                      GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
              Text(
                  details.paymentMethod.isNotEmpty
                      ? details.paymentMethod[0].toUpperCase() +
                          details.paymentMethod.substring(1).toLowerCase()
                      : "Online",
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, Color? valueColor, Color? labelColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 14 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: labelColor ?? (isTotal ? Colors.black87 : Colors.grey[600]),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isTotal ? AppColors.primary : Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingAddressSection(OrderDetailsResponseEntity order) {
    final adr = order.shippingAddressDetails;
    if (adr == null) return const SizedBox.shrink();

    return _buildCard(
      titleWidget: Row(
        children: [
          const Icon(Icons.local_shipping_outlined,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text("Shipping Address",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(adr.houseNo.isNotEmpty ? adr.houseNo : "No House No",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(adr.area.isNotEmpty ? adr.area : "No Area",
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Text(adr.landmark.isNotEmpty ? adr.landmark : "No Landmark",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(adr.fullAddress.isNotEmpty ? adr.fullAddress : "No Full Address",
              style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.grey[600], height: 1.5)),
          const SizedBox(height: 12),
          Text("PIN: ${adr.pincode}",
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.business_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                  adr.addressType.isNotEmpty
                      ? adr.addressType[0].toUpperCase() +
                          adr.addressType.substring(1).toLowerCase()
                      : "Address Type",
                  style:
                      GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingAddressSection(OrderDetailsResponseEntity order) {
    final adr = order.billingAddressDetails;
    if (adr == null) return const SizedBox.shrink();

    return _buildCard(
      titleWidget: Row(
        children: [
          const Icon(Icons.location_on_outlined,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text("Billing Address",
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(adr.houseNo.isNotEmpty ? adr.houseNo : "No House No",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(adr.area.isNotEmpty ? adr.area : "No Area",
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Text(adr.landmark.isNotEmpty ? adr.landmark : "No Landmark",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(adr.fullAddress.isNotEmpty ? adr.fullAddress : "No Full Address",
              style: GoogleFonts.inter(
                  fontSize: 13, color: Colors.grey[600], height: 1.5)),
          const SizedBox(height: 12),
          Text("PIN: ${adr.pincode}",
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.business_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                  adr.addressType.isNotEmpty
                      ? adr.addressType[0].toUpperCase() +
                          adr.addressType.substring(1).toLowerCase()
                      : "Address Type",
                  style:
                      GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  OrderDeliveryEntity? _resolveEffectiveDelivery(
      OrderDetailsResponseEntity order) {
    if (order.deliveries.isNotEmpty) {
      return order.deliveries.first;
    }
    return null;
  }

  Widget _buildDeliverySection(
      OrderDetailsState state, OrderDetailsResponseEntity order) {
    final status = order.orderStatus.trim().toLowerCase();
    if (status == 'confirmed') {
      return _buildDeliveryAssignmentSection(state, order);
    }

    final delivery = _resolveEffectiveDelivery(order);
    if (delivery != null) {
      return _buildAssignedDeliveryPartnerSection(delivery, order.orderStatus);
    }

    return const SizedBox.shrink();
  }

  Widget _buildAssignedDeliveryPartnerSection(
      OrderDeliveryEntity delivery, String rawStatus) {
    String formattedAssignedDate = '';
    if (delivery.deliveryAssignedAt != null) {
      formattedAssignedDate = DateFormat('d MMM yyyy, hh:mm a')
          .format(delivery.deliveryAssignedAt!.toLocal());
    }

    final partner = delivery.deliveryPartnerDetails;
    final partnerName =
        partner?.name.isNotEmpty == true ? partner!.name : 'Delivery Partner';
    final initialLetter =
        partnerName.isNotEmpty ? partnerName[0].toUpperCase() : 'D';
    final vehicleNumber =
        partner?.vehicleNumber.isNotEmpty == true ? partner!.vehicleNumber : '';
    final phone = partner?.phone.isNotEmpty == true ? partner!.phone : '';
    final email = partner?.email.isNotEmpty == true ? partner!.email : '';
    // final otp =
    //     delivery.deliveryOtp.isNotEmpty == true ? delivery.deliveryOtp : '';

    final isVendor = delivery.deliveryPartnerType.toLowerCase() == 'vendor' ||
        delivery.deliveryPartner.toLowerCase() == 'self' ||
        delivery.deliveryPartner.toLowerCase() == 'vendor';

    final badgeText = isVendor ? "Our Deliveryman" : "Medicompares Partner";
    final badgeBg =
        isVendor ? const Color(0xFFECFDF5) : const Color(0xFFEFF6FF);
    final badgeBorder =
        isVendor ? const Color(0xFFA7F3D0) : const Color(0xFFBFDBFE);
    final badgeColor =
        isVendor ? const Color(0xFF059669) : const Color(0xFF2563EB);

    return _buildCard(
      title: "Assigned Delivery Partner",
      icon: Icons.local_shipping_outlined,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: badgeBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: badgeBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              badgeText,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: badgeColor,
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
                    if (vehicleNumber.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Vehicle: $vehicleNumber",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // if (otp.isNotEmpty)
              //   Container(
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              //     decoration: BoxDecoration(
              //       color: const Color(0xFFFFFBEB),
              //       borderRadius: BorderRadius.circular(8),
              //       border: Border.all(color: const Color(0xFFFDE68A)),
              //     ),
              //     child: Column(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Text(
              //           "DELIVERY OTP",
              //           style: GoogleFonts.inter(
              //             fontSize: 9,
              //             fontWeight: FontWeight.w700,
              //             color: const Color(0xFFD97706),
              //             letterSpacing: 0.5,
              //           ),
              //         ),
              //         const SizedBox(height: 2),
              //         Text(
              //           otp,
              //           style: GoogleFonts.inter(
              //             fontSize: 15,
              //             fontWeight: FontWeight.bold,
              //             color: const Color(0xFFB45309),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
            ],
          ),
          if (phone.isNotEmpty || email.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                if (phone.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
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
                if (phone.isNotEmpty && email.isNotEmpty)
                  const SizedBox(width: 12),
                if (email.isNotEmpty)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 9),
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
          ],
          if (formattedAssignedDate.isNotEmpty) ...[
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
                        context.read<OrderDetailsBloc>().add(
                              AssignOrderDeliveryPartnerEvent(
                                orderId: order.id,
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
                          context.read<OrderDetailsBloc>().add(
                                AssignOrderDeliveryPartnerEvent(
                                  orderId: order.id,
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
            ] else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Text(
                    "No internal delivery personnel configured for this vendor.",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: titleWidget ??
                Row(
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        title ?? "",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (trailing != null) trailing,
                  ],
                ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildOtpVerificationSection(OrderDetailsResponseEntity details) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 2), // Red outline
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.vpn_key_outlined,
                    color: Color(0xFFD97706),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "OTP Verification Required",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Please enter the OTP provided by the customer to verify or complete this order.",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.key_outlined,
                          size: 20, color: Colors.grey),
                      hintText: "Enter OTP (e.g. 1234)",
                      hintStyle:
                          GoogleFonts.inter(fontSize: 13, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_otpController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter OTP"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    // Handle OTP verify logic here if needed via BLoC
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Verify",
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AcceptOrderDialog extends StatefulWidget {
  final OrderDetailsResponseEntity orderDetails;
  final Function(String status, {String? rejectionReason}) onAccept;

  const _AcceptOrderDialog({
    Key? key,
    required this.orderDetails,
    required this.onAccept,
  }) : super(key: key);

  @override
  State<_AcceptOrderDialog> createState() => _AcceptOrderDialogState();
}

class _AcceptOrderDialogState extends State<_AcceptOrderDialog> {
  final TextEditingController _remarksController = TextEditingController();
  final Map<String, TextEditingController> _qtyControllers = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.orderDetails.items) {
      _qtyControllers[item.orderItemId] = TextEditingController(text: item.quantity.toString());
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    for (var c in _qtyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.orderDetails.userDetails;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      child: Container(
        width: 500, // max width for tablet/desktop, on mobile it shrinks
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: const Icon(Icons.inventory_2_rounded, color: Color(0xFFD97706), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Stock Verification & Acceptance",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Order #${widget.orderDetails.orderId.isNotEmpty ? widget.orderDetails.orderId : widget.orderDetails.id}",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8)),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Warning Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, color: Color(0xFFB45309), size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Stock Availability Warning & Requirement",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Do you have complete stock available for all booked items in this order?",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF78350F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Accepting confirms that you have verified inventory and can fulfill all requested items. If you are unsure or need clarification, you can call the customer directly before confirming.",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF92400E),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Customer Contact
                    if (user != null)
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAFAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF3E8FF)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.person_outline, color: Color(0xFF7C3AED), size: 18),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "CUSTOMER CONTACT DETAILS",
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF7C3AED),
                                              letterSpacing: 0.5,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "${user.firstName} ${user.lastName}",
                                      textAlign: TextAlign.right,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF475569),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD1FAE5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.phone_in_talk, color: Color(0xFF059669), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.phone,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1E293B),
                                          ),
                                        ),
                                        Text(
                                          "Registered Mobile",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Action to call customer
                                    },
                                    icon: const Icon(Icons.call, size: 14),
                                    label: const Text("Call"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF059669),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    if (user != null) const SizedBox(height: 24),
                    
                    // Booked Items Header
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Booked Items & Negotiated Deliverable Stock:",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Adjust qty if negotiated with user",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Items List
                    ...widget.orderDetails.items.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "${widget.orderDetails.items.indexOf(item) + 1}. ${item.productDetails.name}",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1E293B),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      "Booked Qty: ${item.quantity}",
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Deliverable Stock Quantity:",
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF6B21A8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 70,
                                        child: TextField(
                                          controller: _qtyControllers[item.orderItemId],
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0F172A),
                                          ),
                                          decoration: InputDecoration(
                                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: Color(0xFFD8B4FE)),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(color: Color(0xFF7C3AED)),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFFAFAFC),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "units",
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: const Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 8),
                    
                    // Remarks
                    Text(
                      "Negotiation Notes / Remarks (Optional):",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _remarksController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "e.g. Spoke with customer over phone and agreed to deliver partial stock of 2 units...",
                        hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onAccept('confirmed', rejectionReason: _remarksController.text.trim());
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(
                        "Confirm & Accept",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
