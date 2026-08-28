import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/coupon_entity.dart';
import '../../domain/entities/customer_entity.dart';
import '../bloc/coupon_bloc.dart';
import '../bloc/coupon_event.dart';
import '../bloc/coupon_state.dart';

class EditCouponScreen extends StatefulWidget {
  final Coupon coupon;

  const EditCouponScreen({super.key, required this.coupon});

  @override
  State<EditCouponScreen> createState() => _EditCouponScreenState();
}

class _EditCouponScreenState extends State<EditCouponScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _couponNameController;
  late TextEditingController _couponCodeController;
  late TextEditingController _discountValueController;
  late TextEditingController _minPurchaseController;
  late TextEditingController _maxDiscountController;
  late TextEditingController _userLimitController;

  late String _selectionType;
  late String _renewalCycle;
  late String _discountType;
  late String _status;
  late bool _hiddenCoupon;
  late DateTime? _validFrom;
  late DateTime? _validTo;

  List<Customer> _customers = [];
  Customer? _selectedCustomer;

  final Color _primaryColor = const Color(0xFF6B48FF);

  @override
  void initState() {
    super.initState();
    context.read<CouponBloc>().add(const FetchCustomersEvent());
    _couponNameController = TextEditingController(text: widget.coupon.couponName);
    _couponCodeController = TextEditingController(text: widget.coupon.couponCode);
    _discountValueController = TextEditingController(text: widget.coupon.discountValue.toStringAsFixed(0));
    _minPurchaseController = TextEditingController(
        text: widget.coupon.minimumPurchaseAmount != null ? widget.coupon.minimumPurchaseAmount!.toStringAsFixed(0) : '');
    _maxDiscountController = TextEditingController(
        text: widget.coupon.maximumDiscountAmount != null ? widget.coupon.maximumDiscountAmount!.toStringAsFixed(0) : '');
    _userLimitController = TextEditingController(
        text: widget.coupon.userLimit != null ? widget.coupon.userLimit!.toString() : '');

    final sel = widget.coupon.selectionType.toLowerCase().trim();
    if (sel == 'user') {
      _selectionType = 'User';
    } else if (sel == 'branch') {
      _selectionType = 'Branch';
    } else if (sel == 'multiple') {
      _selectionType = 'Multiple';
    } else {
      _selectionType = 'All';
    }

    final rawRenewal = widget.coupon.renewalCycle.toLowerCase().trim();
    if (rawRenewal.contains('never') || rawRenewal == '1' || rawRenewal.contains('one-time')) {
      _renewalCycle = 'Never (One-time)';
    } else if (rawRenewal.contains('week') || rawRenewal == '7') {
      _renewalCycle = 'Every Week';
    } else if (rawRenewal.contains('10')) {
      _renewalCycle = 'Every 10 days';
    } else if (rawRenewal.contains('month') || rawRenewal == '28' || rawRenewal == '30') {
      _renewalCycle = 'Every Month';
    } else if (rawRenewal.contains('year') || rawRenewal == '365') {
      _renewalCycle = 'Yearly';
    } else if (rawRenewal.contains('daily') || rawRenewal == 'day') {
      _renewalCycle = 'Daily';
    } else {
      _renewalCycle = 'Never (One-time)';
    }

    final rawDisc = widget.coupon.discountType.toLowerCase().trim();
    if (rawDisc.contains('percent') || rawDisc == 'percentage') {
      _discountType = 'Percentage (%)';
    } else if (rawDisc.contains('fix') || rawDisc.contains('flat')) {
      _discountType = 'Fixed Amount(₹)';
    } else {
      _discountType = 'Percentage (%)';
    }

    final rawStat = widget.coupon.status.toLowerCase().trim();
    if (rawStat == 'inactive') {
      _status = 'Inactive';
    } else {
      _status = 'Active';
    }

    _hiddenCoupon = widget.coupon.hiddenCoupon;
    _validFrom = widget.coupon.validFrom;
    _validTo = widget.coupon.validTo;
  }

  @override
  void dispose() {
    _couponNameController.dispose();
    _couponCodeController.dispose();
    _discountValueController.dispose();
    _minPurchaseController.dispose();
    _maxDiscountController.dispose();
    _userLimitController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isFromDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: (isFromDate ? _validFrom : _validTo) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          _validFrom = pickedDate;
        } else {
          _validTo = pickedDate;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_validFrom == null || _validTo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select Valid From and Valid To dates', style: GoogleFonts.inter()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final showSelectUsers =
          _selectionType.trim().toLowerCase() == 'user' ||
          _selectionType.trim().toLowerCase() == 'multiple';

      final updatedCoupon = Coupon(
        id: widget.coupon.id,
        couponCode: _couponCodeController.text.trim(),
        selectionType: _selectionType,
        userLimit: _userLimitController.text.trim().isNotEmpty
            ? int.tryParse(_userLimitController.text.trim())
            : null,
        renewalCycle: _renewalCycle,
        couponName: _couponNameController.text.trim(),
        discountType: _discountType,
        discountValue: double.parse(_discountValueController.text.trim()),
        minimumPurchaseAmount: _minPurchaseController.text.trim().isNotEmpty
            ? double.tryParse(_minPurchaseController.text.trim())
            : null,
        maximumDiscountAmount: _maxDiscountController.text.trim().isNotEmpty
            ? double.tryParse(_maxDiscountController.text.trim())
            : null,
        validFrom: _validFrom!,
        validTo: _validTo!,
        status: _status,
        hiddenCoupon: _hiddenCoupon,
        description: widget.coupon.description,
        userId: showSelectUsers ? (_selectedCustomer?.id ?? widget.coupon.userId) : null,
        applicableType: widget.coupon.applicableType,
        category: widget.coupon.category,
      );

      if (widget.coupon.id != null) {
        context.read<CouponBloc>().add(
          SubmitUpdateCouponEvent(id: widget.coupon.id!, coupon: updatedCoupon),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E1B4B),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Column(
          children: [
            Text('Edit Coupon', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18)),
            Text('Update the coupon information', style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 11)),
          ],
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<CouponBloc, CouponState>(
        listener: (context, state) {
          if (state is CustomersLoaded) {
            setState(() {
              _customers = List.from(state.customers)
                ..sort((a, b) => a.fullName
                    .toLowerCase()
                    .compareTo(b.fullName.toLowerCase()));
              if (_selectedCustomer == null && widget.coupon.userId != null) {
                try {
                  _selectedCustomer = _customers.firstWhere(
                    (c) => c.id == widget.coupon.userId,
                  );
                } catch (_) {}
              }
            });
          } else if (state is CouponUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Coupon updated successfully!', style: GoogleFonts.inter()),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is CouponUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.inter()),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final showSelectUsers =
              _selectionType.trim().toLowerCase() == 'user' ||
              _selectionType.trim().toLowerCase() == 'multiple';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Basic Info
                  _buildSectionCard(
                    title: 'Basic Information',
                    children: [
                      _buildLabel('Coupon Name *'),
                      TextFormField(
                        controller: _couponNameController,
                        decoration: _buildInputDecoration('e.g., Weekend Special'),
                        style: GoogleFonts.inter(),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Coupon Code *'),
                      TextFormField(
                        controller: _couponCodeController,
                        decoration: _buildInputDecoration('e.g., SAVE20'),
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: _primaryColor),
                        validator: (value) => value!.isEmpty ? 'Required' : null,
                      ),
                    ],
                  ),

                  // Selection & Renewal
                  _buildSectionCard(
                    title: 'Target & Cycle Settings',
                    children: [
                      _buildLabel('Selection Type'),
                      DropdownButtonFormField<String>(
                        value: ['User', 'Multiple', 'Branch', 'All'].contains(_selectionType)
                            ? _selectionType
                            : 'All',
                        decoration: _buildInputDecoration('Select Type'),
                        items: ['User', 'Multiple', 'Branch', 'All'].map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type, style: GoogleFonts.inter()),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectionType = val!),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('User Limit (Usage per User)'),
                      TextFormField(
                        controller: _userLimitController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('e.g., 5 (Optional)'),
                        style: GoogleFonts.inter(),
                      ),
                      const SizedBox(height: 16),
                      if (showSelectUsers) ...[
                        _buildLabel('Select Customer(s)'),
                        InkWell(
                          onTap: () => _openCustomerPickerModal(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedCustomer != null
                                    ? const Color(0xFF6B48FF).withOpacity(0.5)
                                    : Colors.grey.shade200,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: _selectedCustomer != null
                                        ? const Color(0xFFEEF2FF)
                                        : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: _selectedCustomer != null
                                        ? Text(
                                            _selectedCustomer!.fullName.isNotEmpty
                                                ? _selectedCustomer!.fullName[0]
                                                    .toUpperCase()
                                                : '?',
                                            style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF6B48FF),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person_search_rounded,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _selectedCustomer != null
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _selectedCustomer!.fullName,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _selectedCustomer!.phone.isNotEmpty
                                                  ? _selectedCustomer!.phone
                                                  : (_selectedCustomer!.email ??
                                                      'ID: ${_selectedCustomer!.custId}'),
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        )
                                      : Text(
                                          'Tap to search & select customer...',
                                          style: GoogleFonts.inter(
                                            color: Colors.grey.shade400,
                                            fontSize: 14,
                                          ),
                                        ),
                                ),
                                if (_selectedCustomer != null)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedCustomer = null;
                                      });
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 20,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        _buildLabel('Renewal Cycle'),
                        DropdownButtonFormField<String>(
                          value: [
                            'Never (One-time)',
                            'Every Week',
                            'Every 10 days',
                            'Every Month',
                            'Daily',
                            'Yearly',
                          ].contains(_renewalCycle)
                              ? _renewalCycle
                              : 'Never (One-time)',
                          decoration: _buildInputDecoration('Select Cycle'),
                          items: [
                            'Never (One-time)',
                            'Every Week',
                            'Every 10 days',
                            'Every Month',
                            'Daily',
                            'Yearly',
                          ].map((String cycle) {
                            return DropdownMenuItem<String>(
                              value: cycle,
                              child: Text(cycle, style: GoogleFonts.inter()),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _renewalCycle = val!),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),

                  // Discount Details
                  _buildSectionCard(
                    title: 'Discount details',
                    children: [
                      _buildLabel('Discount Type'),
                      DropdownButtonFormField<String>(
                        value: ['Percentage (%)', 'Fixed Amount(₹)'].contains(_discountType)
                            ? _discountType
                            : 'Percentage (%)',
                        decoration: _buildInputDecoration('Select Type'),
                        items: ['Percentage (%)', 'Fixed Amount(₹)'].map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type, style: GoogleFonts.inter()),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _discountType = val!),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Discount Value *'),
                                TextFormField(
                                  controller: _discountValueController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration('Value',
                                      suffixIcon: Icon(
                                          _discountType == 'Percentage (%)'
                                              ? Icons.percent_rounded
                                              : Icons.currency_rupee_rounded,
                                          size: 20)),
                                  style: GoogleFonts.inter(),
                                  validator: (value) => value!.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Minimum Purchase'),
                                TextFormField(
                                  controller: _minPurchaseController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration('Min Purchase'),
                                  style: GoogleFonts.inter(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Maximum Discount'),
                      TextFormField(
                        controller: _maxDiscountController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('Max Discount (Optional)'),
                        style: GoogleFonts.inter(),
                      ),
                    ],
                  ),

                  // Validity & Status
                  _buildSectionCard(
                    title: 'Validity & Status Settings',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Valid From *'),
                                InkWell(
                                  onTap: () => _selectDateTime(context, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      border: Border.all(color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            _validFrom != null ? dateFormat.format(_validFrom!) : 'Select Date',
                                            style: GoogleFonts.inter(fontSize: 12),
                                          ),
                                        ),
                                        Icon(Icons.calendar_today_rounded, size: 16, color: _primaryColor),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Valid To *'),
                                InkWell(
                                  onTap: () => _selectDateTime(context, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      border: Border.all(color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            _validTo != null ? dateFormat.format(_validTo!) : 'Select Date',
                                            style: GoogleFonts.inter(fontSize: 12),
                                          ),
                                        ),
                                        Icon(Icons.calendar_today_rounded, size: 16, color: _primaryColor),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Status'),
                      DropdownButtonFormField<String>(
                        value: ['Active', 'Inactive'].contains(_status)
                            ? _status
                            : 'Active',
                        decoration: _buildInputDecoration('Select Status'),
                        items: ['Active', 'Inactive'].map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status, style: GoogleFonts.inter()),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _status = val!),
                      ),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        value: _hiddenCoupon,
                        onChanged: (val) => setState(() => _hiddenCoupon = val!),
                        title: Text(
                          'Hidden Coupon (Hide from general list)',
                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: _primaryColor,
                      ),
                    ],
                  ),

                  // Actions row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6B48FF), Color(0xFF2D1B69)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: state is CouponUpdateLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: state is CouponUpdateLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Update Coupon', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openCustomerPickerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _customers.where((c) {
              final query = searchQuery.toLowerCase().trim();
              if (query.isEmpty) return true;
              return c.fullName.toLowerCase().contains(query) ||
                  c.phone.toLowerCase().contains(query) ||
                  (c.email?.toLowerCase().contains(query) ?? false) ||
                  c.custId.toLowerCase().contains(query);
            }).toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
                    child: Row(
                      children: [
                        Text(
                          'Select Customer',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_customers.length}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(modalContext).pop(),
                          splashRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  // Search field
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 6.0),
                    child: TextField(
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name, phone, or ID...',
                        hintStyle: GoogleFonts.inter(
                            fontSize: 13, color: Colors.grey.shade400),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Colors.grey, size: 20),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  setModalState(() {
                                    searchQuery = '';
                                  });
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
                  ),
                  const SizedBox(height: 6),
                  // Customer List
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_off_outlined,
                                      size: 48, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No customers found',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Try searching with a different name or phone number.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) =>
                                Divider(height: 1, color: Colors.grey.shade100),
                            itemBuilder: (context, index) {
                              final customer = filtered[index];
                              final isSelected =
                                  _selectedCustomer?.id == customer.id;

                              return ListTile(
                                onTap: () {
                                  setState(() {
                                    _selectedCustomer = customer;
                                  });
                                  Navigator.of(modalContext).pop();
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF6B48FF)
                                        : const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Text(
                                      customer.fullName.isNotEmpty
                                          ? customer.fullName[0].toUpperCase()
                                          : '?',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF4F46E5),
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  customer.fullName,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF6B48FF)
                                        : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  customer.phone.isNotEmpty
                                      ? customer.phone
                                      : (customer.email ?? ''),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle_rounded,
                                        color: Color(0xFF6B48FF), size: 22)
                                    : (customer.custId.isNotEmpty
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF3F4F6),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              customer.custId,
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )
                                        : null),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
