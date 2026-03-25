import 'dart:async';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/home_care/data/data_sources/home_care_service.dart';
import 'package:MediCompare/features/home_care/data/models/home_care_model.dart';
import 'package:MediCompare/features/home_care/home_care_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddHomeCareSheet extends StatefulWidget {
  final HomeCareItem? editItem;
  final VoidCallback onSuccess;
  final List<String> existingIds;

  const AddHomeCareSheet({
    super.key, 
    this.editItem, 
    required this.onSuccess,
    this.existingIds = const [],
  });

  @override
  State<AddHomeCareSheet> createState() => _AddHomeCareSheetState();
}

class _AddHomeCareSheetState extends State<AddHomeCareSheet> {
  final _formKey = GlobalKey<FormState>();
  final HomeCareService _service = HomeCareInjection.provideHomeCareService();

  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _searchController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedStatus = 'active';
  String? _selectedTabletId;
  String? _selectedCategory;
  bool _isSubmitting = false;

  List<HomeCareDropdownItem> _searchResults = [];
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
      _durationController.text = item.details.duration ?? "";
      _descriptionController.text = item.details.description ?? "";
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _service.searchHomeCareDropdown(query);
        if (mounted) setState(() => _searchResults = results);
      } catch (_) {}
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTabletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a service'), backgroundColor: Colors.red));
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
        'duration': _durationController.text,
        'description': _descriptionController.text,
        'serviceType': [], // Backend expectation
      };

      if (isEditMode) {
        await _service.updateHomeCare(widget.editItem!.id, payload);
      } else {
        await _service.createHomeCare(payload);
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
    _durationController.dispose();
    _descriptionController.dispose();
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
                  child: const Icon(Icons.home_repair_service_outlined, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditMode ? 'Edit Healthcare Service' : 'Add New Healthcare Service',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B)),
                      ),
                      Text(
                        'Fill in the details to ${isEditMode ? 'update' : 'add'} a healthcare service',
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
                    Text("Healthcare Service Information", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B))),
                    Text("Please provide accurate information for the healthcare service", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 20),

                    // Row 1: Name + Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Service Name", isRequired: true, icon: Icons.health_and_safety_outlined),
                                const SizedBox(height: 8),
                                _buildServiceSearchField(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
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
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Row 2: Discount + Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Discount Price (₹)", isRequired: true, icon: Icons.currency_rupee),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Status", isRequired: true, icon: Icons.show_chart),
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
                    const SizedBox(height: 16),

                    // Row 3: Duration
                    // _buildLabel("Duration", icon: Icons.access_time),
                    // const SizedBox(height: 8),
                    // TextFormField(
                    //    controller: _durationController,
                    //    style: GoogleFonts.inter(fontSize: 13),
                    //    decoration: _inputDecoration(hint: "e.g. 1 hour or 5-6hrs"),
                    // ),

                    // const SizedBox(height: 16),
                    // _buildLabel("Description", icon: Icons.description_outlined),
                    // const SizedBox(height: 8),
                    // TextFormField(
                    //    controller: _descriptionController,
                    //    maxLines: 3,
                    //    style: GoogleFonts.inter(fontSize: 13),
                    //    decoration: _inputDecoration(hint: "Service details..."),
                    // ),

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
                    label: Text(isEditMode ? "Update Service" : "Add Service", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
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

  Widget _buildServiceSearchField() {
    return Column(
      children: [
        TextFormField(
          controller: _searchController,
          style: GoogleFonts.inter(fontSize: 13),
          onTap: () {
             if (_searchController.text.isEmpty) _onSearchChanged('');
          },
          decoration: _inputDecoration(hint: "Search Service...").copyWith(
            suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ),
          onChanged: (q) {
            setState(() { _selectedTabletId = null; });
            _onSearchChanged(q);
          },
          validator: (_) => _selectedTabletId == null ? "Required" : null,
        ),
        if (_searchController.text.isNotEmpty && _selectedTabletId == null)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: _searchResults.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text("No services found", style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (_, i) {
                      final item = _searchResults[i];
                      return InkWell(
                        onTap: () async {
                           setState(() {
                             _selectedTabletId = item.id;
                             _searchController.text = item.name;
                             _durationController.text = item.duration ?? "";
                             _searchResults = [];
                           });
                           
                           try {
                             final details = await _service.getTabletDetails(item.id);
                             if (mounted) {
                               setState(() {
                                 _selectedCategory = details.subcategory?.name;
                                 _descriptionController.text = details.description ?? "";
                               });
                             }
                           } catch (_) {}
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
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF4B5563)),
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
