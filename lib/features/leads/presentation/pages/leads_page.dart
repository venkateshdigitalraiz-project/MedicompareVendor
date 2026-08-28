import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/utils/price_formatter.dart';
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
  int _totalPages = 1;
  bool _isFetchingMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isFetchingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_currentPage < _totalPages) {
        setState(() {
          _currentPage++;
          _isFetchingMore = true;
        });
        context.read<LeadsBloc>().add(GetLeadsEvent(
              page: _currentPage,
              limit: 10,
              search: _searchQuery,
              leadStage: _selectedStage,
              isLoadMore: true,
            ));
      }
    }
  }

  final List<Map<String, String>> _statusFilters = [
    {'label': 'All Status', 'value': ''},
    {'label': 'Pending', 'value': 'pending'},
    {'label': 'Approved', 'value': 'accepted'},
    {'label': 'Rejected', 'value': 'rejected'},
  ];

  final List<Map<String, String>> _statusOptions = [
    {'label': 'Pending', 'value': 'pending'},
    {'label': 'Approved', 'value': 'accepted'},
    {'label': 'Rejected', 'value': 'rejected'},
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
            child: BlocListener<LeadsBloc, LeadsState>(
              listener: (context, state) {
                if (state is UpdateLeadStatusSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else if (state is LeadsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: BlocBuilder<LeadsBloc, LeadsState>(
                builder: (context, state) {
                  if (state is LeadsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is LeadsLoaded) {
                    _totalPages = state.leadsList.pagination.totalPages;
                    _isFetchingMore = state.isLoadingMore;
                    return _buildLeadsList(
                        state.leadsList.leads, state.isLoadingMore);
                  } else if (state is LeadDetailsLoaded) {
                    // This state is shared, we might need a better way to handle
                    // list view when details are loaded if navigation doesn't happen
                    return const SizedBox.shrink();
                  }
                  return const Center(child: Text('No leads found.'));
                },
              ),
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
                    hintText: "Search by customer name...",
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
                  items: _statusFilters.map((s) => s['value']!).toList(),
                  labels: _statusFilters.map((s) => s['label']!).toList(),
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
    // Reset pagination and scroll when filter changes
    setState(() {
      _currentPage = 1;
      _isFetchingMore = false;
    });
    // Scroll to top to avoid showing old items while loading new ones
    _scrollController.jumpTo(0);
    // For status filtering we use only the leadStage parameter.
    // The API expects `leadStage` to filter leads; `status` is left empty.
    context.read<LeadsBloc>().add(GetLeadsEvent(
          status: '', // leave status empty
          leadStage: _selectedStage,
          search: _searchQuery,
          page: _currentPage,
          limit: 10,
          isLoadMore: false,
        ));
  }

  Widget _buildLeadsList(List<LeadEntity> leads, bool isLoadingMore) {
    if (leads.isEmpty) {
      return const Center(child: Text("No leads matching filters."));
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: leads.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == leads.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final lead = leads[index];
        return _buildLeadCard(lead);
      },
    );
  }

  Widget _buildLeadCard(LeadEntity lead) {
    final bool isAccepted = lead.vendorPermission.toLowerCase() == 'accepted';

    return GestureDetector(
      onTap: () {
        if (isAccepted) {
          context.push('/lead-details/${lead.id}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Only accepted leads can be viewed in detail.")),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isAccepted
                    ? Colors.green.withOpacity(0.05)
                    : Colors.orange.withOpacity(0.05),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: isAccepted
                              ? Colors.green[200]!
                              : Colors.orange[200]!),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color:
                          isAccepted ? Colors.green[600] : Colors.orange[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.name,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lead.phone,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusDropdown(lead),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildBeautifulInfoItem(
                          label: "Service",
                          value: lead.serviceName,
                          icon: Icons.medical_services_outlined,
                          color: AppColors.primary,
                          subvalue: lead.serviceType,
                        ),
                      ),
                      Expanded(
                        child: _buildBeautifulInfoItem(
                          label: "Posted On",
                          value: DateFormat('MMM d, yyyy')
                              .format(lead.createdAt.toLocal()),
                          icon: Icons.calendar_today_outlined,
                          color: Colors.blue,
                          subvalue: '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              "Age: ${lead.age} years",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey[700],
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.currency_rupee,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              "Price: ${lead.price.toRupeeFormat()}",
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.grey[700],
                                height: 1.3,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildBeautifulInfoItem(
      {required String label,
      required String value,
      required IconData icon,
      required String subvalue,
      required Color color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[500],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subvalue.isEmpty
                  ? Container()
                  : Text(
                      subvalue,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 0.5,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(LeadEntity lead) {
    final String currentStatus = lead.vendorPermission.toLowerCase();

    Color getStatusColor(String status) {
      switch (status) {
        case 'accepted':
          return Colors.green;
        case 'rejected':
          return Colors.red;
        default:
          return Colors.orange;
      }
    }

    final Color color = getStatusColor(currentStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _statusOptions.any((s) => s['value'] == currentStatus)
              ? currentStatus
              : 'pending',
          icon: Icon(Icons.keyboard_arrow_down, size: 18, color: color),
          style: GoogleFonts.inter(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          borderRadius: BorderRadius.circular(12),
          items: _statusOptions.map((status) {
            return DropdownMenuItem(
              value: status['value'],
              child: Text(
                status['label']!.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null && newValue != currentStatus) {
              _showUpdateStatusDialog(lead, newValue);
            }
          },
        ),
      ),
    );
  }

  void _showUpdateStatusDialog(LeadEntity lead, String newStatus) {
    final String statusLabel =
        _statusOptions.firstWhere((s) => s['value'] == newStatus)['label']!;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Confirm Status Update",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "Are you sure you want to ${statusLabel.toLowerCase()} this lead? This action will notify the Admin about the status change.",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      "Cancel",
                      style: GoogleFonts.inter(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LeadsBloc>().add(
                            UpdateLeadStatusEvent(
                                id: lead.id, status: newStatus),
                          );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: newStatus == 'accepted'
                          ? Colors.green
                          : (newStatus == 'rejected'
                              ? Colors.red
                              : Colors.orange),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      "Confirm ${statusLabel.toLowerCase()}",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
