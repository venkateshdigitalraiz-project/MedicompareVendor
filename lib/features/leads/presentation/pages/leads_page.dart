import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/lead_entity.dart';
import '../bloc/leads_bloc.dart';
import '../bloc/leads_event.dart';
import '../bloc/leads_state.dart';

class LeadsPage extends StatefulWidget {
  const LeadsPage({super.key});

  @override
  State<LeadsPage> createState() => _LeadsPageState();
}

class _LeadsPageState extends State<LeadsPage> {
  String _searchQuery = '';
  String _selectedStage = '';
  int _currentPage = 1;

  final List<Map<String, String>> _stages = [
    {'label': 'All Status', 'value': ''},
    {'label': 'New', 'value': 'new'},
    {'label': 'Contacted', 'value': 'contacted'},
    {'label': 'Qualified', 'value': 'qualified'},
    {'label': 'Converted', 'value': 'converted'},
    {'label': 'Lost', 'value': 'lost'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: const CustomHomeAppBar(
        title: "My Leads",
        subtitle: "Track and manage all your leads",
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocBuilder<LeadsBloc, LeadsState>(
              builder: (context, state) {
                if (state is LeadsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is LeadsLoaded) {
                  return Column(
                    children: [
                      Expanded(child: _buildLeadsList(state.leadsList.leads)),
                      _buildPaginationFooter(state.leadsList.pagination),
                    ],
                  );
                } else if (state is LeadsError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text('No leads found.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _currentPage = 1;
                    });
                    _onFilterChanged();
                  },
                  decoration: InputDecoration(
                    hintText: "Search by lead ID, customer name...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: _buildDropdown(
                  value: _selectedStage,
                  items: _stages.map((s) => s['value']!).toList(),
                  labels: _stages.map((s) => s['label']!).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedStage = val!;
                      _currentPage = 1;
                    });
                    _onFilterChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    List<String>? labels,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: List.generate(items.length, (index) {
            return DropdownMenuItem(
              value: items[index],
              child: Text(
                labels != null ? labels[index] : items[index],
                style: GoogleFonts.inter(fontSize: 14),
              ),
            );
          }),
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _onFilterChanged() {
    context.read<LeadsBloc>().add(GetLeadsEvent(
          leadStage: _selectedStage,
          search: _searchQuery,
          page: _currentPage,
        ));
  }

  Widget _buildPaginationFooter(LeadsPaginationEntity pagination) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: pagination.page > 1
                ? () {
                    setState(() => _currentPage--);
                    _onFilterChanged();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: const Text("Previous"),
          ),
          Text(
            "Page ${pagination.page} of ${pagination.totalPages}",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600),
          ),
          ElevatedButton(
            onPressed: pagination.page < pagination.totalPages
                ? () {
                    setState(() => _currentPage++);
                    _onFilterChanged();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: const Text("Next"),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadsList(List<LeadEntity> leads) {
    if (leads.isEmpty) {
      return const Center(child: Text("No leads matching filters."));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        return _buildLeadCard(lead);
      },
    );
  }

  Widget _buildLeadCard(LeadEntity lead) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.person_outline, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.name,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        lead.phone,
                        style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                _buildPermissionBadge(lead.vendorPermission),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: "SERVICE",
                    value: lead.serviceName,
                    icon: Icons.medical_services_outlined,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    label: "DATE",
                    value: DateFormat('MMM d, yyyy').format(lead.createdAt),
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (lead.address != null) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      lead.address!,
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({required String label, required String value, required IconData icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPermissionBadge(String permission) {
    Color color;
    switch (permission.toLowerCase()) {
      case 'accepted':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            permission.toLowerCase() == 'accepted' ? Icons.check : (permission.toLowerCase() == 'rejected' ? Icons.close : Icons.access_time),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            permission.toUpperCase(),
            style: GoogleFonts.inter(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
