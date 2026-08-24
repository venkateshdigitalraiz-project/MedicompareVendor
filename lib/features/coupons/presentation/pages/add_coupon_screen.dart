import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/coupon_entity.dart';
import '../bloc/add_coupon_bloc.dart';
import '../bloc/add_coupon_event.dart';
import '../bloc/add_coupon_state.dart';

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

  String _selectionType = 'User';
  String _renewalCycle = 'Never (One-time)';
  String _discountType = 'Percentage (%)';
  String _status = 'Active';

  DateTime? _validFrom;
  DateTime? _validTo;
  bool _hiddenCoupon = false;

  final DateFormat _dateFormat = DateFormat('MM/dd/yyyy');

  final Color _primaryColor = const Color(0xFF2D1B69);

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
      initialDate: DateTime.now(),
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
        couponCode: _couponCodeController.text,
        selectionType: _selectionType,
        userLimit: int.tryParse(_userLimitController.text),
        renewalCycle: _renewalCycle,
        couponName: _couponNameController.text,
        discountType: _discountType,
        discountValue: double.parse(_discountValueController.text),
        minimumPurchaseAmount: double.tryParse(_minPurchaseController.text),
        maximumDiscountAmount: double.tryParse(_maxDiscountController.text),
        validFrom: _validFrom!,
        validTo: _validTo!,
        status: _status,
        hiddenCoupon: _hiddenCoupon,
      );

      context.read<AddCouponBloc>().add(SubmitAddCouponEvent(coupon: coupon));
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
      body: BlocConsumer<AddCouponBloc, AddCouponState>(
        listener: (context, state) {
          if (state is AddCouponSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Coupon created successfully!',
                    style: GoogleFonts.inter()),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is AddCouponFailure) {
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
                                  onTap: () => setState(() =>
                                      _discountType = 'Percentage (%)'),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color:
                                          _discountType == 'Percentage (%)'
                                              ? Colors.white
                                              : Colors.transparent,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                    boxShadow: _discountType ==
                                            'Percentage (%)'
                                        ? [
                                            BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.05),
                                                blurRadius: 4,
                                                  offset:
                                                      const Offset(0, 2))
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
                                          color: _discountType ==
                                                  'Percentage (%)'
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
                                onTap: () => setState(() =>
                                    _discountType = 'Fixed Amount(₹)'),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        _discountType == 'Fixed Amount(₹)'
                                            ? Colors.white
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: _discountType ==
                                            'Fixed Amount(₹)'
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
                                          color: _discountType ==
                                                  'Fixed Amount(₹)'
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

                  // --- SECTION 4: Settings ---
                  _buildSectionCard(
                    title: 'Additional Settings',
                    children: [
                      _buildLabel('Renewal Cycle'),
                      DropdownButtonFormField<String>(
                        value: _renewalCycle,
                        decoration: _buildInputDecoration(''),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        items: [
                          'Never (One-time)',
                          'Every Week',
                          'Every 10 days',
                          'Every Month'
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
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
                                state is AddCouponLoading ? null : _submitForm,
                            icon: const Icon(Icons.check_circle_outline_rounded,
                                color: Colors.white, size: 20),
                            label: state is AddCouponLoading
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
}
