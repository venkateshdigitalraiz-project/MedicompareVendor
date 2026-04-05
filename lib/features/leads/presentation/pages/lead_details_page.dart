import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/lead_entity.dart';
import '../bloc/leads_bloc.dart';
import '../bloc/leads_event.dart';
import '../bloc/leads_state.dart';

class LeadDetailsPage extends StatefulWidget {
  final String leadId;

  const LeadDetailsPage({super.key, required this.leadId});

  @override
  State<LeadDetailsPage> createState() => _LeadDetailsPageState();
}

class _LeadDetailsPageState extends State<LeadDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<LeadsBloc>().add(GetLeadDetailsEvent(widget.leadId));
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
              "Lead Details",
              style: GoogleFonts.inter(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "Lead ID: ${widget.leadId.length > 20 ? widget.leadId.substring(0, 20) + "..." : widget.leadId}",
              style: GoogleFonts.inter(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: BlocBuilder<LeadsBloc, LeadsState>(
        builder: (context, state) {
          if (state is LeadsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LeadDetailsLoaded) {
            final lead = state.leadDetails;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBanner(lead),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                      "Personal Information", Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildPersonalInformationGrid(lead),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Information", Icons.info_outline),
                  const SizedBox(height: 12),
                  _buildExtraInformationGrid(lead),
                  const SizedBox(height: 32),
                ],
              ),
            );
          } else if (state is LeadsError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text("Preparing..."));
        },
      ),
    );
  }

  Widget _buildTopBanner(LeadDetailsEntity lead) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6), // Purple color from reference
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.person_outline, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildBannerBadge(lead.leadStage.toUpperCase()),
                    _buildBannerBadge(lead.leadSource),
                    _buildBannerBadge(lead.serviceType.toUpperCase()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF8B5CF6)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInformationGrid(LeadDetailsEntity lead) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _buildInfoCard(
                "Full Name", lead.name, Icons.person_outline, Colors.blue),
            _buildInfoCard(
                "Phone Number", lead.phone, Icons.phone_outlined, Colors.green),
            _buildInfoCard("Age", "${lead.age} years",
                Icons.calendar_today_outlined, Colors.orange),
            _buildInfoCard("Gender", lead.gender, Icons.person, Colors.teal),
            _buildInfoCard("Lead Type", lead.leadType,
                Icons.local_offer_outlined, Colors.indigo),
            _buildInfoCard("Vendor Assignment", lead.vendorAssigned,
                Icons.check_circle_outline, Colors.purple),
            _buildInfoCard("Vendor Permission", lead.vendorPermission,
                Icons.verified_user_outlined, Colors.blueAccent),
            if (lead.date != null)
              _buildInfoCard(
                  "Preferred Date",
                  DateFormat('MMM d, yyyy').format(lead.date!),
                  Icons.date_range_outlined,
                  AppColors.primary),
            if (lead.address != null && lead.address!.isNotEmpty)
              _buildInfoCard("Address", lead.address!,
                  Icons.location_on_outlined, Colors.amber),
          ],
        );
      },
    );
  }

  Widget _buildExtraInformationGrid(LeadDetailsEntity lead) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
          children: [
            _buildPriceCard(lead),
            _buildInfoCard("Service Name", lead.serviceName,
                Icons.medical_services_outlined, Colors.indigo),
            _buildInfoCard(
                "Duration", lead.duration, Icons.timer_outlined, Colors.blue),
          ],
        );
      },
    );
  }

  Widget _buildInfoCard(
      String title, String value, IconData icon, Color iconBgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconBgColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(LeadDetailsEntity lead) {
    final hasDiscount =
        lead.discountPrice > 0 && lead.discountPrice < lead.price;
    final finalPrice = hasDiscount ? lead.discountPrice : lead.price;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.currency_rupee, size: 16, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Pricing",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 4,
                  children: [
                    Text(
                      "₹${finalPrice.toStringAsFixed(2)}",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    if (hasDiscount)
                      Text(
                        "₹${lead.price.toStringAsFixed(2)}",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
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
}
