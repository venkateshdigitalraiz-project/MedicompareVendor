import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../domain/entities/appointment_entity.dart';
import '../bloc/appointment_booking_bloc.dart';
import '../bloc/appointment_booking_event.dart';
import '../bloc/appointment_booking_state.dart';

class AppointmentBookingsPage extends StatefulWidget {
  const AppointmentBookingsPage({super.key});

  @override
  State<AppointmentBookingsPage> createState() =>
      _AppointmentBookingsPageState();
}

class _AppointmentBookingsPageState extends State<AppointmentBookingsPage> {
  String _searchQuery = '';
  String _selectedStatus = '';
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _statuses = [
    {'label': 'All Status', 'value': ''},
    {'label': 'Pending', 'value': 'pending'},
    {'label': 'Sample Collected', 'value': 'sample_collected'},
    {'label': 'Sample Not Collected', 'value': 'sample_not_collected'},
    {'label': 'Completed', 'value': 'completed'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<AppointmentBookingBloc>().state;
      if (state is AppointmentBookingLoaded && !state.isFetchingMore) {
        if (state.appointmentsList.pagination.page <
            state.appointmentsList.pagination.totalPages) {
          _currentPage++;
          context.read<AppointmentBookingBloc>().add(
                GetAppointmentBookingsEvent(
                  status: _selectedStatus,
                  search: _searchQuery,
                  page: _currentPage,
                  isLoadMore: true,
                ),
              );
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FF),
      appBar: const CustomHomeAppBar(
        title: "Appointment Bookings",
        subtitle: "Manage and track all your appointments",
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocBuilder<AppointmentBookingBloc, AppointmentBookingState>(
              builder: (context, state) {
                if (state is AppointmentBookingLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AppointmentBookingLoaded) {
                  return Column(
                    children: [
                      Expanded(
                          child: _buildAppointmentsList(
                              state.appointmentsList.appointmentItems,
                              state.isFetchingMore)),
                    ],
                  );
                } else if (state is AppointmentBookingError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text('No appointments found.'));
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
                    hintText: "Search appointments...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  value: _selectedStatus,
                  items: _statuses.map((s) => s['value']!).toList(),
                  labels: _statuses.map((s) => s['label']!).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedStatus = val!;
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
    context.read<AppointmentBookingBloc>().add(GetAppointmentBookingsEvent(
          status: _selectedStatus,
          search: _searchQuery,
          page: _currentPage,
        ));
  }

  Widget _buildAppointmentsList(
      List<AppointmentItemEntity> orders, bool isLoadingMore) {
    if (orders.isEmpty) {
      return const Center(child: Text("No appointments matching filters."));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: isLoadingMore ? orders.length + 1 : orders.length,
      itemBuilder: (context, index) {
        if (index < orders.length) {
          final order = orders[index];
          return _buildAppointmentCard(order);
        } else {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentItemEntity item) {
    final user = item.userDetails;

    return GestureDetector(
      onTap: () {
        context.push('/appointment-details/${item.id}').then((_) {
          _onFilterChanged(); // Refresh the list when coming back
        });
      },
      child: Container(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.orderItemId,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.productDetails.name.isNotEmpty
                              ? item.productDetails.name
                              : "Appointment Service",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          "Type: ${item.type}",
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(item.orderStatus),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.person_outline,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null
                              ? "${user.firstName} ${user.lastName}"
                              : "Unknown Customer",
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.email ?? "No Email",
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          user?.phone ?? "No Phone",
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Qty: ${item.quantity}",
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Text(
                        "₹${item.totalPrice.toStringAsFixed(2)}",
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, yyyy')
                                .format(item.createdAt.toLocal()),
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'new':
        color = Colors.orange;
        break;
      case 'delivered':
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
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
        status.toUpperCase(),
        style: GoogleFonts.inter(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
