import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
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
  @override
  void initState() {
    super.initState();
    context
        .read<OrderDetailsBloc>()
        .add(GetOrderDetailsEvent(widget.orderId, orderType: 'rental'));
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              " Rental Order Details",
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
      ),
      body: BlocConsumer<OrderDetailsBloc, OrderDetailsState>(
        listener: (context, state) {
          if (state is OrderDetailsError) {
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
                  _buildRentalOrderItemsSection(orderDetails),
                  const SizedBox(height: 16),
                  _buildOrderSummarySection(orderDetails),
                ],
              );

              final rightColumn = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCustomerInformationSection(orderDetails),
                  const SizedBox(height: 16),
                  _buildShippingAddressSection(),
                  const SizedBox(height: 16),
                  _buildBillingAddressSection(),
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
                          leftColumn,
                          const SizedBox(height: 16),
                          rightColumn,
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

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(16),
      child: title.isEmpty
          ? Container()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
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

    // API returns a single object for rentals, handled as the first item in the list
    final item = orderDetails.items.first;

    final product = item.productDetails;
    final rentalDetails = item.rentalDetails;
    final productName =
        (product.tabletDetails != null && product.tabletDetails is Map)
            ? (product.tabletDetails['name'] ?? product.name)
            : product.name;

    final snapshotImageUrls = rentalDetails?.productSnapshot?.imageUrl ?? [];

    // Fallback to product.files if snapshot imageUrl is empty
    final imageUrl =
        snapshotImageUrls.isNotEmpty ? snapshotImageUrls.first : '';

    final perDayPrice = item.price;
    final quantity = item.quantity;

    return _buildCard(
      title: "Item Details",
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
                      Text(
                        productName,
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _buildChip("ID: ${item.orderItemId}"),
                          //    _buildChip("Order: ${orderDetails.orderId}"),
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
                    Text("Rent per day",
                        style: GoogleFonts.inter(
                            fontSize: 11, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text("₹${perDayPrice.toStringAsFixed(0)}",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.primary)),
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
        color: Colors.blueGrey[50],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.blueGrey[700],
        ),
      ),
    );
  }

  Widget _buildOrderSummarySection(OrderDetailsResponseEntity orderDetails) {
    // We assume the first item represents the rental details for summary
    final firstItem =
        orderDetails.items.isNotEmpty ? orderDetails.items.first : null;
    final rentalDetails = firstItem?.rentalDetails;

    // Fallbacks if rental details are missing
    final totalDays = rentalDetails?.totalDays ?? 1;
    final basePrice = rentalDetails?.basePricePerDay ?? 0.0;
    final subtotal = basePrice * totalDays;

    final serviceCharges = rentalDetails?.serviceCharges ?? 0.0;
    final returnCharges = rentalDetails?.returnCharges ?? 0.0;
    final deposit = rentalDetails?.deposit ?? 0.0;
    final adminCommission = firstItem?.vendorCommissionAmount ?? 600.0;

    final gst = orderDetails.billingSummary.gstAmount;
    final totalRentalValue =
        subtotal + serviceCharges + returnCharges + deposit;
    final totalEarned = totalRentalValue - adminCommission;
    final installamount = orderDetails.billingSummary.paidAmount;

    return _buildCard(
      title: "Order Summary",
      child: Column(
        children: [
          _buildSummaryRow("Subtotal (Inclusive of All Taxes)",
              "₹ ${subtotal.toStringAsFixed(0)} ($basePrice x $totalDays days)"),
          const SizedBox(height: 12),
          _buildSummaryRow("GST", "₹ ${gst.toStringAsFixed(0)}"),
          const SizedBox(height: 12),
          _buildSummaryRow(
              "Service Charges", "₹ ${serviceCharges.toStringAsFixed(0)}"),
          const SizedBox(height: 12),
          _buildSummaryRow(
              "Return Charges", "₹ ${returnCharges.toStringAsFixed(0)}"),
          const SizedBox(height: 12),
          _buildSummaryRow(
              "Deposit (Returnable)", "₹ ${deposit.toStringAsFixed(0)}"),
          const SizedBox(height: 12),
          _buildSummaryRow(
              "Admin Commission", "- ₹ ${adminCommission.toStringAsFixed(0)}",
              valueColor: Colors.red, labelColor: Colors.red),
          const Divider(height: 32),
          _buildSummaryRow(
              "Total Rental Value", "₹ ${totalRentalValue.toStringAsFixed(0)}",
              isBold: true),
          const SizedBox(height: 16),
          _buildSummaryRow(
              "Total Earned", "₹ ${totalEarned.toStringAsFixed(0)}",
              isBold: true, valueColor: AppColors.primary),
          const Divider(height: 32),
          _buildSummaryRow(
              "1st Installment Amount", "₹ ${installamount.toStringAsFixed(0)}",
              isBold: true, valueColor: AppColors.primary),
          const SizedBox(height: 16),
          _buildSummaryRow(
              "Payment Method: ${rentalDetails?.paymentType ?? 'Online'}", "",
              isBold: false, labelSize: 11),
          const SizedBox(height: 8),
          _buildSummaryRow("Payment Type: Onetimepayment", "",
              isBold: false, labelSize: 11),
          const SizedBox(height: 8),
          _buildSummaryRow(
              "Rental Plan: ${rentalDetails?.rentalPlan ?? 'Monthly'}", "",
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
              Text(
                user != null ? "${user.firstName} ${user.lastName}" : "Unknown",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, fontSize: 13),
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
