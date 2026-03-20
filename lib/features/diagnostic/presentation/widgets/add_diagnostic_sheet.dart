import 'dart:async';
import 'dart:io';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/diagnostic/data/data_sources/diagnostic_service.dart';
import 'package:MediCompare/features/diagnostic/data/models/diagnostic_model.dart';
import 'package:MediCompare/features/diagnostic/diagnostic_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class AddDiagnosticSheet extends StatefulWidget {
  final DiagnosticItem? editItem;
  final VoidCallback onSuccess;

  const AddDiagnosticSheet({super.key, this.editItem, required this.onSuccess});

  @override
  State<AddDiagnosticSheet> createState() => _AddDiagnosticSheetState();
}

class _AddDiagnosticSheetState extends State<AddDiagnosticSheet> {
  final _formKey = GlobalKey<FormState>();
  final DiagnosticService _service = DiagnosticInjection.provideDiagnosticService();

  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _searchController = TextEditingController();

  String _selectedStatus = 'active';
  String? _selectedTabletId;
  File? _selectedImage;
  bool _isLoading = false;
  bool _isSubmitting = false;

  List<DiagnosticDropdownItem> _searchResults = [];
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
    }
    _loadInitialSearchResults();
  }

  Future<void> _loadInitialSearchResults() async {
    setState(() => _isLoading = true);
    try {
      final results = await _service.searchDiagnostics('');
      if (mounted) setState(() { _searchResults = results; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _service.searchDiagnostics(query);
        if (mounted) setState(() => _searchResults = results);
      } catch (_) {}
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTabletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a diagnostic'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final payload = {
        'name': _selectedTabletId,
        'price': double.tryParse(_priceController.text) ?? 0,
        'discount': double.tryParse(_discountController.text) ?? 0,
        'status': _selectedStatus,
      };
      if (isEditMode) {
        await _service.updateDiagnostic(widget.editItem!.id, payload, image: _selectedImage);
      } else {
        await _service.createDiagnostic(payload, image: _selectedImage);
      }
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
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
                  child: const Icon(Icons.biotech_outlined, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditMode ? 'Edit Diagnostic' : 'Add New Diagnostic',
                        style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B)),
                      ),
                      Text(
                        'Fill in the details to ${isEditMode ? 'update' : 'add'} a diagnostic',
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
                    Text("Diagnostic Information", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B))),
                    Text("Please provide accurate information", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 20),

                    // Row 1: Name + Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Diagnostic Name", isRequired: true, icon: Icons.crop_free_outlined),
                              const SizedBox(height: 8),
                              _buildDiagnosticSearchField(),
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

                    // _buildLabel("Diagnostic Image", icon: Icons.image_outlined),
                    // const SizedBox(height: 8),
                    // _buildImagePicker(),

                    const SizedBox(height: 12),
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
                // Text("All fields marked with * are required", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500])),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E1B4B), fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.crop_free_outlined, size: 16),
                        label: Text(isEditMode ? "Update" : "Add Diagnostic", style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: DottedBorder(
        color: Colors.grey[300]!,
        borderType: BorderType.RRect,
        radius: const Radius.circular(12),
        dashPattern: const [6, 4],
        child: Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: _selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, fit: BoxFit.cover),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file_outlined, color: Colors.grey[400], size: 28),
                      const SizedBox(height: 4),
                      Text("Upload diagnostic image", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400])),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDiagnosticSearchField() {
    return Column(
      children: [
        TextFormField(
          controller: _searchController,
          style: GoogleFonts.inter(fontSize: 13),
          decoration: _inputDecoration(hint: "Search Diagnostic...").copyWith(
            suffixIcon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          ),
          onChanged: (q) {
            setState(() { _selectedTabletId = null; });
            _onSearchChanged(q);
          },
          validator: (_) => _selectedTabletId == null ? "Please select a diagnostic" : null,
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
            child: _isLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator(strokeWidth: 2)))
                : _searchResults.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text("No diagnostics found", style: GoogleFonts.inter(color: Colors.grey, fontSize: 13)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        itemBuilder: (_, i) {
                          final item = _searchResults[i];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedTabletId = item.id;
                                _searchController.text = item.name;
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
