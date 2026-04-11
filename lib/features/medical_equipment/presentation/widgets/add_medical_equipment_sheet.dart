import 'dart:async';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/medical_equipment/data/data_sources/medical_equipment_service.dart';
import 'package:MediCompare/features/medical_equipment/data/models/medical_equipment_model.dart';
import 'package:MediCompare/features/medical_equipment/medical_equipment_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMedicalEquipmentSheet extends StatefulWidget {
  final MedicalEquipmentItem? editItem;
  final VoidCallback onSuccess;
  final List<String> existingIds;

  const AddMedicalEquipmentSheet({
    super.key,
    this.editItem,
    required this.onSuccess,
    this.existingIds = const [],
  });

  @override
  State<AddMedicalEquipmentSheet> createState() =>
      _AddMedicalEquipmentSheetState();
}

class _AddMedicalEquipmentSheetState extends State<AddMedicalEquipmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final MedicalEquipmentService _service =
      MedicalEquipmentInjection.provideMedicalEquipmentService();

  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _depositController = TextEditingController();
  final _returnChargeController = TextEditingController();
  final _serviceChargeController = TextEditingController();
  final _rentController = TextEditingController();
  final _searchController = TextEditingController();

  String _selectedStatus = 'active';
  String? _selectedTabletId;
  String? _selectedCategory;
  bool _isSubmitting = false;

  List<MedicalEquipmentDropdownItem> _searchResults = [];
  Timer? _debounce;

  bool get isEditMode => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final item = widget.editItem!;
      _priceController.text = item.price.toInt().toString();
      _discountController.text = item.discountPrice.toInt().toString();
      _depositController.text = item.fixedDeposit?.toInt().toString() ?? "0";
      _returnChargeController.text =
          item.returnCharge?.toInt().toString() ?? "0";
      _serviceChargeController.text =
          item.serviceCharges?.toInt().toString() ?? "0";
      _rentController.text = item.perDayRent?.toInt().toString() ?? "0";
      _selectedStatus = item.status;
      _selectedTabletId = item.details.id;
      _searchController.text = item.details.name;
      _selectedCategory = item.details.subcategory?.name;
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _service.searchTablets(query);
        if (mounted) setState(() => _searchResults = results);
      } catch (_) {}
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTabletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please select an equipment'),
          backgroundColor: Colors.red));
      return;
    }

    if (!isEditMode && widget.existingIds.contains(_selectedTabletId!)) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('This product already present'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final payload = {
        'name': _selectedTabletId,
        'category': _selectedCategory ?? 'General',
        'price': double.tryParse(_priceController.text) ?? 0,
        'discount': double.tryParse(_discountController.text) ?? 0,
        'fixedDeposit': double.tryParse(_depositController.text) ?? 0,
        'returnCharge': double.tryParse(_returnChargeController.text) ?? 0,
        'serviceCharges': double.tryParse(_serviceChargeController.text) ?? 0,
        'perDayRent': double.tryParse(_rentController.text) ?? 0,
        'status': _selectedStatus,
        'brand': '',
        'model': '',
        'description': 'Medical equipment',
        'interest': null,
      };

      if (isEditMode) {
        await _service.update(widget.editItem!.id, payload);
      } else {
        await _service.create(payload);
      }
      widget.onSuccess();
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(
          SnackBar(
            content: Text(isEditMode
                ? 'Updated successfully'
                : 'Product added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
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
                        isEditMode
                            ? 'Edit Medical Equipment'
                            : 'Add New Medical Equipment',
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E1B4B)),
                      ),
                      Text(
                        'Fill in the details to ${isEditMode ? 'update' : 'add'} medical equipment',
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
          Flexible(
            child: SingleChildScrollView(
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
                        isRequired: !isEditMode,
                        icon: isEditMode
                            ? Icons.medical_information_outlined
                            : Icons.search),
                    const SizedBox(height: 8),
                    _buildSearchField(),
                    const SizedBox(height: 16),

                    // Grid Layout for inputs
                    Row(
                      children: [
                        Expanded(
                            child: _buildInputField("Price (₹)",
                                _priceController, Icons.currency_rupee)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildInputField(
                                "Discount Price (₹)",
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
                            child: _buildInputField("Fixed Deposit (₹)",
                                _depositController, Icons.savings_outlined)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildInputField(
                                "Return Charge (₹)",
                                _returnChargeController,
                                Icons.replay_outlined)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: _buildInputField(
                                "Service Charges (₹)",
                                _serviceChargeController,
                                Icons.design_services_outlined)),
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildInputField("Per Day Rent (₹)",
                                _rentController, Icons.calendar_today_outlined)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isEditMode)
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
          ),
          // Footer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: BoxDecoration(
                color: Colors.white,
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
                    label: Text(
                        isEditMode ? "Update Equipment" : "Add Equipment",
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
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(fontSize: 13),
          decoration: _inputDecoration(hint: "0.00"),
          validator: validator ??
              (val) => (val == null || val.isEmpty) ? "Required" : null,
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Column(
      children: [
        TextFormField(
          controller: _searchController,
          enabled: !isEditMode,
          style: GoogleFonts.inter(
              fontSize: 13,
              color: isEditMode ? Colors.grey[600] : Colors.black87),
          onTap: () {
            if (!isEditMode && _searchController.text.isEmpty)
              _onSearchChanged('');
          },
          decoration:
              _inputDecoration(hint: "Search Medical Equipment...").copyWith(
            suffixIcon: isEditMode
                ? null
                : const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            fillColor: isEditMode ? Colors.grey[50] : Colors.white,
          ),
          onChanged: (q) {
            setState(() {
              _selectedTabletId = null;
            });
            _onSearchChanged(q);
          },
          validator: (_) => _selectedTabletId == null ? "Required" : null,
        ),
        if (!isEditMode &&
            _searchResults.isNotEmpty &&
            _selectedTabletId == null)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (_, i) {
                final item = _searchResults[i];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTabletId = item.id;
                      _searchController.text = item.name;
                      _selectedCategory = item.subcategory?.name;
                      _searchResults = [];
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Text(item.name,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: const Color(0xFF1E1B4B))),
                  ),
                );
              },
            ),
          ),
      ],
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
