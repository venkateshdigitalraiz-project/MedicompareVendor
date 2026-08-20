import 'dart:developer';

import 'package:MediCompare/features/orders/domain/entities/order_details_response_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/order_entity.dart';
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
  String _selectedDeliveryPartner = 'medicompares';
  int _selectedParcelTime = 30;

  @override
  void initState() {
    super.initState();
    context
        .read<OrderDetailsBloc>()
        .add(GetOrderDetailsEvent(widget.orderId, orderType: widget.orderType));
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
                Text(
                  "ID: ${widget.orderId.length > 15 ? widget.orderId.substring(0, 15) + "..." : widget.orderId}",
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        // actions: [
        //   BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
        //     builder: (context, state) {
        //       if (state is OrderDetailsLoaded) {
        //         final orderDetails = state.orderDetails;
        //         final status = orderDetails.orderStatus.toLowerCase();
        //         if (status == 'new' || status == 'pending') {
        //           return Row(
        //             mainAxisSize: MainAxisSize.min,
        //             children: [
        //               _buildCompactActionButton(
        //                   "Reject", Colors.red, () => _showRejectionDialog()),
        //               _buildCompactActionButton("Accept", AppColors.primary,
        //                   () => _handleUpdateStatus('confirmed')),
        //             ],
        //           );
        //         }
        //       }
        //       return const SizedBox.shrink();
        //     },
        //   ),
        //   const SizedBox(width: 8),
        // ],
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

              final leftColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildOrderItemsSection(orderDetails),
                  const SizedBox(height: 16),
                  _buildOrderSummarySection(orderDetails),
                ],
              );

              final rightColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCustomerInformationSection(orderDetails),
                  const SizedBox(height: 16),
                  // TODO: Shipping address isn't in OrderDetailsResponseEntity currently,
                  // skipping it or extracting if added.
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
                          _buildOrderItemsSection(orderDetails),
                          const SizedBox(height: 16),
                          _buildCustomerInformationSection(orderDetails),
                          const SizedBox(height: 16),
                          _buildOrderSummarySection(orderDetails),
                          const SizedBox(height: 16),
                          // _buildShippingAddressSection(orderDetails),
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
        "orderStatus": status,
        "status": status,
        "orderId": orderDetails.orderId,
        "productIds":
            orderDetails.items.map((item) => item.productDetails.id).toList(),
        "packageIds": [],
        "deliveryPartner": _selectedDeliveryPartner,
        "readyTime": _selectedParcelTime.toString(),
        "assignedPartnerId": null,
        if (rejectionReason != null) "rejectionReason": rejectionReason,
      };

      context.read<OrderDetailsBloc>().add(UpdateOrderStatusEvent(
            orderItemId: orderDetails.items.first.orderItemId,
            payload: payload,
          ));
    }
  }

  void _showRejectionDialog() {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Reject Order",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Please provide a reason for rejecting this order.",
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter rejection reason...",
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
              "Cancel",
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
                    content: Text("Please enter a reason for rejection"),
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
              "Reject",
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
          String? imageUrl;
          if (tablet != null) {
            if (tablet['imageUrl'] != null &&
                (tablet['imageUrl'] as List).isNotEmpty) {
              imageUrl = tablet['imageUrl'].first;
            } else if (tablet['files'] != null &&
                (tablet['files'] as List).isNotEmpty) {
              imageUrl = tablet['files'].first;
            }
          }
          log("imageUrl : $imageUrl");

          final gst = item.billingSummary.gstAmount;

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
                      child: imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(imageUrl, fit: BoxFit.cover))
                          : const Icon(Icons.image_outlined, color: Colors.grey),
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
                              if (tablet != null && tablet['variant'] != null)
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
                            "₹${item.vendorCommissionAmount.toStringAsFixed(2)}",
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
                        Text("₹${item.billingSummary.gstAmount.toStringAsFixed(2)}",
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
                            "₹${(item.billingSummary.finalAmount - item.billingSummary.gstAmount).toStringAsFixed(2)}",
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
                        "Customer ID: ${user.id.length > 10 ? user.id.substring(user.id.length - 10).toUpperCase() : user.id.toUpperCase()}",
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
    final gst = details.billingSummary.totalGst;
    final adminCommission = details.items
        .fold<double>(0.0, (sum, item) => sum + item.vendorCommissionAmount);
    final totalEarnings =
        details.billingSummary.subtotal - adminCommission; // Example formula

    return _buildCard(
      title: "Order Summary",
      child: Column(
        children: [
          _buildSummaryRow("Subtotal (Inclusive of all taxes)",
              "₹ ${details.subtotal.toStringAsFixed(2)}"),
          const SizedBox(height: 16),
          _buildSummaryRow("GST", "₹ ${gst.toStringAsFixed(2)}"),
          const SizedBox(height: 16),
          _buildSummaryRow(
              "Admin Commission", "- ₹${adminCommission.toStringAsFixed(2)}",
              valueColor: Colors.red, labelColor: Colors.red),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 16),
          _buildSummaryRow(
              "Total Earnings", "₹ ${totalEarnings.toStringAsFixed(2)}",
              isTotal: true),
          const SizedBox(height: 16),
          Row(
            children: [
              Text("Payment Method: ",
                  style:
                      GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
              Text("Online",
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

  Widget _buildShippingAddressSection(OrderItemEntity order) {
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

  Widget _buildCard(
      {String? title, Widget? titleWidget, required Widget child}) {
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
                Text(
                  title ?? "",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black87),
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
}
