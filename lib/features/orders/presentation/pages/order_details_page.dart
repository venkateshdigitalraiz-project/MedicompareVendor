import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';

class OrderDetailPage extends StatefulWidget {
  final String orderId;

  const OrderDetailPage({super.key, required this.orderId});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  String _selectedDeliveryPartner = 'medicompares'; // 'medicompares' or 'self'
  int _selectedParcelTime = 30; // 15, 30, 45, 60

  @override
  void initState() {
    super.initState();
    context.read<OrdersBloc>().add(GetOrderDetailsEvent(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Details",
              style: GoogleFonts.inter(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
        actions: [
          BlocBuilder<OrdersBloc, OrdersState>(
            builder: (context, state) {
              if (state is OrderDetailsLoaded) {
                final status = state.order.orderStatus.toLowerCase();
                if (status == 'new' || status == 'pending') {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCompactActionButton("Reject", Colors.red,
                          () => _handleUpdateStatus('cancelled')),
                      _buildCompactActionButton("Accept", AppColors.primary,
                          () => _handleUpdateStatus('confirmed')),
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
      body: BlocConsumer<OrdersBloc, OrdersState>(
        listener: (context, state) {
          if (state is OrderStatusUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
            context
                .read<OrdersBloc>()
                .add(GetOrderDetailsEvent(widget.orderId));
          } else if (state is OrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is OrdersLoading || state is OrderActionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrderDetailsLoaded) {
            final order = state.order;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusGrid(order),
                  const SizedBox(height: 16),
                  _buildDeliverySettings(),
                  const SizedBox(height: 16),
                  _buildOrderItems(order),
                  const SizedBox(height: 16),
                  _buildCustomerInformation(order),
                  const SizedBox(height: 16),
                  _buildAddressSection(order),
                  const SizedBox(height: 16),
                  _buildOrderSummary(order),
                  const SizedBox(height: 24),
                ],
              ),
            );
          } else if (state is OrdersError) {
            return Center(
                child:
                    Text(state.message, style: const TextStyle(fontSize: 12)));
          }
          return const Center(child: Text("Preparing details..."));
        },
      ),
    );
  }

  void _handleUpdateStatus(String status) {
    final state = context.read<OrdersBloc>().state;
    if (state is OrderDetailsLoaded) {
      final order = state.order;
      final payload = {
        "orderStatus": status,
        "status": status,
        "orderId": order.orderId,
        "productIds": [order.productId],
        "packageIds": [],
        "deliveryPartner": _selectedDeliveryPartner,
        "readyTime": _selectedParcelTime.toString(),
        "assignedPartnerId": null
      };

      context.read<OrdersBloc>().add(UpdateOrderStatusEvent(
            orderItemId: order.id,
            payload: payload,
          ));
    }
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

  Widget _buildStatusGrid(OrderItemEntity order) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.2,
      children: [
        _buildInfoCard(
          "Order Status",
          order.orderStatus.toUpperCase(),
          Icons.shopping_cart_outlined,
          Colors.purple,
          isStatus: true,
        ),
        _buildInfoCard(
          "Booking Type",
          order.bookingType.toUpperCase(),
          Icons.book_online_outlined,
          Colors.orange,
        ),
        _buildInfoCard(
          "Payment Status",
          order.paymentStatus.toUpperCase(),
          Icons.account_balance_wallet_outlined,
          Colors.green,
          isStatus: true,
          statusColor: order.paymentStatus.toLowerCase() == 'unpaid'
              ? Colors.red
              : Colors.green,
        ),
        _buildInfoCard(
          "Order Date",
          DateFormat('MMM d, hh:mm a').format(order.createdAt),
          Icons.calendar_today_outlined,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color,
      {bool isStatus = false, Color? statusColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style:
                      GoogleFonts.inter(fontSize: 9, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (statusColor ?? color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: statusColor ?? color,
                ),
              ),
            )
          else
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildDeliverySettings() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                "Prefer Delivery Partner",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildVerticalDeliveryOption(
            id: 'medicompares',
            title: "Medicompares Delivery",
            subtitle: "Fast & reliable logistics",
            icon: Icons.local_shipping,
          ),
          const SizedBox(height: 8),
          _buildVerticalDeliveryOption(
            id: 'self',
            title: "Self Delivery",
            subtitle: "Manage your own transport",
            icon: Icons.person_outline,
          ),
          if (_selectedDeliveryPartner == 'medicompares') ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Parcel Ready Time",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Select when the parcel will be ready for pickup.",
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [15, 30, 45, 60].map((time) {
                final isSelected = _selectedParcelTime == time;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: InkWell(
                      onTap: () => setState(() => _selectedParcelTime = time),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.grey[200]!),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "$time Mins",
                          style: GoogleFonts.inter(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerticalDeliveryOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedDeliveryPartner == id;
    return InkWell(
      onTap: () => setState(() => _selectedDeliveryPartner = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[200]!,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Radio<String>(
                value: id,
                groupValue: _selectedDeliveryPartner,
                onChanged: (val) =>
                    setState(() => _selectedDeliveryPartner = val!),
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(icon, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(OrderItemEntity order) {
    final product = order.productDetails;
    final tablet = product.tabletDetails;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Items (${order.quantity})",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.image_outlined,
                      color: Colors.grey, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tablet != null
                            ? tablet['name'] ?? product.name
                            : product.name,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "ID: ${order.orderItemId}",
                        style:
                            GoogleFonts.inter(fontSize: 9, color: Colors.grey),
                      ),
                      Text(
                        "${order.type.toUpperCase()} • ${order.bookingType.toUpperCase()}",
                        style: GoogleFonts.inter(
                            fontSize: 9, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Qty: ${order.quantity}",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₹${order.discountPrice.toStringAsFixed(2)}",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 14,
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
  }

  Widget _buildCustomerInformation(OrderItemEntity order) {
    final user = order.userDetails;
    if (user == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Customer Information",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: const Icon(Icons.person,
                    color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${user.firstName} ${user.lastName}",
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    Text(
                      user.email,
                      style: GoogleFonts.inter(
                          fontSize: 10, color: Colors.grey[600]),
                    ),
                    Text(
                      user.phone,
                      style: GoogleFonts.inter(
                          fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniInfoBox("Age", "${user.age} yrs"),
              const SizedBox(width: 8),
              _buildMiniInfoBox("Gender", user.gender),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMiniInfoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("$label: ",
              style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[600])),
          Text(value,
              style:
                  GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAddressSection(OrderItemEntity order) {
    return Column(
      children: [
        _buildCompactAddressCard("Shipping Address",
            order.shippingAddressDetails, Icons.local_shipping_outlined),
        const SizedBox(height: 8),
        _buildCompactAddressCard("Billing Address", order.billingAddressDetails,
            Icons.receipt_long_outlined),
      ],
    );
  }

  Widget _buildCompactAddressCard(
      String title, AddressDetailsEntity? adr, IconData icon) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (adr != null) ...[
            Text("${adr.houseNo}, ${adr.area}",
                style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w500)),
            if (adr.landmark.isNotEmpty)
              Text("Landmark: ${adr.landmark}",
                  style:
                      GoogleFonts.inter(fontSize: 10, color: Colors.grey[600])),
            Text(adr.fullAddress,
                style:
                    GoogleFonts.inter(fontSize: 10, color: Colors.grey[600])),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    adr.addressType.toUpperCase(),
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(width: 8),
                Text("Pincode: ${adr.pincode}",
                    style: GoogleFonts.inter(
                        fontSize: 10, color: Colors.grey[700])),
              ],
            ),
          ] else
            const Text("Not available",
                style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(OrderItemEntity order) {
    final details = order.orderDetails;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Summary",
            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _buildCompactSummaryRow("Subtotal", details.subtotal),
          _buildCompactSummaryRow("Shipping", details.shipping),
          _buildCompactSummaryRow("Discount", -details.discount,
              isDiscount: true),
          _buildCompactSummaryRow("CGST", details.cgst),
          _buildCompactSummaryRow("SGST", details.sgst),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                "₹${details.total.toStringAsFixed(2)}",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.payment_outlined, size: 12, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                "Payment: ${details.paymentMethod.toUpperCase()}",
                style: GoogleFonts.inter(
                    fontSize: 9,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSummaryRow(String label, double amount,
      {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 11)),
          Text(
            "${amount < 0 ? '-' : ''} ₹${amount.abs().toStringAsFixed(2)}",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: isDiscount ? Colors.green : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
