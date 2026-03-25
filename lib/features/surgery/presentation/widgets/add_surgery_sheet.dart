import 'package:MediCompare/features/surgery/data/data_sources/surgery_service.dart';
import 'package:MediCompare/features/surgery/data/models/surgery_model.dart';
import 'package:MediCompare/features/surgery/surgery_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddSurgerySheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final SurgeryItem? editSurgery;
  final List<String> existingIds;

  const AddSurgerySheet({
    super.key, 
    required this.onSuccess, 
    this.editSurgery,
    this.existingIds = const [],
  });

  @override
  State<AddSurgerySheet> createState() => _AddSurgerySheetState();
}

class _AddSurgerySheetState extends State<AddSurgerySheet> {
  final _formKey = GlobalKey<FormState>();
  final SurgeryService _surgeryService = SurgeryInjection.provideSurgeryService();

  SurgeryDropdownItem? _selectedSurgery;
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  
  bool _isActive = true;
  bool _isLoading = false;
  bool _isFetchingDetails = false;

  bool get isEditMode => widget.editSurgery != null;

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
      // In a real scenario, we might fetch vendor surgery details if editSurgery is partial
      // For now, mapping from widget.editSurgery
      final surgery = widget.editSurgery!;
      setState(() {
        _selectedSurgery = SurgeryDropdownItem(
          id: surgery.details.id,
          name: surgery.details.name,
          subcategoryId: surgery.details.subcategory?.id ?? '',
          complexity: surgery.details.complexity,
          duration: surgery.details.duration,
          description: surgery.details.description,
        );
        _priceController.text = surgery.price.toString();
        _discountController.text = surgery.discountPrice.toString();
        _isActive = surgery.status == 'active';
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isFetchingDetails = false);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSurgery == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a surgery first')));
      return;
    }

    if (!isEditMode && widget.existingIds.contains(_selectedSurgery!.id)) {
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
        "name": isEditMode ? widget.editSurgery!.id : _selectedSurgery!.id,
        "category": _selectedSurgery!.subcategoryId, // Using subcategory ID as 'category' often maps to subcategory in these APIs
        "price": double.tryParse(_priceController.text) ?? 0,
        "discount": double.tryParse(_discountController.text) ?? 0,
        "status": _isActive ? "active" : "inactive",
        "type": "general",
        "complexity": _selectedSurgery!.complexity ?? "simple",
        "duration": _selectedSurgery!.duration ?? "",
        "description": _selectedSurgery!.description ?? ""
      };

      if (isEditMode) {
        // According to user's example, update payload uses product ID in 'name' field
        payload["name"] = widget.editSurgery!.id;
        await _surgeryService.updateSurgery(widget.editSurgery!.id, payload);
      } else {
        await _surgeryService.createSurgery(payload);
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.show_chart, color: Color(0xFF7C3AED), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEditMode ? "Edit Surgery" : "Add New Surgery", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B))),
                        Text("Fill in the details to add a surgery to your system", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: _isFetchingDetails 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.close, color: Colors.grey),
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
                      Text("Surgery Information", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B))),
                      const SizedBox(height: 4),
                      Text(isEditMode ? "Update the surgery details below" : "Please provide accurate information for the surgery", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 24),
                      
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Surgery Name Dropdown
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Surgery Name", isRequired: true, icon: Icons.link_outlined),
                                const SizedBox(height: 8),
                                if (isEditMode && _selectedSurgery != null) ...[
                                   Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Text(_selectedSurgery!.name, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF4B5563)), overflow: TextOverflow.ellipsis),
                                        ),
                                        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Surgery name cannot be changed.", style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500])),
                                ] else ...[
                                  Autocomplete<SurgeryDropdownItem>(
                                  displayStringForOption: (option) => option.name,
                                  optionsBuilder: (TextEditingValue textEditingValue) async {
                                    if (textEditingValue.text.isEmpty) return const Iterable<SurgeryDropdownItem>.empty();
                                    try {
                                      return await _surgeryService.getCommonSurgeries(textEditingValue.text);
                                    } catch (e) {
                                      return const Iterable<SurgeryDropdownItem>.empty();
                                    }
                                  },
                                  onSelected: (SurgeryDropdownItem selection) {
                                    setState(() => _selectedSurgery = selection);
                                  },
                                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                    return TextFormField(
                                      controller: controller,
                                      focusNode: focusNode,
                                      style: GoogleFonts.poppins(fontSize: 14),
                                      decoration: _inputDecoration(hint: "Search Surgery...").copyWith(
                                        suffixIcon: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (controller.text.isNotEmpty)
                                              IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () {
                                                controller.clear();
                                                setState(() => _selectedSurgery = null);
                                              }),
                                            const Icon(Icons.keyboard_arrow_down),
                                            const SizedBox(width: 8),
                                          ],
                                        )
                                      ),
                                      validator: (value) => _selectedSurgery == null ? "Required" : null,
                                    );
                                  },
                                  optionsViewBuilder: (context, onSelected, options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(12),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxHeight: 250,
                                            maxWidth: MediaQuery.of(context).size.width - 100,
                                          ),
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            itemCount: options.length,
                                            itemBuilder: (BuildContext context, int index) {
                                              final option = options.elementAt(index);
                                              return InkWell(
                                                onTap: () => onSelected(option),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                  child: Text(option.name, style: GoogleFonts.poppins(fontSize: 14)),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Status Dropdown
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Status", isRequired: true, icon: Icons.show_chart),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<bool>(
                                  value: _isActive,
                                  decoration: _inputDecoration(hint: "Active"),
                                  items: [
                                    DropdownMenuItem(value: true, child: Text("Active", style: GoogleFonts.poppins(fontSize: 14))),
                                    DropdownMenuItem(value: false, child: Text("Inactive", style: GoogleFonts.poppins(fontSize: 14))),
                                  ],
                                  onChanged: (val) => setState(() => _isActive = val ?? true),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      if (_selectedSurgery != null) ...[
                        const SizedBox(height: 32),
                        Text("Surgery Price", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B))),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Price (₹)", isRequired: true, icon: Icons.show_chart),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(hint: "0.00"),
                                validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
                              ),
                              const SizedBox(height: 16),
                              _buildLabel("Discount Price (₹)", isRequired: true, icon: Icons.show_chart),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _discountController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration(hint: "0.00").copyWith(
                                  suffixIcon: const Icon(Icons.unfold_more, size: 18, color: Colors.grey),
                                ),
                                validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(height: 1),
            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1E1B4B), fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading 
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Icon(Icons.show_chart, size: 18),
                    label: Text(_isLoading ? "Saving..." : (isEditMode ? "Update Surgery" : "Add Surgery"), style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {required bool isRequired, IconData? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF4B5563)),
        ),
        if (isRequired)
          Text(" *", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF7C3AED))),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
    );
  }
}
