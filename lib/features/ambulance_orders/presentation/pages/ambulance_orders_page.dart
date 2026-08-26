import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/ambulance_orders_bloc.dart';
import '../bloc/ambulance_orders_event.dart';
import '../bloc/ambulance_orders_state.dart';
import '../../domain/entities/ambulance_order_entity.dart';

class AmbulanceOrdersPage extends StatefulWidget {
  const AmbulanceOrdersPage({super.key});

  @override
  State<AmbulanceOrdersPage> createState() => _AmbulanceOrdersPageState();
}

class _AmbulanceOrdersPageState extends State<AmbulanceOrdersPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  AmbulanceOrdersLoaded? _cachedState;

  String _selectedStatus = '';
  final List<Map<String, String>> _statusOptions = [
    {'label': 'All Status', 'value': ''},
    {'label': 'Pending', 'value': 'pending'},
    {'label': 'Confirmed', 'value': 'confirmed'},
    {'label': 'In Transit', 'value': 'intransit'},
    {'label': 'Completed', 'value': 'completed'},
    {'label': 'Cancelled', 'value': 'cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<AmbulanceOrdersBloc>().add(const LoadAmbulanceOrdersEvent());
  }

  void _onScroll() {
    final cached = _cachedState;
    if (cached == null || cached.isLoadingMore) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (cached.data.page < cached.data.totalPages) {
        context.read<AmbulanceOrdersBloc>().add(LoadAmbulanceOrdersEvent(
              page: cached.data.page + 1,
              status: _selectedStatus,
              search: _searchController.text,
              isLoadMore: true,
            ));
      }
    }
  }

  void _reload() {
    context.read<AmbulanceOrdersBloc>().add(LoadAmbulanceOrdersEvent(
          status: _selectedStatus,
          search: _searchController.text,
        ));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Ambulance Orders',
          style: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: BlocBuilder<AmbulanceOrdersBloc, AmbulanceOrdersState>(
        builder: (context, state) {
          if (state is AmbulanceOrdersLoaded) {
            _cachedState = state;
          }
          if (state is AmbulanceOrdersLoading && _cachedState == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AmbulanceOrdersError && _cachedState == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                      onPressed: _reload, child: const Text('Retry')),
                ],
              ),
            );
          }
          final displayState = _cachedState;
          if (displayState == null)
            return const Center(child: CircularProgressIndicator());

          return Column(
            children: [
              _buildFilters(),
              Expanded(
                child: displayState.data.orders.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        onRefresh: () async => _reload(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          itemCount: displayState.isLoadingMore
                              ? displayState.data.orders.length + 1
                              : displayState.data.orders.length,
                          itemBuilder: (_, index) {
                            if (index >= displayState.data.orders.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2)),
                              );
                            }
                            return _buildOrderCard(
                                displayState.data.orders[index]);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _reload(),
              style: GoogleFonts.inter(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Search by ID, customer...',
                hintStyle:
                    GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
                prefixIcon:
                    Icon(Icons.search, size: 18, color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFFF8FAFF),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: AppColors.primaryDark, width: 1.5)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatus,
                style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                borderRadius: BorderRadius.circular(10),
                dropdownColor: Colors.white,
                items: _statusOptions
                    .map((s) => DropdownMenuItem(
                          value: s['value'],
                          child: Text(s['label']!,
                              style: GoogleFonts.inter(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedStatus = val);
                    _reload();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(AmbulanceOrderEntity order) {
    final customer = order.customer;
    final product = order.product;
    final statusColor = _statusColor(order.bookingStatus);
    final paymentColor =
        order.paymentStatus == 'paid' ? Colors.green : Colors.orange;

    return GestureDetector(
      onTap: () => context.push('/ambulance-order-details', extra: order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.airport_shuttle,
                        color: AppColors.primaryDark, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.bookingId,
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: const Color(0xFF1E1B4B))),
                        Text(
                          product?.serviceName ?? 'N/A',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          "Type: ${order.emergencyType.isNotEmpty ? order.emergencyType[0].toUpperCase() + order.emergencyType.substring(1) : 'N/A'}",
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _statusBadge(order.bookingStatus, statusColor),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFF1F0F0)),
              const SizedBox(height: 12),

              // Customer row
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFFF5F3FF),
                    backgroundImage: customer?.profileImage != null
                        ? NetworkImage(customer!.profileImage!) as ImageProvider
                        : null,
                    child: customer?.profileImage == null
                        ? const Icon(Icons.person,
                            size: 18, color: AppColors.primaryDark)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer?.fullName ?? 'Unknown',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text(customer?.phone ?? '',
                            style: GoogleFonts.inter(
                                fontSize: 11, color: Colors.grey[500])),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${order.fare.toStringAsFixed(0)}',
                        style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primaryDark),
                      ),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 6, vertical: 2),
                      //   decoration: BoxDecoration(
                      //       color: paymentColor.withOpacity(0.1),
                      //       borderRadius: BorderRadius.circular(6)),
                      //   child: Text(
                      //     order.paymentStatus.toUpperCase(),
                      //     style: GoogleFonts.inter(
                      //         fontSize: 9,
                      //         fontWeight: FontWeight.bold,
                      //         color: paymentColor),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Locations
              _locationRow(Icons.circle, Colors.green, 'P:',
                  order.pickupLocation.address),
              const SizedBox(height: 4),
              _locationRow(Icons.location_on, Colors.red, 'D:',
                  order.dropoffLocation.address),
              const SizedBox(height: 10),

              // Footer
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(DateFormat('MMM d, yyyy').format(order.createdAt),
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey[500])),
                  const Spacer(),
                  Icon(Icons.social_distance,
                      size: 12, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('${order.distance.toStringAsFixed(0)} km',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey[500])),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                        color: paymentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      order.paymentMethod == 'cod'
                          ? 'Cash on Delivery'
                          : 'Online',
                      style: GoogleFonts.inter(
                          fontSize: 11, color: Colors.grey[500]),
                    ),
                  ),
                  // Text(
                  //   order.paymentMethod == 'cod'
                  //       ? 'Cash on Delivery'
                  //       : 'Online',
                  //   style: GoogleFonts.inter(
                  //       fontSize: 11, color: Colors.grey[500]),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationRow(
      IconData icon, Color color, String prefix, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(icon, size: 10, color: color),
        ),
        const SizedBox(width: 6),
        Text('$prefix ',
            style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600])),
        Expanded(
          child: Text(
            address,
            style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _statusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20)),
      child: Text(
        _capitalize(status),
        style: GoogleFonts.inter(
            fontSize: 11, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.airport_shuttle_outlined,
              size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text('No ambulance orders found',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

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
