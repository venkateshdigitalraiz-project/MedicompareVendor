import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../domain/entities/ambulance_order_entity.dart';

class AmbulanceOrderDetailsPage extends StatelessWidget {
  final AmbulanceOrderEntity order;
  const AmbulanceOrderDetailsPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final customer = order.customer;
    final product = order.product;
    final statusColor = _statusColor(order.bookingStatus);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      body: CustomScrollView(
        slivers: [
          // ── Gradient AppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3730A3), Color(0xFF6366F1)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(56, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.bookingId,
                                    style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today,
                                          size: 11, color: Colors.white70),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('MMM d, yyyy • hh:mm a')
                                            .format(order.createdAt),
                                        style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _statusChip(order.bookingStatus, statusColor),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Quick stats strip ──────────────────────────────
                  _statsStrip(order),
                  const SizedBox(height: 14),

                  // ── Ambulance Details ──────────────────────────────
                  if (product != null) ...[
                    _sectionCard(
                      icon: Icons.airport_shuttle_rounded,
                      iconColor: AppColors.primaryDark,
                      title: 'Ambulance Details',
                      child: _buildAmbulanceDetails(order, product),
                    ),
                    const SizedBox(height: 14),
                  ],
                  // ── Fare Summary ───────────────────────────────────
                  _sectionCard(
                    icon: Icons.receipt_long_outlined,
                    iconColor: Colors.green,
                    title: 'Fare Summary',
                    child: _buildFareSummary(order),
                  ),
                  const SizedBox(height: 14),
                  // ── Patient Info ───────────────────────────────────
                  if (customer != null) ...[
                    _sectionCard(
                      icon: Icons.person_outline_rounded,
                      iconColor: const Color(0xFF0EA5E9),
                      title: 'Patient Info',
                      child: _buildPatientInfo(customer),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Trip Details ───────────────────────────────────
                  _sectionCard(
                    icon: Icons.map_outlined,
                    iconColor: Colors.deepOrange,
                    title: 'Trip Details',
                    child: _buildTripDetails(order),
                  ),
                  const SizedBox(height: 14),

                  // ── Business Contact ───────────────────────────────
                  if (product?.businessName != null) ...[
                    _sectionCard(
                      icon: Icons.business_outlined,
                      iconColor: Colors.purple,
                      title: 'Business Contact',
                      child: _buildBusinessContact(product!),
                    ),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick stats strip ────────────────────────────────────────────────
  Widget _statsStrip(AmbulanceOrderEntity order) {
    return Row(
      children: [
        _statBox(
          icon: Icons.straighten,
          label: 'Distance',
          value: '${order.distance.toStringAsFixed(0)} km',
          color: const Color(0xFF6366F1),
        ),
        const SizedBox(width: 10),
        _statBox(
          icon: Icons.currency_rupee,
          label: 'Fare',
          value: order.fare.toRupeeFormat(),
          color: Colors.green,
        ),
        const SizedBox(width: 10),
        _statBox(
          icon: Icons.emergency_outlined,
          label: 'Type',
          value: _capitalize(
              order.emergencyType.replaceAll('nonemergency', 'Non-Emergency')),
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _statBox(
      {required IconData icon,
      required String label,
      required String value,
      required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold, fontSize: 12, color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label,
                style:
                    GoogleFonts.poppins(fontSize: 10, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  // ── Ambulance Details ────────────────────────────────────────────────
  Widget _buildAmbulanceDetails(
      AmbulanceOrderEntity order, AmbulanceOrderProductDetail product) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: product.imageUrl != null
              ? Image.network(product.imageUrl!,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _ambulancePlaceholder())
              : _ambulancePlaceholder(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.serviceName,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF1E1B4B))),
              const SizedBox(height: 4),
              Text(
                "Type: ${order.emergencyType.isNotEmpty ? order.emergencyType[0].toUpperCase() + order.emergencyType.substring(1) : 'N/A'}",
                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              if (product.businessName != null)
                Row(children: [
                  Icon(Icons.business_center_outlined,
                      size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                      child: Text(product.businessName!,
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey[600]))),
                ]),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(product.discountPrice.toRupeeFormat(),
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryDark)),
      ],
    );
  }

  // ── Patient Info ─────────────────────────────────────────────────────
  Widget _buildPatientInfo(AmbulanceOrderUser customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: const Color(0xFFE0E7FF),
              backgroundImage: customer.profileImage != null
                  ? NetworkImage(customer.profileImage!) as ImageProvider
                  : null,
              child: customer.profileImage == null
                  ? const Icon(Icons.person,
                      color: AppColors.primaryDark, size: 26)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(customer.fullName,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: const Color(0xFF1E1B4B))),
                  if (customer.age != null || customer.gender != null)
                    Text(
                      [
                        if (customer.age != null) 'Age: ${customer.age}',
                        if (customer.gender != null)
                          _capitalize(customer.gender!),
                      ].join(' • '),
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _contactTile(
            Icons.phone_outlined, customer.phone, const Color(0xFF0EA5E9)),
        const SizedBox(height: 8),
        _contactTile(Icons.email_outlined, customer.email, Colors.purple),
        if (customer.medicalConditions != null &&
            customer.medicalConditions!.isNotEmpty &&
            customer.medicalConditions!.toLowerCase() != 'null') ...[
          const SizedBox(height: 12),
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
                Row(children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.red, size: 14),
                  const SizedBox(width: 4),
                  Text('MEDICAL CONDITIONS',
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          letterSpacing: 0.4)),
                ]),
                const SizedBox(height: 4),
                Text(customer.medicalConditions!,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.red[800])),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Trip Details ─────────────────────────────────────────────────────
  Widget _buildTripDetails(AmbulanceOrderEntity order) {
    return Column(
      children: [
        _tripStop(
          dotColor: Colors.green,
          label: 'PICKUP',
          address: order.pickupLocation.address,
          isFirst: true,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 11),
          child: Row(
            children: [
              Container(width: 2, height: 30, color: Colors.grey[300]),
            ],
          ),
        ),
        _tripStop(
          dotColor: Colors.red,
          label: 'DROPOFF',
          address: order.dropoffLocation.address,
          isFirst: false,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6FF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(Icons.social_distance_outlined,
                  size: 18, color: AppColors.primaryDark),
              const SizedBox(width: 8),
              Text('Total Distance: ',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.grey[600])),
              Text('${order.distance.toStringAsFixed(0)} km',
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Fare Summary ─────────────────────────────────────────────────────
  Widget _buildFareSummary(AmbulanceOrderEntity order) {
    final isPaid = order.paymentStatus == 'paid';
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Payment Status',
                style:
                    GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
            _pill(_capitalize(order.paymentStatus),
                isPaid ? Colors.green : Colors.orange),
          ],
        ),
        const SizedBox(height: 10),
        _fareRow('Base Fare', order.fare.toRupeeFormat()),
        if (order.gst > 0) ...[
          const SizedBox(height: 6),
          _fareRow('GST', order.gst.toRupeeFormat()),
        ],
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1),
        ),
        _fareRow(
          'Total Fare',
          (order.totalFare > 0 ? order.totalFare : order.fare).toRupeeFormat(),
          isBold: true,
          valueColor: AppColors.primaryDark,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      order.paymentMethod == 'cod'
                          ? Icons.money_outlined
                          : Icons.credit_card_outlined,
                      size: 18,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.paymentMethod == 'cod'
                          ? 'Cash on Delivery'
                          : 'Online Payment',
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1E1B4B)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Business Contact ─────────────────────────────────────────────────
  Widget _buildBusinessContact(AmbulanceOrderProductDetail product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(product.businessName ?? '',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: const Color(0xFF1E1B4B))),
        const SizedBox(height: 12),
        if (product.businessPhone != null)
          _contactTile(
              Icons.phone_outlined, product.businessPhone!, Colors.green),
        if (product.businessEmail != null) ...[
          const SizedBox(height: 8),
          _contactTile(
              Icons.email_outlined, product.businessEmail!, Colors.purple),
        ],
        if (product.businessAddress != null) ...[
          const SizedBox(height: 8),
          _contactTile(
              Icons.location_on_outlined, product.businessAddress!, Colors.red),
        ],
      ],
    );
  }

  // ── Reusable Widgets ─────────────────────────────────────────────────

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF1E1B4B))),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F0F5)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _tripStop(
      {required Color dotColor,
      required String label,
      required String address,
      required bool isFirst}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: dotColor.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: dotColor, width: 2),
              ),
              child: Center(
                  child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: dotColor, shape: BoxShape.circle))),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(address,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: const Color(0xFF1E1B4B),
                        height: 1.4)),
              ],
            ),
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
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(text,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: const Color(0xFF374151))),
          ),
        ),
      ],
    );
  }

  Widget _fareRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600])),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _statusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
      ),
      child: Text(
        _capitalize(status),
        style: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _ambulancePlaceholder() => Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.airport_shuttle_rounded,
            color: AppColors.primaryDark, size: 32),
      );

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.blue;
      case 'intransit':
        return Colors.indigo;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
