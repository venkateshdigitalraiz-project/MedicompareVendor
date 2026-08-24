import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/coupon_entity.dart';
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

  final Color _primaryColor = const Color(0xFF6B48FF);

  @override
  void initState() {
    super.initState();
    _couponNameController = TextEditingController(text: widget.coupon.couponName);
    _couponCodeController = TextEditingController(text: widget.coupon.couponCode);
    _discountValueController = TextEditingController(text: widget.coupon.discountValue.toStringAsFixed(0));
    _minPurchaseController = TextEditingController(
        text: widget.coupon.minimumPurchaseAmount != null ? widget.coupon.minimumPurchaseAmount!.toStringAsFixed(0) : '');
    _maxDiscountController = TextEditingController(
        text: widget.coupon.maximumDiscountAmount != null ? widget.coupon.maximumDiscountAmount!.toStringAsFixed(0) : '');
    _userLimitController = TextEditingController(
        text: widget.coupon.userLimit != null ? widget.coupon.userLimit!.toString() : '');

    _selectionType = widget.coupon.selectionType;
    _renewalCycle = widget.coupon.renewalCycle;
    _discountType = widget.coupon.discountType;
    _status = widget.coupon.status;
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

      final updatedCoupon = Coupon(
        id: widget.coupon.id,
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
        description: widget.coupon.description,
        userId: widget.coupon.userId,
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
          if (state is CouponUpdateSuccess) {
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
                        value: _selectionType,
                        decoration: _buildInputDecoration('Select Type'),
                        items: ['User', 'Branch', 'All'].map((String type) {
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
                      _buildLabel('Renewal Cycle'),
                      DropdownButtonFormField<String>(
                        value: _renewalCycle,
                        decoration: _buildInputDecoration('Select Cycle'),
                        items: ['Never (One-time)', 'Daily', 'Weekly', 'Monthly', 'Yearly'].map((String cycle) {
                          return DropdownMenuItem<String>(
                            value: cycle,
                            child: Text(cycle, style: GoogleFonts.inter()),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _renewalCycle = val!),
                      ),
                    ],
                  ),

                  // Discount Details
                  _buildSectionCard(
                    title: 'Discount details',
                    children: [
                      _buildLabel('Discount Type'),
                      DropdownButtonFormField<String>(
                        value: _discountType,
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
                        value: _status,
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
}
