import 'dart:io';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/features/lab_test/data/data_sources/lab_test_service.dart';
import 'package:MediCompare/features/lab_test/data/models/lab_test_model.dart';
import 'package:MediCompare/features/lab_test/data/models/lab_test_package_model.dart';
import 'package:MediCompare/features/lab_test/lab_test_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class AddLabTestPackageSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final LabTestPackageItem? editItem;

  const AddLabTestPackageSheet({super.key, required this.onSuccess, this.editItem});

  @override
  State<AddLabTestPackageSheet> createState() => _AddLabTestPackageSheetState();
}

class _AddLabTestPackageSheetState extends State<AddLabTestPackageSheet> {
  final _formKey = GlobalKey<FormState>();
  final LabTestService _labTestService = LabTestInjection.provideLabTestService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  
  String _selectedStatus = 'active';
  File? _selectedImage;
  
  List<LabTestDetails> _allLabTests = [];
  List<String> _selectedProductIds = [];
  bool _isLoading = false;
  bool _isFetchingTests = false;

  bool get isEditMode => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    _fetchLabTests();
    if (isEditMode) {
      _nameController.text = widget.editItem!.name;
      _descriptionController.text = widget.editItem!.description ?? "";
      _priceController.text = widget.editItem!.price.toString();
      _discountController.text = widget.editItem!.discountPrice.toString();
      _selectedStatus = widget.editItem!.status;
      _selectedProductIds = List<String>.from(widget.editItem!.products);
    }
  }

  Future<void> _fetchLabTests() async {
    setState(() => _isFetchingTests = true);
    try {
      final tests = await _labTestService.getAllLabTestTablets();
      setState(() {
        _allLabTests = tests;
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isFetchingTests = false);
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one lab test')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> payload = {
        "name": _nameController.text,
        "description": _descriptionController.text,
        "price": double.tryParse(_priceController.text) ?? 0,
        "discountprice": double.tryParse(_discountController.text) ?? 0,
        "products": _selectedProductIds,
        "status": _selectedStatus,
      };

      // Since the Service's createPackage/updatePackage is using json, if there's an image, we should check if we need to change it to multipart or if there's a separate method.
      // For now, I'll pass the image to the service's post call if needed.
      // Actually, I'll update the LabTestService to handle the image in a better way if needed.
      
      if (isEditMode) {
        await _labTestService.updatePackage(widget.editItem!.id, payload, image: _selectedImage);
      } else {
        await _labTestService.createPackage(payload, image: _selectedImage);
      }
      
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
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
                    child: const Icon(Icons.science_outlined, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(isEditMode ? "Edit Package" : "Add New Package", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B))),
                        Text("Fill in the details to add a lab test package to your system", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600])),
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
                      Row(
                        children: [
                           Expanded(
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 _buildLabel("Package Name", isRequired: true, icon: Icons.science_outlined),
                                 const SizedBox(height: 8),
                                 TextFormField(
                                   controller: _nameController,
                                   decoration: _inputDecoration(hint: "cbc"),
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
                                 _buildLabel("Price (₹)", isRequired: true, icon: Icons.currency_rupee),
                                 const SizedBox(height: 8),
                                 TextFormField(
                                   controller: _priceController,
                                   keyboardType: TextInputType.number,
                                   decoration: _inputDecoration(hint: "0.00"),
                                   validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
                                 ),
                               ],
                             ),
                           ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      Row(
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
                                    decoration: _inputDecoration(hint: "0.00"),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) return "Required";
                                      final discount = double.tryParse(val);
                                      final price = double.tryParse(_priceController.text);
                                      if (discount != null && price != null && discount > price) {
                                        return "Over price";
                                      }
                                      return null;
                                    },
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
                                    items: [
                                      DropdownMenuItem(value: 'active', child: Text("Active", style: GoogleFonts.inter(fontSize: 13))),
                                      DropdownMenuItem(value: 'inactive', child: Text("Inactive", style: GoogleFonts.inter(fontSize: 13))),
                                    ],
                                    onChanged: (val) => setState(() => _selectedStatus = val!),
                                    decoration: _inputDecoration(hint: "Select Status"),
                                  ),
                               ],
                             ),
                           ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      _buildLabel("Select Lab Tests", isRequired: true, icon: Icons.science_outlined),
                      const SizedBox(height: 8),
                      _isFetchingTests 
                          ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)))
                          : _buildTestSelector(),
                      
                      const SizedBox(height: 16),
                      _buildLabel("Description", icon: Icons.show_chart),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: _inputDecoration(hint: "Describe the lab test package..."),
                      ),
                      
                      const SizedBox(height: 16),
                      _buildLabel("Package Image", icon: Icons.image_outlined),
                      const SizedBox(height: 8),
                      _buildImagePicker(),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  
                   TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Cancel", style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E1B4B), fontWeight: FontWeight.w600)),
                   ),
                   const SizedBox(width: 12),
                   ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _submit,
                    icon: _isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.science_outlined, size: 18),
                    label: Text(_isLoading ? "Saving..." : (isEditMode ? "Update Package" : "Add Package"), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: _allLabTests.isEmpty 
              ? Center(child: Text("No tests found", style: GoogleFonts.inter(color: Colors.grey)))
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _allLabTests.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final test = _allLabTests[index];
                    final isSelected = _selectedProductIds.contains(test.id);
                    return InkWell(
                      onTap: () {
                         setState(() {
                           if (isSelected) {
                             _selectedProductIds.remove(test.id);
                           } else {
                             _selectedProductIds.add(test.id);
                           }
                         });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        color: isSelected ? const Color(0xFFF8FAFF) : Colors.transparent,
                        child: Row(
                          children: [
                            Checkbox(
                              value: isSelected,
                              activeColor: const Color(0xFF7C3AED),
                              onChanged: (val) {
                                 setState(() {
                                   if (val == true) {
                                     _selectedProductIds.add(test.id);
                                   } else {
                                     _selectedProductIds.remove(test.id);
                                   }
                                 });
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(test.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B))),
                                  Text(
                                    "${test.sampleType ?? 'Unknown'} • ${test.reportsDuration ?? 'Duration not specified'}",
                                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500]),
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
                      Text("Upload package image", style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[400])),
                    ],
                  ),
                ),
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
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF4B5563)),
          ),
        ),
        if (isRequired)
          Text(" *", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.red)),
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
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF7C3AED))),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.red)),
    );
  }
}
