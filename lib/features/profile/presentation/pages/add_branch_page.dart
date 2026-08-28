import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/core/utils/core_injection.dart';
import '../bloc/branch_bloc.dart';
import '../bloc/branch_event.dart';
import '../bloc/branch_state.dart';
import '../../profile_branch_injection.dart';

class AddBranchPage extends StatelessWidget {
  const AddBranchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBranchInjection.provideBranchBloc(),
      child: const _AddBranchView(),
    );
  }
}

class _AddBranchView extends StatefulWidget {
  const _AddBranchView();

  @override
  State<_AddBranchView> createState() => _AddBranchViewState();
}

class _AddBranchViewState extends State<_AddBranchView> {
  final _formKey = GlobalKey<FormState>();
  final String _googleApiKey = "AIzaSyCrQfumXF2fKkdxz0Z1SRD-9XlAthO3vZs";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _editableAddressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController(text: "telangana");
  final TextEditingController _pincodeController = TextEditingController();

  String _selectedStatus = 'active';
  String _selectedRoleId = '6980ea3f6b9b1c829e39d1fd';
  String _selectedDeliveryPincode = '';
  File? _selectedImage;
  bool _obscurePassword = true;

  List<dynamic> _predictions = [];
  bool _isSearchingAddress = false;

  // Delivery Pincodes from API
  List<Map<String, String>> _deliveryPincodes = [];
  bool _isLoadingPincodes = false;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryPincodes();
  }

  Future<void> _fetchDeliveryPincodes() async {
    setState(() => _isLoadingPincodes = true);
    try {
      final apiService = CoreInjection.provideApiService();
      final response = await apiService.get(ApiEndpoints.pincodeList);
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final List list = jsonResponse['data']['list'] ?? [];
        final List<Map<String, String>> parsed = [];
        for (var item in list) {
          final id = item['_id']?.toString() ?? '';
          final pinObj = item['pincode'];
          final name = pinObj != null && pinObj['name'] != null
              ? pinObj['name'].toString()
              : (item['name']?.toString() ?? 'Pincode');
          if (id.isNotEmpty) {
            parsed.add({'id': id, 'name': name});
          }
        }
        if (mounted) {
          setState(() {
            _deliveryPincodes = parsed;
            if (_deliveryPincodes.isNotEmpty) {
              _selectedDeliveryPincode = _deliveryPincodes.first['id']!;
            } else {
              _selectedDeliveryPincode = '698f650f9f7316f72f6bf08e';
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _selectedDeliveryPincode = '698f650f9f7316f72f6bf08e';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _selectedDeliveryPincode = '698f650f9f7316f72f6bf08e';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingPincodes = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    _editableAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress(String query) async {
    if (query.trim().length < 3) {
      if (_predictions.isNotEmpty) setState(() => _predictions = []);
      return;
    }

    setState(() => _isSearchingAddress = true);
    try {
      final url =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleApiKey&sessiontoken=branch_add_v1";
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
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Select Branch Image",
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E1B4B),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(modalContext);
                      _pickImage(ImageSource.camera);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEEF2FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Color(0xFF4F46E5), size: 24),
                          ),
                          const SizedBox(height: 8),
                          Text("Camera",
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(modalContext);
                      _pickImage(ImageSource.gallery);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEEF2FF),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.photo_library_rounded,
                                color: Color(0xFF4F46E5), size: 24),
                          ),
                          const SizedBox(height: 8),
                          Text("Gallery",
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> payload = {
      "name": _nameController.text.trim(),
      "email": _emailController.text.trim(),
      "mobile": _mobileController.text.trim(),
      "address": _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : _editableAddressController.text.trim(),
      "city": _cityController.text.trim(),
      "state": _stateController.text.trim(),
      "pincode": _pincodeController.text.trim(),
      "status": _selectedStatus,
      "deliveryPincode": _selectedDeliveryPincode.isNotEmpty
          ? _selectedDeliveryPincode
          : '698f650f9f7316f72f6bf08e',
      "password": _passwordController.text.trim(),
      "roleId": _selectedRoleId,
    };

    context.read<BranchBloc>().add(
          CreateBranchEvent(data: payload, image: _selectedImage),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              "Add New Branch",
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Register branch details & credentials",
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<BranchBloc, BranchState>(
        listener: (context, state) {
          if (state is BranchCreateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(state.message,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF15803D),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
            Navigator.pop(context, true);
          } else if (state is BranchCreateFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(state.message,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Branch Details & Image Card
                  _buildSectionCard(
                    title: "Branch Identity",
                    subtitle: "Name, storefront image and basic info",
                    icon: Icons.storefront_outlined,
                    children: [
                      _buildLabel("Branch Name", isRequired: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration(
                          hint: "e.g., venkatesh digitalraiz",
                          prefixIcon: Icons.business_rounded,
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? "Branch name is required"
                            : null,
                      ),
                      const SizedBox(height: 18),
                      _buildLabel("Branch Image (Optional)"),
                      const SizedBox(height: 10),
                      _buildImageUploader(),
                    ],
                  ),

                  // 2. Authentication & Contact Credentials Card
                  _buildSectionCard(
                    title: "Credentials & Contact",
                    subtitle: "Login credentials and communication channel",
                    icon: Icons.lock_outline_rounded,
                    children: [
                      _buildLabel("Branch Email", isRequired: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(
                          hint: "e.g., tester@digitalraiz.com",
                          prefixIcon: Icons.email_outlined,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Email is required";
                          }
                          if (!val.contains('@') || !val.contains('.')) {
                            return "Enter a valid email address";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildLabel("Branch Password", isRequired: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _inputDecoration(
                          hint: "Enter branch password (e.g. 123456)",
                          prefixIcon: Icons.lock_rounded,
                          suffixWidget: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? "Password is required"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel("Mobile Number", isRequired: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(
                          hint: "e.g., 9991233456",
                          prefixIcon: Icons.phone_android_rounded,
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Mobile number is required";
                          }
                          if (val.trim().length < 8) {
                            return "Enter a valid mobile number";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  // 3. Location & Address Card
                  _buildSectionCard(
                    title: "Location & Address",
                    subtitle: "Street address, city, state, and pincode",
                    icon: Icons.location_on_outlined,
                    children: [
                      _buildLabel("Branch Address", isRequired: true),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        decoration: _inputDecoration(
                          hint: "e.g., sdggfdfgsfsf",
                          prefixIcon: Icons.place_outlined,
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? "Branch address is required"
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildLabel("Search Address with Maps (Auto-fill)"),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          TextFormField(
                            controller: _editableAddressController,
                            maxLines: 2,
                            onChanged: _searchAddress,
                            decoration: _inputDecoration(
                              hint: "Type to search address on Maps...",
                              prefixIcon: Icons.map_outlined,
                              suffixWidget: _isSearchingAddress
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          if (_predictions.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 70),
                              constraints: const BoxConstraints(maxHeight: 220),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _predictions.length,
                                separatorBuilder: (_, __) =>
                                    Divider(height: 1, color: Colors.grey.shade100),
                                itemBuilder: (context, index) {
                                  final p = _predictions[index];
                                  return ListTile(
                                    dense: true,
                                    leading: const Icon(Icons.location_pin,
                                        size: 18, color: Color(0xFF6B48FF)),
                                    title: Text(
                                      p['description'],
                                      style: GoogleFonts.inter(
                                          fontSize: 13, color: Colors.black87),
                                    ),
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
                                _buildLabel("City"),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _cityController,
                                  decoration: _inputDecoration(
                                    hint: "e.g., Hyderabad",
                                    prefixIcon: Icons.location_city_rounded,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("State", isRequired: true),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _stateController,
                                  decoration: _inputDecoration(
                                    hint: "e.g., telangana",
                                    prefixIcon: Icons.public_rounded,
                                  ),
                                  validator: (val) =>
                                      (val == null || val.trim().isEmpty)
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
                                _buildLabel("Pincode"),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _pincodeController,
                                  keyboardType: TextInputType.number,
                                  decoration: _inputDecoration(
                                    hint: "e.g., 500081",
                                    prefixIcon: Icons.pin_drop_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Delivery Pincode"),
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
                                                : _deliveryPincodes.first['id'],
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
                                              hint: "Select Pincode",
                                              prefixIcon:
                                                  Icons.local_shipping_outlined,
                                            ),
                                          )
                                        : TextFormField(
                                            initialValue:
                                                _selectedDeliveryPincode,
                                            onChanged: (val) =>
                                                _selectedDeliveryPincode = val,
                                            decoration: _inputDecoration(
                                              hint: "Delivery ID",
                                              prefixIcon:
                                                  Icons.local_shipping_outlined,
                                            ),
                                          ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // 4. Role & Status Card
                  _buildSectionCard(
                    title: "Role & Branch Status",
                    subtitle: "Assigned management role and activation status",
                    icon: Icons.admin_panel_settings_outlined,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Role (roleId)"),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedRoleId,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                      value: '6980ea3f6b9b1c829e39d1fd',
                                      child: Text("Manager"),
                                    ),
                                    DropdownMenuItem(
                                      value: '6980ea3f6b9b1c829e39d1fe',
                                      child: Text("Pharmacist"),
                                    ),
                                    DropdownMenuItem(
                                      value: '6980ea3f6b9b1c829e39d1ff',
                                      child: Text("Nurse"),
                                    ),
                                    DropdownMenuItem(
                                      value: '6980ea3f6b9b1c829e39d200',
                                      child: Text("Doctor"),
                                    ),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => _selectedRoleId = val!),
                                  decoration: _inputDecoration(
                                    hint: "Select Role",
                                    prefixIcon: Icons.badge_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel("Branch Status"),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedStatus,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'active',
                                        child: Text("Active")),
                                    DropdownMenuItem(
                                        value: 'inactive',
                                        child: Text("Inactive")),
                                  ],
                                  onChanged: (val) =>
                                      setState(() => _selectedStatus = val!),
                                  decoration: _inputDecoration(
                                    hint: "Status",
                                    prefixIcon: Icons.toggle_on_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Actions Row
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6B48FF), Color(0xFF2D1B69)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6B48FF).withOpacity(0.3),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.add_business_rounded,
                                            color: Colors.white, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Create Branch",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageUploader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_selectedImage!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.storefront_rounded,
                    color: Color(0xFF4F46E5), size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedImage != null
                      ? "Image Selected"
                      : "Upload branch storefront",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "PNG, JPG or WEBP up to 5MB",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: _showImagePickerSheet,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedImage != null ? "Change Image" : "Select Image",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (_selectedImage != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => setState(() => _selectedImage = null),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Remove",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF4F46E5), size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E1B4B),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          ...children,
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
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        if (isRequired)
          Text(
            " *",
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
    Widget? suffixWidget,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.grey.shade500, size: 19)
          : null,
      suffixIcon: suffixWidget,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade300),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }
}
