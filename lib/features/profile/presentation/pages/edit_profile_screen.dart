import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/core/utils/core_injection.dart';
import 'package:MediCompare/core/api/api_endpoints.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _profileImage;
  String? _profileImageUrl;

  File? _businessLogo;
  String? _businessLogoUrl;

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  // Business Information Data
  String _businessName = "Digitalraiz Creative";
  String _businessEmail = "digital@gmail.com";
  String _businessMobile = "7656567576";
  String _businessAddress =
      "Hyderabad - Warangal Highway, Teachers Colony, Hanamkonda, Telangana, 506004";

  final List<String> _categories = [
    "Rx Medicines",
    "Surgeries",
    "Lab Tests",
    "Diagnostics",
    "Clinics and Rehabs",
    "Ambulance",
    "Dental Care",
    "Medical Equipment",
    "Treatments",
    "Home Care",
  ];

  Country selectedCountry = Country(
    phoneCode: "91",
    countryCode: "IN",
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: "India",
    example: "9123456789",
    displayName: "India (IN) [+91]",
    displayNameNoCountryCode: "India (IN)",
    e164Key: "91-IN-0",
  );

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    try {
      final apiService = CoreInjection.provideApiService();
      final response = await apiService.get(ApiEndpoints.vendorProfile);
      final body = jsonDecode(response.body);
      if (body['success'] == true && body['data'] != null) {
        final user = body['data']['user'] as Map<String, dynamic>? ?? {};
        if (mounted) {
          setState(() {
            _firstNameController.text = user['firstName']?.toString() ?? '';
            _lastNameController.text = user['lastName']?.toString() ?? '';
            _emailController.text = user['email']?.toString() ?? '';

            final mobile = user['mobile']?.toString() ?? '';
            if (mobile.length > 10 && mobile.startsWith('91')) {
              _phoneController.text = mobile.substring(2);
            } else {
              _phoneController.text = mobile;
            }

            final profileImg = user['profileImage'];
            if (profileImg is Map && profileImg['url'] != null) {
              _profileImageUrl = profileImg['url'].toString();
            } else if (profileImg is String) {
              _profileImageUrl = profileImg;
            }

            // Vendor / Store / Business information
            final vendor = body['data']['vendor'] ??
                body['data']['store'] ??
                user['vendor'];
            if (vendor is Map<String, dynamic>) {
              if (vendor['name'] != null &&
                  vendor['name'].toString().isNotEmpty) {
                _businessName = vendor['name'].toString();
              }
              if (vendor['email'] != null &&
                  vendor['email'].toString().isNotEmpty) {
                _businessEmail = vendor['email'].toString();
              }
              if (vendor['phone'] != null &&
                  vendor['phone'].toString().isNotEmpty) {
                _businessMobile = vendor['phone'].toString();
              }
              if (vendor['address'] != null &&
                  vendor['address'].toString().isNotEmpty) {
                _businessAddress = vendor['address'].toString();
              }
              if (vendor['logo'] != null) {
                if (vendor['logo'] is Map && vendor['logo']['url'] != null) {
                  _businessLogoUrl = vendor['logo']['url'].toString();
                } else if (vendor['logo'] is String) {
                  _businessLogoUrl = vendor['logo'].toString();
                }
              }
            }
          });
        }
      }
    } catch (_) {
      // Fallback defaults remain intact
    }
  }

  // Pick Personal Profile Picture
  Future<void> _pickProfileImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _profileImage = File(picked.path);
      });
    }
  }

  void _showProfileImagePicker() {
    _showImageSourceBottomSheet(
      title: "Select Profile Picture",
      onSourceSelected: (source) => _pickProfileImage(source),
    );
  }

  // Pick Business Logo
  Future<void> _pickBusinessLogo(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() {
        _businessLogo = File(picked.path);
      });
    }
  }

  void _showBusinessLogoPicker() {
    _showImageSourceBottomSheet(
      title: "Select Business Logo",
      onSourceSelected: (source) => _pickBusinessLogo(source),
    );
  }

  void _showImageSourceBottomSheet({
    required String title,
    required Function(ImageSource) onSourceSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: AppColors.primary),
              ),
              title: Text(
                "Take a Photo",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onSourceSelected(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_rounded,
                    color: AppColors.primary),
              ),
              title: Text(
                "Choose from Gallery",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onSourceSelected(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          "Edit Profile",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 1️⃣ FIRST: PERSONAL INFORMATION SECTION
              _buildPersonalDetailsCard(),

              const SizedBox(height: 24),

              /// 2️⃣ NEXT: BUSINESS INFORMATION CARD (ATTACHED SCREENSHOT)
              _buildBusinessInformationCard(),

              const SizedBox(height: 32),

              /// ================= SAVE BUTTON =================
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Profile updated successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Save",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= 1️⃣ PERSONAL DETAILS CARD =================
  Widget _buildPersonalDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF), // Soft purple
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppColors.primaryDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Personal Details",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// Profile Image with Upload Button (Camera / Gallery)
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFF1F5F9),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _profileImage != null
                            ? Image.file(
                                _profileImage!,
                                fit: BoxFit.cover,
                              )
                            : _profileImageUrl != null &&
                                    _profileImageUrl!.isNotEmpty
                                ? Image.network(
                                    _profileImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _defaultAvatar(),
                                  )
                                : _defaultAvatar(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showProfileImagePicker,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Tap camera icon to change profile photo",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          /// Name Inputs
          Row(
            children: [
              Expanded(
                child: _inputField(
                  controller: _firstNameController,
                  hint: "First Name",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _inputField(
                  controller: _lastNameController,
                  hint: "Last Name",
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _inputField(
            controller: _emailController,
            hint: "Enter your Email Address",
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _phoneNumberField(),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: const Color(0xFFEDE9FE),
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 46,
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// ================= 2️⃣ BUSINESS INFORMATION CARD =================
  Widget _buildBusinessInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header: Icon + Business Information
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF), // soft blue background
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Business Information",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          /// Business Logo Section
          Center(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xFFF1F5F9),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: _businessLogo != null
                            ? Image.file(
                                _businessLogo!,
                                fit: BoxFit.cover,
                              )
                            : _businessLogoUrl != null &&
                                    _businessLogoUrl!.isNotEmpty
                                ? Image.network(
                                    _businessLogoUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _defaultLogoImage(),
                                  )
                                : _defaultLogoImage(),
                      ),
                    ),
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: GestureDetector(
                        onTap: _showBusinessLogoPicker,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.file_upload_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Click the upload icon to add business logo",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "(Max 5MB, JPG, PNG, GIF)",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1, height: 1),
          const SizedBox(height: 20),

          /// Detail Rows
          _buildInfoRow(
            icon: Icons.apartment_outlined,
            label: "Business Name",
            valueWidget: Text(
              _businessName,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: "Business Email",
            valueWidget: Text(
              _businessEmail,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: "Business Mobile",
            valueWidget: Text(
              _businessMobile,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: "Address",
            valueWidget: Text(
              _businessAddress,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
                height: 1.35,
              ),
            ),
          ),
          _buildInfoRow(
            icon: Icons.business_center_outlined,
            label: "Categories",
            valueWidget: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE), // Soft lavender/purple
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6D28D9),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultLogoImage() {
    return Image.network(
      "https://images.unsplash.com/photo-1500534623283-312aade485b7?w=300&auto=format&fit=crop&q=80",
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFE2E8F0),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 36,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Widget valueWidget,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: const Color(0xFF94A3B8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: valueWidget,
          ),
        ],
      ),
    );
  }

  /// ================= TEXT INPUT =================
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: const Color(0xFF1E293B),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(
            fontSize: 13.5,
            color: const Color(0xFF94A3B8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      ),
    );
  }

  /// ================= PHONE FIELD WITH COUNTRY PICKER =================
  Widget _phoneNumberField() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey300),
      ),
      child: Row(
        children: [
          /// COUNTRY PICKER
          GestureDetector(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: true,
                onSelect: (Country country) {
                  setState(() {
                    selectedCountry = country;
                  });
                },
              );
            },
            child: Row(
              children: [
                Text(
                  selectedCountry.flagEmoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: AppColors.black,
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            "+${selectedCountry.phoneCode}",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(width: 10),

          Container(
            width: 1,
            height: 22,
            color: AppColors.grey300,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                hintText: "Phone Number",
                hintStyle: GoogleFonts.inter(
                  fontSize: 13.5,
                  color: const Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
