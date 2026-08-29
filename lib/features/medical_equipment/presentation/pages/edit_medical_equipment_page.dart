import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/medical_equipment_entity.dart';
import '../../domain/usecases/update_medical_equipment_usecase.dart';
import '../../medical_equipment_injection.dart';
import 'package:MediCompare/core/constants/app_colors.dart';

class EditMedicalEquipmentPage extends StatefulWidget {
  final MedicalEquipmentItem item;
  final VoidCallback? onSuccess;

  const EditMedicalEquipmentPage({
    super.key,
    required this.item,
    this.onSuccess,
  });

  @override
  State<EditMedicalEquipmentPage> createState() =>
      _EditMedicalEquipmentPageState();
}

class _EditMedicalEquipmentPageState extends State<EditMedicalEquipmentPage> {
  final _formKey = GlobalKey<FormState>();
  final UpdateMedicalEquipmentUseCase _updateUseCase =
      MedicalEquipmentInjection.provideUpdateUseCase();

  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _depositController;
  late final TextEditingController _returnChargeController;
  late final TextEditingController _serviceChargeController;
  late final TextEditingController _rentController;
  late final TextEditingController _searchController;

  String _selectedStatus = 'active';
  String? _selectedTabletId;
  String? _selectedCategory;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;

    _priceController = TextEditingController(
      text: item.price % 1 == 0
          ? item.price.toInt().toString()
          : item.price.toStringAsFixed(2),
    );
    _discountController = TextEditingController(
      text: item.discountPrice % 1 == 0
          ? item.discountPrice.toInt().toString()
          : item.discountPrice.toStringAsFixed(2),
    );
    _depositController = TextEditingController(
      text: (item.fixedDeposit ?? 0) % 1 == 0
          ? (item.fixedDeposit ?? 0).toInt().toString()
          : (item.fixedDeposit ?? 0).toStringAsFixed(2),
    );
    _returnChargeController = TextEditingController(
      text: (item.returnCharge ?? 0) % 1 == 0
          ? (item.returnCharge ?? 0).toInt().toString()
          : (item.returnCharge ?? 0).toStringAsFixed(2),
    );
    _serviceChargeController = TextEditingController(
      text: (item.serviceCharges ?? 0) % 1 == 0
          ? (item.serviceCharges ?? 0).toInt().toString()
          : (item.serviceCharges ?? 0).toStringAsFixed(2),
    );
    _rentController = TextEditingController(
      text: (item.perDayRent ?? 0) % 1 == 0
          ? (item.perDayRent ?? 0).toInt().toString()
          : (item.perDayRent ?? 0).toStringAsFixed(2),
    );

    _searchController = TextEditingController(text: item.details.name);
    _selectedStatus =
        item.status.toLowerCase() == 'inactive' ? 'inactive' : 'active';
    _selectedTabletId = item.details.id;
    _selectedCategory = item.details.subcategory?.name;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    _depositController.dispose();
    _returnChargeController.dispose();
    _serviceChargeController.dispose();
    _rentController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTabletId == null || _selectedTabletId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select medical equipment name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final payload = {
        'name': _selectedTabletId,
        'category': _selectedCategory ?? widget.item.details.subcategory?.name ?? 'General',
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'discount': double.tryParse(_discountController.text) ?? 0.0,
        'fixedDeposit': double.tryParse(_depositController.text) ?? 0.0,
        'returnCharge': double.tryParse(_returnChargeController.text) ?? 0.0,
        'serviceCharges': double.tryParse(_serviceChargeController.text) ?? 0.0,
        'perDayRent': double.tryParse(_rentController.text) ?? 0.0,
        'status': _selectedStatus,
        'brand': widget.item.details.brand ?? '',
        'model': widget.item.details.model ?? '',
        'description': widget.item.details.description.isNotEmpty
            ? widget.item.details.description
            : 'Medical equipment',
        'interest': null,
      };

      await _updateUseCase(widget.item.id, payload);

      if (widget.onSuccess != null) {
        widget.onSuccess!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Updated successfully'),
            backgroundColor: Color(0xFF15803D),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('ServerException: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1E1B4B), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Edit Medical Equipment",
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E1B4B),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF5F3FF),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.medical_services_outlined,
                                color: AppColors.primary, size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Edit Medical Equipment',
                                  style: GoogleFonts.inter(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E1B4B)),
                                ),
                                Text(
                                  'Fill in the details to update medical equipment',
                                  style: GoogleFonts.inter(
                                      fontSize: 12, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Color(0xFF1E1B4B))),
                        ],
                      ),
                    ),
                    const Divider(height: 24),
                    
                    // Form
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Medical Equipment Information",
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E1B4B))),
                            Text(
                                "Please provide accurate information for the medical equipment",
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: Colors.grey[500])),
                            const SizedBox(height: 20),

                            // Search Name
                            _buildLabel("Medical Equipment Name",
                                isRequired: false,
                                icon: Icons.medical_information_outlined),
                            const SizedBox(height: 8),
                            _buildSearchField(),
                            const SizedBox(height: 16),

                            // Grid Layout for inputs
                            Row(
                              children: [
                                Expanded(
                                    child: _buildInputField("Price (?)",
                                        _priceController, Icons.currency_rupee)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _buildInputField(
                                        "Discount Price (?)",
                                        _discountController,
                                        Icons.local_offer_outlined, validator: (val) {
                                  if (val == null || val.isEmpty) return "Required";
                                  final discount = double.tryParse(val);
                                  final price = double.tryParse(_priceController.text);
                                  if (discount != null &&
                                      price != null &&
                                      discount > price) {
                                    return "Over price";
                                  }
                                  return null;
                                })),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                    child: _buildInputField("Fixed Deposit (?)",
                                        _depositController, Icons.savings_outlined)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _buildInputField(
                                        "Return Charge (?)",
                                        _returnChargeController,
                                        Icons.replay_outlined)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                    child: _buildInputField(
                                        "Service Charges (?)",
                                        _serviceChargeController,
                                        Icons.design_services_outlined)),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: _buildInputField("Per Day Rent (?)",
                                        _rentController, Icons.calendar_today_outlined)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildLabel("Status",
                                          isRequired: true,
                                          icon: Icons.check_circle_outline),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: _selectedStatus,
                                        isExpanded: true,
                                        decoration: _inputDecoration(hint: "Status"),
                                        style: GoogleFonts.inter(
                                            fontSize: 13, color: Colors.black87),
                                        items: [
                                          DropdownMenuItem(
                                              value: 'active',
                                              child: Text("Active",
                                                  style: GoogleFonts.inter(
                                                      fontSize: 13))),
                                          DropdownMenuItem(
                                              value: 'inactive',
                                              child: Text("Inactive",
                                                  style: GoogleFonts.inter(
                                                      fontSize: 13))),
                                        ],
                                        onChanged: (val) =>
                                            setState(() => _selectedStatus = val!),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(), // Keep the grid balanced
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    
                    // Footer
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(16)),
                          border: Border(top: BorderSide(color: Colors.grey[200]!))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel",
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: const Color(0xFF1E1B4B),
                                    fontWeight: FontWeight.w600)),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 44,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _submit,
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.add_shopping_cart, size: 16),
                              label: Text("Update Equipment",
                                  style: GoogleFonts.inter(
                                      fontSize: 14, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      String label, TextEditingController controller, IconData icon,
      {String? Function(String?)? validator}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, isRequired: true, icon: icon),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: GoogleFonts.inter(fontSize: 13),
          decoration: _inputDecoration(hint: "0.00"),
          validator: validator ??
              (val) => (val == null || val.isEmpty) ? "Required" : null,
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextFormField(
      controller: _searchController,
      enabled: false,
      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
      decoration: _inputDecoration(hint: "Search Medical Equipment...").copyWith(
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false, IconData? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6)
        ],
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1E1B4B)),
          ),
        ),
        if (isRequired)
          Text(" *",
              style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red)),
    );
  }
}
