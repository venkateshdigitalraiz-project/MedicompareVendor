import 'dart:async';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/medical_treatment/data/data_sources/medical_treatment_service.dart';
import 'package:MediCompare/features/medical_treatment/data/models/medical_treatment_model.dart';
import 'package:MediCompare/features/medical_treatment/medical_treatment_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddMedicalTreatmentSheet extends StatefulWidget {
  final MedicalTreatmentItem? editItem;
  final VoidCallback onSuccess;
  final List<String> existingIds;

  const AddMedicalTreatmentSheet({
    super.key, 
    this.editItem, 
    required this.onSuccess,
    this.existingIds = const [],
  });

  @override
  State<AddMedicalTreatmentSheet> createState() => _AddMedicalTreatmentSheetState();
}

class _AddMedicalTreatmentSheetState extends State<AddMedicalTreatmentSheet> {
  final _formKey = GlobalKey<FormState>();
  final MedicalTreatmentService _service = MedicalTreatmentInjection.provideMedicalTreatmentService();

  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _searchController = TextEditingController();

  String _selectedStatus = 'active';
  String? _selectedTabletId;
  String? _selectedCategory;
  bool _isSubmitting = false;

  List<MedicalTreatmentDropdownItem> _searchResults = [];
  Timer? _debounce;

  bool get isEditMode => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      final item = widget.editItem!;
      _priceController.text = item.price.toInt().toString();
      _discountController.text = item.discountPrice.toInt().toString();
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a treatment'), backgroundColor: Colors.red));
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
        'status': _selectedStatus,
        'description': '', // Optional fields
        'duration': '',
        'procedureType': '',
        'complexityLevel': '',
        'recoveryTime': '',
        'requirements': [],
        'sideEffects': [],
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
            content: Text(isEditMode ? 'Updated successfully' : 'Product added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
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
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.medical_information_outlined, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditMode ? 'Edit Medical Treatment' : 'Add New Medical Treatment',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B)),
                      ),
                      Text(
                        'Fill in the details to ${isEditMode ? 'update' : 'add'} a medical treatment',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Color(0xFF1E1B4B))),
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
                    Text("Treatment Information", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B))),
                    Text("Search and pick from global medical treatments", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 20),

                    // Search Name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Treatment Name", isRequired: !isEditMode, icon: isEditMode ? Icons.medical_information_outlined : Icons.search),
                        const SizedBox(height: 8),
                        _buildSearchField(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price & Discount
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Price (₹)", isRequired: true, icon: Icons.currency_rupee),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.inter(fontSize: 13),
                                decoration: _inputDecoration(hint: "0.00"),
                                validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Discount Price (₹)", isRequired: true, icon: Icons.local_offer_outlined),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _discountController,
                                keyboardType: TextInputType.number,
                                style: GoogleFonts.inter(fontSize: 13),
                                decoration: _inputDecoration(hint: "0.00"),
                                validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Status
                    Row(
                       children: [
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               _buildLabel("Status", isRequired: true, icon: Icons.check_circle_outline),
                               const SizedBox(height: 8),
                               DropdownButtonFormField<String>(
                                 value: _selectedStatus,
                                 isExpanded: true,
                                 decoration: _inputDecoration(hint: "Select Status"),
                                 style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                                 items: [
                                   DropdownMenuItem(value: 'active', child: Text("Active", style: GoogleFonts.inter(fontSize: 13))),
                                   DropdownMenuItem(value: 'inactive', child: Text("Inactive", style: GoogleFonts.inter(fontSize: 13))),
                                 ],
                                 onChanged: (val) => setState(() => _selectedStatus = val!),
                               ),
                             ],
                           ),
                         ),
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
            decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[200]!))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E1B4B), fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.add, size: 16),
                    label: Text(isEditMode ? "Update Treatment" : "Add Treatment", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildSearchField() {
    return Column(
      children: [
        TextFormField(
          controller: _searchController,
          enabled: !isEditMode,
          style: GoogleFonts.inter(fontSize: 13, color: isEditMode ? Colors.grey[600] : Colors.black87),
          onTap: () {
            if (!isEditMode && _searchController.text.isEmpty) _onSearchChanged('');
          },
          decoration: _inputDecoration(hint: "Select Treatment...").copyWith(
            suffixIcon: isEditMode ? null : const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            fillColor: isEditMode ? Colors.grey[50] : Colors.white,
          ),
          onChanged: (q) {
            setState(() { _selectedTabletId = null; });
            _onSearchChanged(q);
          },
          validator: (_) => _selectedTabletId == null ? "Required" : null,
        ),
        if (!isEditMode && _searchResults.isNotEmpty && _selectedTabletId == null)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Text(item.name, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1E1B4B))),
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
        if (icon != null) ...[Icon(icon, size: 14, color: Colors.grey[500]), const SizedBox(width: 6)],
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF1E1B4B)),
          ),
        ),
        if (isRequired) Text(" *", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red)),
    );
  }
}
