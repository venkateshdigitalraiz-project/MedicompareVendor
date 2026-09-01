import 'dart:async';
import 'package:MediCompare/features/coupons/domain/entities/customer_entity.dart';
import 'package:MediCompare/features/coupons/presentation/bloc/coupon_bloc.dart';
import 'package:MediCompare/features/coupons/presentation/bloc/coupon_event.dart';
import 'package:MediCompare/features/coupons/presentation/bloc/coupon_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/coupon_entity.dart';

class AddCouponScreen extends StatefulWidget {
  const AddCouponScreen({Key? key}) : super(key: key);

  @override
  _AddCouponScreenState createState() => _AddCouponScreenState();
}

class _AddCouponScreenState extends State<AddCouponScreen> {
  final _formKey = GlobalKey<FormState>();

  final _couponCodeController = TextEditingController();
  final _userLimitController = TextEditingController();
  final _couponNameController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minPurchaseController = TextEditingController();
  final _maxDiscountController = TextEditingController();

  String _selectionType = 'All';
  String _renewalCycle = 'Never (One-time)';
  String _discountType = 'Percentage (%)';
  String _status = 'Active';

  DateTime? _validFrom;
  DateTime? _validTo;
  bool _hiddenCoupon = false;

  List<Customer> _customers = [];
  List<Customer> _selectedCustomers = [];

  final DateFormat _dateFormat = DateFormat('MM/dd/yyyy');

  final Color _primaryColor = const Color(0xFF2D1B69);

  @override
  void initState() {
    super.initState();
    context.read<CouponBloc>().add(const FetchCustomersEvent());
  }

  @override
  void dispose() {
    _couponCodeController.dispose();
    _userLimitController.dispose();
    _couponNameController.dispose();
    _discountValueController.dispose();
    _minPurchaseController.dispose();
    _maxDiscountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate
          ? (_validFrom ?? DateTime.now())
          : (_validTo ?? _validFrom ?? DateTime.now()),
      firstDate: isFromDate ? DateTime.now() : (_validFrom ?? DateTime.now()),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _validFrom = picked;
        } else {
          _validTo = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_validFrom == null || _validTo == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select Valid From and Valid To dates',
                style: GoogleFonts.inter()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final coupon = Coupon(
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
        userId: _selectedCustomers.isNotEmpty
            ? _selectedCustomers.map((c) => c.id).join(',')
            : null,
      );

      context.read<CouponBloc>().add(SubmitAddCouponEvent(coupon: coupon));
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
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft modern background
      appBar: AppBar(
        title: Text('Add New Coupon',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.bold, color: Colors.black87)),
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
            });
          } else if (state is CouponSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Coupon created successfully!',
                    style: GoogleFonts.inter()),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is CouponFailure) {
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
          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, left: 8.0),
                    child: Text(
                      'Create a new discount coupon to offer special deals to your customers.',
                      style: GoogleFonts.inter(
                          color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ),

                  // --- SECTION 1: Basic Info ---
                  _buildSectionCard(
                    title: 'Basic Information',
                    children: [
                      _buildLabel('Coupon Name *'),
                      TextFormField(
                        controller: _couponNameController,
                        decoration:
                            _buildInputDecoration('e.g., Weekend Special'),
                        style: GoogleFonts.inter(),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('Coupon Code *'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _couponCodeController,
                              decoration: _buildInputDecoration('e.g., SAVE20'),
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: _primaryColor),
                              validator: (value) =>
                                  value!.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            height: 44, // Match text field height
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6B48FF), Color(0xFF2D1B69)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _couponCodeController.text =
                                      'GEN${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                              ),
                              child: Text('Generate',
                                  style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // --- SECTION 4: Settings ---
                  _buildSectionCard(
                    title: 'Additional Settings',
                    children: [
                      _buildLabel('Selection Type'),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectionType = 'User'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _selectionType == 'User'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: _selectionType == 'User'
                                        ? [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2))
                                          ]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_outline,
                                          size: 18,
                                          color: _selectionType == 'User'
                                              ? Colors.black87
                                              : Colors.grey.shade600),
                                      const SizedBox(width: 6),
                                      Text('User',
                                          style: GoogleFonts.inter(
                                              color: _selectionType == 'User'
                                                  ? Colors.black87
                                                  : Colors.grey.shade600,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectionType = 'Multiple'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _selectionType == 'Multiple'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: _selectionType == 'Multiple'
                                        ? [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2))
                                          ]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.people_outline,
                                          size: 18,
                                          color: _selectionType == 'Multiple'
                                              ? Colors.black87
                                              : Colors.grey.shade600),
                                      const SizedBox(width: 6),
                                      Text('Multiple',
                                          style: GoogleFonts.inter(
                                              color:
                                                  _selectionType == 'Multiple'
                                                      ? Colors.black87
                                                      : Colors.grey.shade600,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _selectionType = 'All'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _selectionType == 'All'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: _selectionType == 'All'
                                        ? [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2))
                                          ]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.public,
                                          size: 18,
                                          color: _selectionType == 'All'
                                              ? Colors.black87
                                              : Colors.grey.shade600),
                                      const SizedBox(width: 6),
                                      Text('All',
                                          style: GoogleFonts.inter(
                                              color: _selectionType == 'All'
                                                  ? Colors.black87
                                                  : Colors.grey.shade600,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectionType == 'All') ...[
                        _buildLabel('Renewal Cycle'),
                        DropdownButtonFormField<String>(
                          value: _renewalCycle,
                          decoration: _buildInputDecoration(''),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          items: [
                            'Never (One-time)',
                            'Every Week',
                            'Every 10 days',
                            'Every Month',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value, style: GoogleFonts.inter()),
                            );
                          }).toList(),
                          onChanged: (newValue) =>
                              setState(() => _renewalCycle = newValue!),
                        ),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 16),
                      if (_selectionType == 'User' ||
                          _selectionType == 'Multiple') ...[
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
                                color: _selectedCustomers.isNotEmpty
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
                                    color: _selectedCustomers.isNotEmpty
                                        ? const Color(0xFFEEF2FF)
                                        : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: _selectedCustomers.isNotEmpty
                                        ? (_selectedCustomers.length > 1
                                            ? const Icon(Icons.people_alt,
                                                color: Color(0xFF6B48FF), size: 20)
                                            : Text(
                                                _selectedCustomers.first.fullName.isNotEmpty
                                                    ? _selectedCustomers.first.fullName[0]
                                                        .toUpperCase()
                                                    : '?',
                                                style: GoogleFonts.inter(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(0xFF6B48FF),
                                                ),
                                              ))
                                        : const Icon(
                                            Icons.person_search_rounded,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _selectedCustomers.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _selectedCustomers
                                                  .map((c) => c.fullName)
                                                  .join(', '),
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              _selectedCustomers.length == 1
                                                  ? (_selectedCustomers.first.phone.isNotEmpty
                                                      ? _selectedCustomers.first.phone
                                                      : (_selectedCustomers.first.email ??
                                                          'ID: ${_selectedCustomers.first.custId}'))
                                                  : '${_selectedCustomers.length} customers selected',
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
                                if (_selectedCustomers.isNotEmpty)
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedCustomers.clear();
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
                      ],
                      _buildLabel('Status'),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _status = 'Active'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _status == 'Active'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: _status == 'Active'
                                        ? [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2))
                                          ]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('Active',
                                      style: GoogleFonts.inter(
                                          color: _status == 'Active'
                                              ? Colors.black87
                                              : Colors.grey.shade600,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _status = 'Inactive'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _status == 'Inactive'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: _status == 'Inactive'
                                        ? [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2))
                                          ]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: Text('Inactive',
                                      style: GoogleFonts.inter(
                                          color: _status == 'Inactive'
                                              ? Colors.black87
                                              : Colors.grey.shade600,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: CheckboxListTile(
                          title: Text('Hidden Coupon',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text('Hide from general list',
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: Colors.grey.shade600)),
                          value: _hiddenCoupon,
                          activeColor: _primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          onChanged: (bool? value) =>
                              setState(() => _hiddenCoupon = value ?? false),
                          controlAffinity: ListTileControlAffinity.trailing,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  // --- SECTION 2: Discount Details ---
                  _buildSectionCard(
                    title: 'Discount Details',
                    children: [
                      _buildLabel('Discount Type *'),
                      Container(
                        height: 44,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _discountType = 'Percentage (%)'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _discountType == 'Percentage (%)'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: _discountType == 'Percentage (%)'
                                        ? [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2))
                                          ]
                                        : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Text(
                                        'Percent(%)',
                                        style: GoogleFonts.inter(
                                          color:
                                              _discountType == 'Percentage (%)'
                                                  ? Colors.black87
                                                  : Colors.grey.shade600,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(
                                    () => _discountType = 'Fixed Amount(₹)'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _discountType == 'Fixed Amount(₹)'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow:
                                        _discountType == 'Fixed Amount(₹)'
                                            ? [
                                                BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2))
                                              ]
                                            : [],
                                  ),
                                  alignment: Alignment.center,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Text(
                                        'Fixed(₹)',
                                        style: GoogleFonts.inter(
                                          color:
                                              _discountType == 'Fixed Amount(₹)'
                                                  ? Colors.black87
                                                  : Colors.grey.shade600,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Value *'),
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
                                  validator: (value) =>
                                      value!.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Max Discount (₹)'),
                                TextFormField(
                                  controller: _maxDiscountController,
                                  keyboardType: TextInputType.number,
                                  decoration: _buildInputDecoration(
                                      'e.g., 1000',
                                      suffixIcon: const Icon(
                                          Icons.currency_rupee_rounded,
                                          size: 20)),
                                  style: GoogleFonts.inter(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // --- SECTION 3: Usage & Validity ---
                  _buildSectionCard(
                    title: 'Usage & Validity',
                    children: [
                      _buildLabel('Minimum Purchase Amount'),
                      TextFormField(
                        controller: _minPurchaseController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('e.g., 500',
                            suffixIcon: const Icon(Icons.currency_rupee_rounded,
                                size: 20)),
                        style: GoogleFonts.inter(),
                      ),
                      const SizedBox(height: 16),
                      _buildLabel('User Limit (Usage per User)'),
                      TextFormField(
                        controller: _userLimitController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('e.g., 1',
                            suffixIcon: const Icon(Icons.person_outline_rounded,
                                size: 20)),
                        style: GoogleFonts.inter(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Valid From *'),
                                GestureDetector(
                                  onTap: () => _selectDate(context, true),
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _validFrom != null
                                                ? _dateFormat
                                                    .format(_validFrom!)
                                                : 'Select Date',
                                            style: GoogleFonts.inter(
                                              color: _validFrom != null
                                                  ? Colors.black87
                                                  : Colors.grey.shade400,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const Icon(Icons.calendar_month_rounded,
                                            size: 20, color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Valid To *'),
                                GestureDetector(
                                  onTap: () => _selectDate(context, false),
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF9FAFB),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _validTo != null
                                                ? _dateFormat.format(_validTo!)
                                                : 'Select Date',
                                            style: GoogleFonts.inter(
                                              color: _validTo != null
                                                  ? Colors.black87
                                                  : Colors.grey.shade400,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                        const Icon(Icons.calendar_month_rounded,
                                            size: 20, color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // --- Action Buttons ---
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Colors.grey.shade300, width: 1.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text('Cancel',
                                style: GoogleFonts.inter(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6B48FF), Color(0xFF2D1B69)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6B48FF).withOpacity(0.3),
                                spreadRadius: 0,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed:
                                state is CouponLoading ? null : _submitForm,
                            icon: const Icon(Icons.check_circle_outline_rounded,
                                color: Colors.white, size: 20),
                            label: state is CouponLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Text('Create Coupon',
                                    style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _openCustomerPickerModal(BuildContext context) {
    Timer? debounceTimer;
    final couponBloc = context.read<CouponBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        String searchQuery = '';
        return BlocProvider.value(
            value: couponBloc,
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
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
                            BlocBuilder<CouponBloc, CouponState>(
                              builder: (context, state) {
                                int count = _customers.length;
                                if (state is CustomersLoaded)
                                  count = state.customers.length;
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF4F46E5),
                                    ),
                                  ),
                                );
                              },
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

                            if (debounceTimer?.isActive ?? false) {
                              debounceTimer!.cancel();
                            }
                            debounceTimer =
                                Timer(const Duration(milliseconds: 500), () {
                              context
                                  .read<CouponBloc>()
                                  .add(FetchCustomersEvent(search: val));
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
                                    icon: const Icon(Icons.clear_rounded,
                                        size: 18),
                                    onPressed: () {
                                      setModalState(() {
                                        searchQuery = '';
                                      });
                                      if (debounceTimer?.isActive ?? false) {
                                        debounceTimer!.cancel();
                                      }
                                      context.read<CouponBloc>().add(
                                          const FetchCustomersEvent(
                                              search: ''));
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
                        child: BlocBuilder<CouponBloc, CouponState>(
                            builder: (context, state) {
                          if (state is CustomersLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          List<Customer> displayList = _customers;
                          if (state is CustomersLoaded) {
                            displayList = state.customers;
                          }

                          final filtered = displayList.where((c) {
                            final query = searchQuery.toLowerCase().trim();
                            if (query.isEmpty) return true;
                            return c.fullName.toLowerCase().contains(query) ||
                                c.phone.toLowerCase().contains(query) ||
                                (c.email?.toLowerCase().contains(query) ??
                                    false) ||
                                c.custId.toLowerCase().contains(query);
                          }).toList();

                          if (filtered.isEmpty) {
                            return Center(
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
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) =>
                                Divider(height: 1, color: Colors.grey.shade100),
                            itemBuilder: (context, index) {
                              final customer = filtered[index];
                              final isSelected = _selectedCustomers
                                  .any((c) => c.id == customer.id);

                              return ListTile(
                                onTap: () {
                                  setModalState(() {
                                    if (_selectionType == 'Multiple') {
                                      if (isSelected) {
                                        _selectedCustomers.removeWhere(
                                            (c) => c.id == customer.id);
                                      } else {
                                        _selectedCustomers.add(customer);
                                      }
                                    } else {
                                      _selectedCustomers = [customer];
                                    }
                                  });
                                  setState(() {});
                                  if (_selectionType != 'Multiple') {
                                    Navigator.of(modalContext).pop();
                                  }
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
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
            ));
      },
    );
  }
}
