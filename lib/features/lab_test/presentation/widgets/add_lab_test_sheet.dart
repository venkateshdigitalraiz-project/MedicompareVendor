import 'dart:async';
import 'package:MediCompare/features/lab_test/data/data_sources/lab_test_service.dart';
import 'package:MediCompare/features/lab_test/data/models/lab_test_model.dart';
import 'package:MediCompare/features/lab_test/lab_test_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddLabTestSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final LabTestItem? editItem;
  final List<String> existingIds;

  const AddLabTestSheet({
    super.key,
    required this.onSuccess,
    this.editItem,
    this.existingIds = const [],
  });

  @override
  State<AddLabTestSheet> createState() => _AddLabTestSheetState();
}

class _AddLabTestSheetState extends State<AddLabTestSheet> {
  final _formKey = GlobalKey<FormState>();
  final LabTestService _labTestService =
      LabTestInjection.provideLabTestService();

  LabTestDropdownItem? _selectedTest;

  final _priceController = TextEditingController();
  final _discountController = TextEditingController();

  final _searchController = TextEditingController();
  List<LabTestDropdownItem> _searchResults = [];
  Timer? _debounce;

  bool _isLoading = false;
  bool _isFetchingDetails = false;
  String _selectedStatus = 'active';

  bool get isEditMode => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _loadEditData();
    }
  }

  Future<void> _loadEditData() async {
    setState(() => _isFetchingDetails = true);
    try {
      // Fetch fresh details for tablet ID
      final tabletDetails = await _labTestService
          .getLabTestTabletDetails(widget.editItem!.details.id);

      setState(() {
        _selectedTest = LabTestDropdownItem(
          id: tabletDetails.id,
          name: tabletDetails.name,
          price: 0, // Not needed here
          subcategoryId: tabletDetails.subcategory?.id ?? '',
        );

        _priceController.text = widget.editItem!.price.toString();
        _discountController.text = widget.editItem!.discountPrice.toString();
        _searchController.text = _selectedTest?.name ?? '';
        _selectedStatus = widget.editItem!.status;
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isFetchingDetails = false);
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

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _labTestService.searchLabTests(query);
        if (mounted) {
          setState(() {
            _searchResults = results
                .map((e) => LabTestDropdownItem(
                      id: e.id,
                      name: e.name,
                      price: 0,
                      subcategoryId: e.subcategory?.id ?? '',
                    ))
                .toList();
          });
        }
      } catch (_) {}
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a lab test first')));
      return;
    }

    if (!isEditMode && widget.existingIds.contains(_selectedTest!.id)) {
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

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> payload = {
        "name": _selectedTest!.id,
        "price": double.tryParse(_priceController.text) ?? 0,
        "discountprice": double.tryParse(_discountController.text) ?? 0,
        "status": _selectedStatus,
        "files": [],
        "facilities": [],
      };

      if (isEditMode) {
        await _labTestService.updateLabTest(widget.editItem!.id, payload);
      } else {
        await _labTestService.createLabTest(payload);
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
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFetchingDetails) {
      return Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.science_outlined,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEditMode ? "Edit Lab Test" : "Add New Lab Test",
                            style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E1B4B))),
                        Text(
                            "Fill in the details to add a lab test to your system",
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Lab Test Information",
                          style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E1B4B))),
                      const SizedBox(height: 4),
                      Text(
                          "Please provide accurate information for the lab test",
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 24),

                      // Test Name Input
                      _buildLabel("Test Name",
                          isRequired: true, icon: Icons.science_outlined),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          TextFormField(
                            controller: _searchController,
                            style: GoogleFonts.poppins(fontSize: 14),
                            onTap: () {
                              if (_searchController.text.isEmpty)
                                _onSearchChanged('');
                            },
                            decoration: _inputDecoration(
                                    hint: "Search for lab test...")
                                .copyWith(
                                    suffixIcon:
                                        const Icon(Icons.keyboard_arrow_down)),
                            onChanged: (val) {
                              setState(() {
                                _selectedTest = null;
                              });
                              _onSearchChanged(val);
                            },
                            validator: (value) =>
                                _selectedTest == null ? "Required" : null,
                          ),
                          if (_selectedTest == null &&
                              _searchResults.isNotEmpty)
                            Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              margin: const EdgeInsets.only(top: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[200]!),
                                boxShadow: [
                                  BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8)
                                ],
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: _searchResults.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final option = _searchResults[index];
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedTest = option;
                                        _searchController.text = option.name;
                                        _searchResults = [];
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Text(option.name,
                                          style: GoogleFonts.poppins(
                                              fontSize: 14)),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                          "Search and select a test to auto-fill details and price",
                          style: GoogleFonts.poppins(
                              fontSize: 11, color: Colors.grey[500])),

                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Price (₹)",
                                    isRequired: true,
                                    icon: Icons.currency_rupee),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration(hint: "0.00"),
                                  validator: (val) =>
                                      (val == null || val.isEmpty)
                                          ? "Required"
                                          : null,
                                ),
                                // const SizedBox(height: 4),
                                // Text("Auto-filled when test selected, can be edited if needed", style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Discount Price (₹)",
                                    isRequired: true,
                                    icon: Icons.currency_rupee),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _discountController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration(hint: "0.00"),
                                  validator: (val) {
                                    if (val == null || val.isEmpty)
                                      return "Required";
                                    final discount = double.tryParse(val);
                                    final price =
                                        double.tryParse(_priceController.text);
                                    if (discount != null &&
                                        price != null &&
                                        discount > price) {
                                      return "Over price";
                                    }
                                    return null;
                                  },
                                ),
                                // const SizedBox(height: 4),
                                // Text("Auto-filled when discount price selected, can be edited if needed", style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      _buildLabel("Active Status",
                          isRequired: false, icon: Icons.power_settings_new),
                      const SizedBox(height: 8),
                      _buildToggleBtn(
                        _selectedStatus == 'active' ? "Active" : "Inactive",
                        Icons.power_settings_new,
                        _selectedStatus == 'active'
                            ? const Color(0xFF7C3AED)
                            : Colors.grey,
                        () => setState(() => _selectedStatus =
                            _selectedStatus == 'active'
                                ? 'inactive'
                                : 'active'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel",
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF1E1B4B),
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.science_outlined, size: 18),
                    label: Text(
                        _isLoading
                            ? "Saving..."
                            : (isEditMode ? "Update Lab Test" : "Add Lab Test"),
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false, IconData? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4B5563)),
        ),
        if (isRequired)
          Text(" *",
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED))),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red)),
    );
  }

  Widget _buildToggleBtn(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w500, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
