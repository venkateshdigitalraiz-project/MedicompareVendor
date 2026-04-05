import 'dart:convert';
import 'dart:io';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/core/utils/core_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../data/data_sources/branch_service.dart';
import '../../data/models/branch_model.dart';

class EditBranchSheet extends StatefulWidget {
  final Branch branch;
  final VoidCallback onSuccess;

  const EditBranchSheet({super.key, required this.branch, required this.onSuccess});

  @override
  State<EditBranchSheet> createState() => _EditBranchSheetState();
}

class _EditBranchSheetState extends State<EditBranchSheet> {
  final _formKey = GlobalKey<FormState>();
  final BranchService _branchService = BranchService(CoreInjection.provideApiService());
  final String _googleApiKey = "AIzaSyCrQfumXF2fKkdxz0Z1SRD-9XlAthO3vZs";

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _editableAddressController;
  late final TextEditingController _stateController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  
  String _selectedStatus = 'active';
  String _selectedRole = 'Manager';
  File? _selectedImage;
  bool _isLoading = false;
  
  // Google Places API state
  List<dynamic> _predictions = [];
  bool _isSearchingAddress = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch.name);
    _addressController = TextEditingController(text: widget.branch.address);
    _editableAddressController = TextEditingController();
    _stateController = TextEditingController(text: widget.branch.state);
    _mobileController = TextEditingController(text: widget.branch.mobile);
    _emailController = TextEditingController(text: widget.branch.email);
    _selectedStatus = widget.branch.status;
    // Assuming roleId or some other string matches. Default to 'Manager'
    _selectedRole = 'Manager'; 
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _editableAddressController.dispose();
    _stateController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress(String query) async {
    if (query.length < 3) {
      if (_predictions.isNotEmpty) setState(() => _predictions = []);
      return;
    }

    setState(() => _isSearchingAddress = true);
    try {
      final url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleApiKey&sessiontoken=branch_edit_v1";
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      
      if (data['status'] == 'OK' && mounted) {
        setState(() {
          _predictions = data['predictions'];
        });
      }
    } catch (e) {
      debugPrint("Address search error: $e");
    } finally {
      if (mounted) setState(() => _isSearchingAddress = false);
    }
  }

  void _onAddressSelected(Map<String, dynamic> prediction) {
    setState(() {
      _editableAddressController.text = prediction['description'];
      _addressController.text = prediction['description'];
      _predictions = [];
      // Attempt to extract state if possible or keep manually
    });
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> payload = {
        "name": _nameController.text,
        "email": _emailController.text,
        "mobile": _mobileController.text,
        "address": _addressController.text,
        "state": _stateController.text,
        "status": _selectedStatus,
        "roleId": widget.branch.roleId, // Should match what backend expects
      };

      await _branchService.updateBranch(widget.branch.id, payload, image: _selectedImage);
      widget.onSuccess();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentImageUrl = widget.branch.images.isNotEmpty ? widget.branch.images.first : "";

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edit Branch",
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E1B4B)),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Branch Name", isRequired: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration(hint: "Digitalraiz Sub-Branch"),
                      validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel("Branch Image"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                         Container(
                           width: 60,
                           height: 60,
                           decoration: BoxDecoration(
                             color: const Color(0xFFF9FAFB),
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(color: Colors.grey[200]!),
                           ),
                           child: _selectedImage != null 
                             ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_selectedImage!, fit: BoxFit.cover))
                             : currentImageUrl.isNotEmpty 
                               ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(currentImageUrl, fit: BoxFit.cover))
                               : const Icon(Icons.business, color: Colors.grey),
                         ),
                         const SizedBox(width: 16),
                         Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                              OutlinedButton(
                                onPressed: _pickImage,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text("Change Image", style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E1B4B))),
                              ),
                              const SizedBox(height: 4),
                              Text("JPG, PNG or GIF. Max 2MB.", style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[500])),
                           ],
                         ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildLabel("Branch Address", isRequired: true),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: _inputDecoration(hint: "Enter branch address"),
                      validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Branch Address (Editable)", isRequired: true),
                    const SizedBox(height: 8),
                    Stack(
                      children: [
                        TextFormField(
                          controller: _editableAddressController,
                          maxLines: 3,
                          onChanged: _searchAddress,
                          decoration: _inputDecoration(hint: "Address will be auto-filled from Google Maps or enter manually"),
                        ),
                        if (_predictions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 80),
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: _predictions.length,
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final p = _predictions[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(p['description'], style: GoogleFonts.inter(fontSize: 12)),
                                  onTap: () => _onAddressSelected(p),
                                );
                              },
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
                              _buildLabel("State", isRequired: true),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _stateController,
                                decoration: _inputDecoration(hint: "State"),
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
                              _buildLabel("Contact Number", isRequired: true),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _mobileController,
                                keyboardType: TextInputType.phone,
                                decoration: _inputDecoration(hint: "7777777777"),
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
                              _buildLabel("Email"),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailController,
                                decoration: _inputDecoration(hint: "digi@gmail.com"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Role"),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(value: 'Select Role', child: Text("Select Role")),
                                  DropdownMenuItem(value: 'Manager', child: Text("Manager")),
                                  DropdownMenuItem(value: 'pharmacist', child: Text("pharmacist")),
                                  DropdownMenuItem(value: 'nurse', child: Text("nurse")),
                                  DropdownMenuItem(value: 'doctor', child: Text("doctor")),
                                ],
                                onChanged: (val) => setState(() => _selectedRole = val!),
                                decoration: _inputDecoration(hint: "Select Role"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildLabel("Status"),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text("Active")),
                        DropdownMenuItem(value: 'inactive', child: Text("Inactive")),
                      ],
                      onChanged: (val) => setState(() => _selectedStatus = val!),
                      decoration: _inputDecoration(hint: "Status"),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: _isLoading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text("Update Branch", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel", style: GoogleFonts.inter(color: Colors.grey[600], fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF4B5563)),
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
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
    );
  }
}
