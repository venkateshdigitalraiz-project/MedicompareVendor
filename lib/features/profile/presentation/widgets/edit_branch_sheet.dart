import 'dart:convert';
import 'dart:io';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/core/utils/core_injection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import '../../data/models/branch_model.dart';
import '../bloc/branch_bloc.dart';
import '../bloc/branch_event.dart';
import '../bloc/branch_state.dart';
import '../../profile_branch_injection.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class EditBranchSheet extends StatelessWidget {
  final Branch branch;
  final VoidCallback onSuccess;

  const EditBranchSheet(
      {super.key, required this.branch, required this.onSuccess});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBranchInjection.provideBranchBloc(),
      child: _EditBranchSheetView(branch: branch, onSuccess: onSuccess),
    );
  }
}

class _EditBranchSheetView extends StatefulWidget {
  final Branch branch;
  final VoidCallback onSuccess;

  const _EditBranchSheetView(
      {super.key, required this.branch, required this.onSuccess});

  @override
  State<_EditBranchSheetView> createState() => _EditBranchSheetViewState();
}

class _EditBranchSheetViewState extends State<_EditBranchSheetView> {
  final _formKey = GlobalKey<FormState>();
  final String _googleApiKey = "AIzaSyCrQfumXF2fKkdxz0Z1SRD-9XlAthO3vZs";

  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _editableAddressController;
  late final TextEditingController _stateController;
  late final TextEditingController _mobileController;
  late final TextEditingController _emailController;
  // late final TextEditingController _pincodeController;

  String _selectedStatus = 'active';
  String _selectedRole = 'Manager';
  File? _selectedImage;

  // Google Places API state
  List<dynamic> _predictions = [];
  bool isSearchingAddress = false;

  String _selectedDeliveryPincode = '';
  List<Map<String, String>> _deliveryPincodes = [];
  bool _isLoadingPincodes = false;

  String _lat = '';
  String _lng = '';
  String _city = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.branch.name);
    _addressController = TextEditingController(text: widget.branch.address);
    _editableAddressController =
        TextEditingController(text: widget.branch.address);
    _stateController = TextEditingController(text: widget.branch.state);
    _mobileController = TextEditingController(text: widget.branch.mobile);
    _emailController = TextEditingController(text: widget.branch.email);
    _selectedStatus = widget.branch.status;

    final validRoles = [
      'Select Role',
      'Manager',
      'pharmacist',
      'nurse',
      'doctor'
    ];
    if (validRoles.contains(widget.branch.roleName)) {
      _selectedRole = widget.branch.roleName;
    } else if (validRoles.contains(widget.branch.roleName.toLowerCase())) {
      _selectedRole = widget.branch.roleName.toLowerCase();
    } else {
      _selectedRole = 'Manager';
    }

    // _pincodeController = TextEditingController(text: widget.branch.pincode);
    _selectedDeliveryPincode = widget.branch.deliveryPinCodes;

    _lat = widget.branch.lat.toString();
    _lng = widget.branch.lng.toString();
    _city = '';

    // Attempt to extract city from existing address
    if (widget.branch.address.isNotEmpty) {
      List<String> parts = widget.branch.address.split(',');
      if (parts.length >= 3) {
        _city = parts[parts.length - 3].trim();
      }
    }

    _fetchDeliveryPincodes();
  }

  Future<void> _fetchDeliveryPincodes() async {
    setState(() => _isLoadingPincodes = true);
    try {
      final apiService = CoreInjection.provideApiService();
      final response = await apiService.get('/vendor/pincode/list');
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final List list = jsonResponse['data']['list'] ?? [];
        final List<Map<String, String>> parsed = [];
        for (var item in list) {
          final id = item['_id']?.toString() ?? '';
          final pinObj = item['pincode'];
          final pinId = pinObj != null ? (pinObj['_id']?.toString() ?? '') : '';
          final name = pinObj != null && pinObj['name'] != null
              ? pinObj['name'].toString()
              : (item['name']?.toString() ?? 'Pincode');
          if (id.isNotEmpty) {
            parsed.add({'id': id, 'name': name, 'pincodeId': pinId});
          }
        }
        if (mounted) {
          setState(() {
            _deliveryPincodes = parsed;
            if (_deliveryPincodes
                .any((p) => p['id'] == _selectedDeliveryPincode)) {
              // keep it
            } else if (_deliveryPincodes.isNotEmpty) {
              _selectedDeliveryPincode = _deliveryPincodes.first['id']!;
            } else {
              _selectedDeliveryPincode = widget.branch.deliveryPinCodes;
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _selectedDeliveryPincode = widget.branch.deliveryPinCodes;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _selectedDeliveryPincode = widget.branch.deliveryPinCodes;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingPincodes = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _editableAddressController.dispose();
    _stateController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    // _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress(String query) async {
    if (query.length < 3) {
      if (_predictions.isNotEmpty) setState(() => _predictions = []);
      return;
    }

    setState(() => isSearchingAddress = true);
    try {
      final url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleApiKey&sessiontoken=branch_edit_v1";
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
      if (mounted) setState(() => isSearchingAddress = false);
    }
  }

  void _onAddressSelected(Map<String, dynamic> prediction) async {
    setState(() {
      _editableAddressController.text = prediction['description'];
      _addressController.text = prediction['description'];
      _predictions = [];
    });
    try {
      List<geocoding.Location> locations = await geocoding.Geocoding()
          .locationFromAddress(prediction['description']);
      if (locations.isNotEmpty) {
        final pos = locations.first;
        _lat = pos.latitude.toString();
        _lng = pos.longitude.toString();

        List<geocoding.Placemark> placemarks = await geocoding.Geocoding()
            .placemarkFromCoordinates(pos.latitude, pos.longitude);
        if (placemarks.isNotEmpty) {
          _city = placemarks.first.locality ?? '';
        }
      }
    } catch (_) {}
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

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    String selectedPincodeName = widget.branch.pincode;
    String selectedDeliveryPincodeId = _selectedDeliveryPincode;

    if (_selectedDeliveryPincode.isNotEmpty) {
      try {
        final selectedMap = _deliveryPincodes
            .firstWhere((p) => p['id'] == _selectedDeliveryPincode);
        selectedPincodeName = selectedMap['name'] ?? widget.branch.pincode;
        if (selectedMap['pincodeId'] != null &&
            selectedMap['pincodeId']!.isNotEmpty) {
          selectedDeliveryPincodeId = selectedMap['pincodeId']!;
        }
      } catch (_) {}
    }

    final Map<String, dynamic> payload = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "mobile": _mobileController.text.trim(),
      "address": _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : _editableAddressController.text.trim(),
      "pincode": selectedPincodeName,
      "state": _stateController.text.trim(),
      "city": _city,
      "status": _selectedStatus,
      "roleId": widget.branch.roleId, // Should match what backend expects
      "deliveryPincode": selectedDeliveryPincodeId.isNotEmpty
          ? selectedDeliveryPincodeId
          : '698f650f9f7316f72f6bf08e',
      "lat": _lat,
      "lng": _lng,
      "location": jsonEncode({
        "type": "Point",
        "coordinates": [
          double.tryParse(_lng) ?? 0.0,
          double.tryParse(_lat) ?? 0.0
        ],
        "address": _addressController.text.trim()
      }),
    };

    debugPrint("=== UPDATE BRANCH PAYLOAD ===");
    debugPrint(jsonEncode(payload));
    debugPrint("=============================");

    context.read<BranchBloc>().add(
          UpdateBranchEvent(
              branchId: widget.branch.id, data: payload, image: _selectedImage),
        );
  }

  @override
  Widget build(BuildContext context) {
    final String currentImageUrl =
        widget.branch.images.isNotEmpty ? widget.branch.images.first : "";

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: BlocConsumer<BranchBloc, BranchState>(
        listener: (context, state) {
          if (state is BranchUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(state.message,
                          style:
                              GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF15803D),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
            widget.onSuccess();
            Navigator.pop(context);
          } else if (state is BranchUpdateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(state.message,
                          style:
                              GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFFDC2626),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is BranchLoading;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edit Branch",
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E1B4B)),
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
                          decoration:
                              _inputDecoration(hint: "Digitalraiz Sub-Branch"),
                          validator: (val) =>
                              (val == null || val.isEmpty) ? "Required" : null,
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
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(_selectedImage!,
                                          fit: BoxFit.cover))
                                  : currentImageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(currentImageUrl,
                                              fit: BoxFit.cover))
                                      : const Icon(Icons.business,
                                          color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                OutlinedButton(
                                  onPressed: _pickImage,
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text("Change Image",
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1E1B4B))),
                                ),
                                const SizedBox(height: 4),
                                Text("JPG, PNG or GIF. Max 2MB.",
                                    style: GoogleFonts.inter(
                                        fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            // Expanded(
                            //   child: Column(
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       _buildLabel("Pincode", isRequired: true),
                            //       const SizedBox(height: 8),
                            //       TextFormField(
                            //         controller: _pincodeController,
                            //         decoration:
                            //             _inputDecoration(hint: "Enter branch Pincode"),
                            //         validator: (val) =>
                            //             (val == null || val.isEmpty) ? "Required" : null,
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Deliverable Pincode"),
                                  const SizedBox(height: 8),
                                  _isLoadingPincodes
                                      ? const SizedBox(
                                          height: 48,
                                          child: Center(
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2)),
                                        )
                                      : _deliveryPincodes.isNotEmpty
                                          ? DropdownButtonFormField<String>(
                                              value: _deliveryPincodes.any((p) =>
                                                      p['id'] ==
                                                      _selectedDeliveryPincode)
                                                  ? _selectedDeliveryPincode
                                                  : _deliveryPincodes
                                                      .first['id'],
                                              isExpanded: true,
                                              items: _deliveryPincodes.map((p) {
                                                return DropdownMenuItem<String>(
                                                  value: p['id'],
                                                  child: Text(
                                                    p['name'] ?? '',
                                                    style: GoogleFonts.inter(
                                                        fontSize: 13),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setState(() =>
                                                      _selectedDeliveryPincode =
                                                          val);
                                                }
                                              },
                                              decoration: _inputDecoration(
                                                  hint: "Select Pincode"),
                                            )
                                          : TextFormField(
                                              initialValue:
                                                  _selectedDeliveryPincode,
                                              onChanged: (val) =>
                                                  _selectedDeliveryPincode =
                                                      val,
                                              decoration: _inputDecoration(
                                                  hint: "Delivery ID"),
                                            ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildLabel("Branch Address", isRequired: true),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressController,
                          decoration:
                              _inputDecoration(hint: "Enter branch address"),
                          validator: (val) =>
                              (val == null || val.isEmpty) ? "Required" : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel("Branch Address (Editable)",
                            isRequired: true),
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            TextFormField(
                              controller: _editableAddressController,
                              maxLines: 3,
                              onChanged: _searchAddress,
                              decoration: _inputDecoration(
                                  hint:
                                      "Address will be auto-filled from Google Maps or enter manually"),
                            ),
                            if (_predictions.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 80),
                                constraints:
                                    const BoxConstraints(maxHeight: 200),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10)
                                  ],
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: _predictions.length,
                                  separatorBuilder: (_, __) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final p = _predictions[index];
                                    return ListTile(
                                      dense: true,
                                      title: Text(p['description'],
                                          style:
                                              GoogleFonts.inter(fontSize: 12)),
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
                                    validator: (val) =>
                                        (val == null || val.isEmpty)
                                            ? "Required"
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Contact Number",
                                      isRequired: true),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _mobileController,
                                    keyboardType: TextInputType.phone,
                                    decoration:
                                        _inputDecoration(hint: "7777777777"),
                                    validator: (val) =>
                                        (val == null || val.isEmpty)
                                            ? "Required"
                                            : null,
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
                                    decoration: _inputDecoration(
                                        hint: "digi@gmail.com"),
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
                                      DropdownMenuItem(
                                          value: 'Select Role',
                                          child: Text("Select Role")),
                                      DropdownMenuItem(
                                          value: 'Manager',
                                          child: Text("Manager")),
                                      DropdownMenuItem(
                                          value: 'pharmacist',
                                          child: Text("pharmacist")),
                                      DropdownMenuItem(
                                          value: 'nurse', child: Text("nurse")),
                                      DropdownMenuItem(
                                          value: 'doctor',
                                          child: Text("doctor")),
                                    ],
                                    onChanged: (val) =>
                                        setState(() => _selectedRole = val!),
                                    decoration:
                                        _inputDecoration(hint: "Select Role"),
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
                            DropdownMenuItem(
                                value: 'active', child: Text("Active")),
                            DropdownMenuItem(
                                value: 'inactive', child: Text("Inactive")),
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedStatus = val!),
                          decoration: _inputDecoration(hint: "Status"),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : Text("Update Branch",
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel",
                                style: GoogleFonts.inter(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ); // closes Column
        }, // closes builder
      ), // closes BlocConsumer
    ); // closes Container
  } // closes build method

  Widget _buildLabel(String text, {bool isRequired = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF4B5563)),
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
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary)),
    );
  }
}
