import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/price_formatter.dart';
import '../bloc/coupon_bloc.dart';
import '../bloc/coupon_event.dart';
import '../bloc/coupon_state.dart';
import 'add_coupon_screen.dart';
import 'edit_coupon_screen.dart';
import '../../domain/entities/coupon_entity.dart';

class CouponListScreen extends StatefulWidget {
  const CouponListScreen({super.key});

  @override
  State<CouponListScreen> createState() => _CouponListScreenState();
}

class _CouponListScreenState extends State<CouponListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = ''; // '' for All, 'active', 'inactive'

  @override
  void initState() {
    super.initState();
    _fetchCoupons();
  }

  void _fetchCoupons() {
    context.read<CouponBloc>().add(
          GetCouponsEvent(
            search: _searchController.text,
            status: _selectedStatus,
          ),
        );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        title: Text(
          'My Coupons',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _fetchCoupons(),
                  decoration: InputDecoration(
                    hintText: 'Search coupons...',
                    hintStyle: GoogleFonts.inter(
                        color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon:
                        const Icon(Icons.search_rounded, color: Colors.grey),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              _fetchCoupons();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: GoogleFonts.inter(fontSize: 14),
                ),
                const SizedBox(height: 12),
                // Status tabs
                Row(
                  children: [
                    _buildStatusChip('All', ''),
                    const SizedBox(width: 8),
                    _buildStatusChip('Active', 'active'),
                    const SizedBox(width: 8),
                    _buildStatusChip('Inactive', 'inactive'),
                  ],
                ),
              ],
            ),
          ),

          // Coupons list
          Expanded(
            child: BlocBuilder<CouponBloc, CouponState>(
              builder: (context, state) {
                if (state is CouponListLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFF6B48FF)),
                    ),
                  );
                } else if (state is CouponListError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded,
                              size: 64, color: Colors.red.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load coupons',
                            style: GoogleFonts.inter(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchCoupons,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B48FF),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text('Retry',
                                style: GoogleFonts.inter(color: Colors.white)),
                          )
                        ],
                      ),
                    ),
                  );
                } else if (state is CouponListLoaded) {
                  final coupons = state.coupons;
                  if (coupons.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_offer_outlined,
                              size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No Coupons Found',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the button below to add your first coupon.',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: Colors.grey.shade400),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _fetchCoupons(),
                    color: const Color(0xFF6B48FF),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: coupons.length,
                      itemBuilder: (context, index) {
                        final coupon = coupons[index];
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<CouponBloc>(),
                                  child: EditCouponScreen(coupon: coupon),
                                ),
                              ),
                            );
                            if (result == true) {
                              _fetchCoupons();
                            }
                          },
                          child: _buildCouponCard(coupon),
                        );
                      },
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<CouponBloc>(),
                child: const AddCouponScreen(),
              ),
            ),
          );
          if (result == true) {
            _fetchCoupons();
          }
        },
        backgroundColor: const Color(0xFF6B48FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildStatusChip(String label, String statusValue) {
    final isSelected = _selectedStatus == statusValue;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = statusValue;
        });
        _fetchCoupons();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B48FF) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildCouponCard(Coupon coupon) {
    final isPercent =
        coupon.discountType.toString().toLowerCase().contains('percent');
    final formattedValue = isPercent
        ? '${coupon.discountValue.toStringAsFixed(0)}%'
        : coupon.discountValue.toRupeeFormat();

    final startDateStr = DateFormat('dd MMM yyyy').format(coupon.validFrom);
    final endDateStr = DateFormat('dd MMM yyyy').format(coupon.validTo);
    final computedStatus = coupon.computedStatus;
    final isActive = computedStatus == 'Active';
    final isUpcoming = computedStatus == 'Upcoming';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left discount badge strip
              Container(
                width: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6B48FF), Color(0xFF432A9C)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formattedValue,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'OFF',
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Right contents
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Code and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(6),
                              border:
                                  Border.all(color: const Color(0xFFC7D2FE)),
                            ),
                            child: Text(
                              coupon.couponCode,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4F46E5),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              computedStatus,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFFB91C1C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Coupon Name
                      Text(
                        coupon.couponName,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Details (Min purchase, hidden etc.)
                      if (coupon.minimumPurchaseAmount != null &&
                          coupon.minimumPurchaseAmount! > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            'Min. Purchase: ${coupon.minimumPurchaseAmount!.toRupeeFormat()}',
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ),
                      // Validity dates
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '$startDateStr - $endDateStr',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          if (coupon.hiddenCoupon) ...[
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Hidden',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
