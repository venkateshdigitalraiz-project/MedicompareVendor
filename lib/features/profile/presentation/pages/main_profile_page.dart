import 'dart:convert';
import 'dart:io';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/core/utils/token_storage.dart';
import 'package:MediCompare/core/utils/core_injection.dart';
import 'package:MediCompare/core/api/api_endpoints.dart';
import 'package:MediCompare/core/models/permission_model.dart';
import 'package:MediCompare/core/utils/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class MainprofileScreen extends StatefulWidget {
  const MainprofileScreen({super.key});

  @override
  State<MainprofileScreen> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<MainprofileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Profile data
  bool _isLoading = true;
  String _firstName = '';
  String _lastName = '';
  String _mobile = '';
  String _email = '';
  String? _profileImageUrl;
  List<String> _activeModules = [];

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final apiService = CoreInjection.provideApiService();
      final response = await apiService.get(ApiEndpoints.vendorProfile);
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        final user = body['data']['user'] as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _firstName = user['firstName']?.toString() ?? '';
            _lastName = user['lastName']?.toString() ?? '';
            final mobile = user['mobile'];
            // Mobile may have country code prefix (e.g. 919010879221) — strip leading 91
            String mobileStr = mobile?.toString() ?? '';
            if (mobileStr.length > 10 && mobileStr.startsWith('91')) {
              mobileStr = '+91 ${mobileStr.substring(2)}';
            } else if (mobileStr.isNotEmpty) {
              mobileStr = '+$mobileStr';
            }
            _mobile = mobileStr;
            _email = user['email']?.toString() ?? '';
            final profileImg = user['profileImage'];
            if (profileImg is Map && profileImg['url'] != null) {
              _profileImageUrl = profileImg['url'].toString();
            }

            // Parse permissions
            final permissionsData =
                body['data']['permission'] as List<dynamic>? ?? [];
            final List<PermissionModel> permissions = permissionsData
                .map((p) => PermissionModel.fromJson(p))
                .toList();

            PermissionHandler().setPermissions(permissions);

            _activeModules = permissions
                .where((p) => p.status == 'active' && p.hasAction('view'))
                .map((p) => p.module)
                .toList();

            // debugPrint('VENDOR_PERMISSIONS_MODULES: $_activeModules');

            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile =
        await _picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() => _profileImage = file);
      await _uploadProfilePicture(file);
    }
  }

  Future<void> _uploadProfilePicture(File file) async {
    setState(() => _isUploading = true);
    try {
      final apiService = CoreInjection.provideApiService();
      final response = await apiService.post(
        ApiEndpoints.updateProfilePicture,
        files: {'image': file},
      );
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        // Refresh profile to get new URL from server
        await _fetchProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile picture updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(body['message']?.toString() ?? 'Upload failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Camera"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _hasPermission(String module, {String action = 'view'}) {
    if (_isLoading) return true;
    return PermissionHandler().hasPermission(module, action);
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fullName =
        [_firstName, _lastName].where((s) => s.isNotEmpty).join(' ');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.white),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          "Profile",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 22),

            /// PROFILE IMAGE + INFO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.primaryDark,
                        child: CircleAvatar(
                          radius: 39,
                          backgroundImage: _buildProfileImage(),
                          child: _isLoading || _isUploading
                              ? Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black38,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showImagePicker,
                        child: const CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.white,
                          child: Icon(Icons.camera_alt, size: 16),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 16),

                  /// NAME + CONTACT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _isLoading
                            ? Container(
                                width: 120,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              )
                            : Text(
                                fullName.isNotEmpty ? fullName : 'Vendor',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                        const SizedBox(height: 6),
                        if (_isLoading) ...[
                          Container(
                              width: 140,
                              height: 12,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(6))),
                          const SizedBox(height: 4),
                          Container(
                              width: 160,
                              height: 12,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(6))),
                        ] else ...[
                          if (_mobile.isNotEmpty) _infoRow(Icons.call, _mobile),
                          const SizedBox(height: 4),
                          if (_email.isNotEmpty) _infoRow(Icons.mail, _email),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            _menuTile("Change Password", Icons.remove_red_eye_outlined, () {
              context.push('/change-password');
            }),
            _menuTile("Orders", Icons.shopping_bag_outlined, () {
              context.push('/orders');
            }),
            _menuTile("Rental bookings", Icons.calendar_today_outlined, () {
              context.push('/rental-orders');
            }),
            _menuTile("Appointment Booking", Icons.medical_services_rounded,
                () {
              context.push('/appointment');
            }),
            _menuTile("Leads", Icons.leaderboard_outlined, () {
              context.push('/leads');
            }),
            _menuTile("Branches", Icons.business_outlined, () {
              context.push('/branches');
            }),
            if (!Platform.isIOS)
              _menuTile("My Subscription Plan", Icons.subscriptions_outlined,
                  () {
                context.push('/subscription-plan');
                // howSubscriptionUpgradeDialog();
              }),
            _menuTile("My Lead Plan History", Icons.history_edu_outlined, () {
              context.push('/lead-plan-history');
            }),
            if (_hasPermission('medicine'))
              _menuTile("Medicines", Icons.medication_outlined, () {
                context.push('/medicine-list');
              }),
            if (_hasPermission('surgeries'))
              _menuTile("Surgeries", Icons.show_chart, () {
                context.push('/surgery-list');
              }),
            if (_hasPermission('lab-tests'))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ExpansionTile(
                  leading: const Icon(Icons.science_outlined,
                      color: AppColors.primaryDark),
                  title:
                      Text("Lab Tests", style: GoogleFonts.inter(fontSize: 14)),
                  shape: const Border(),
                  childrenPadding: const EdgeInsets.only(left: 32),
                  trailing: const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.primaryDark),
                  children: [
                    _menuTile("List", Icons.list_alt_outlined, () {
                      context.push('/lab-test-list');
                    }, isSubTile: true),
                    _menuTile("Packages", Icons.inventory_2_outlined, () {
                      context.push('/lab-test-package-list');
                    }, isSubTile: true),
                  ],
                ),
              ),
            if (_hasPermission('diagnostics'))
              _menuTile("Diagnostics", Icons.biotech_outlined, () {
                context.push('/diagnostic-list');
              }),
            if (_hasPermission('home-care'))
              _menuTile(
                  "Home Care Services", Icons.home_repair_service_outlined, () {
                context.push('/homecare-list');
              }),
            if (_hasPermission('nursing-care'))
              _menuTile("Care Taker Services", Icons.person_search_outlined,
                  () {
                context.push('/nursing-list');
              }),
            if (_hasPermission('dental-service'))
              _menuTile(
                  "Odontogram Services", Icons.sentiment_satisfied_alt_outlined,
                  () {
                context.push('/dental-list');
              }),
            if (_hasPermission('medical-treatment'))
              _menuTile("Medical Treatment Services",
                  Icons.health_and_safety_outlined, () {
                context.push('/medical-treatment-list');
              }),
            if (_hasPermission('medical-equipment'))
              _menuTile(
                  "Medical Equipment Services", Icons.medical_services_outlined,
                  () {
                context.push('/equipment-list');
              }),
            if (_hasPermission('ambulance-service'))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ExpansionTile(
                  leading: const Icon(Icons.airport_shuttle_outlined,
                      color: AppColors.primaryDark),
                  title:
                      Text("Ambulance", style: GoogleFonts.inter(fontSize: 14)),
                  shape: const Border(),
                  childrenPadding: const EdgeInsets.only(left: 32),
                  trailing: const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.primaryDark),
                  children: [
                    _menuTile("List", Icons.list_alt_outlined, () {
                      context.push('/ambulance-list');
                    }, isSubTile: true),
                    _menuTile("Orders", Icons.shopping_cart_outlined, () {
                      context.push('/ambulance-orders');
                    }, isSubTile: true),
                  ],
                ),
              ),
            _menuTile("Support & Help Center", Icons.support_agent, () {
              context.push('/support-ticket');
            }),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExpansionTile(
                leading: const Icon(Icons.gavel_outlined,
                    color: AppColors.primaryDark),
                title: Text("Legal Information",
                    style: GoogleFonts.inter(fontSize: 14)),
                shape: const Border(),
                childrenPadding: const EdgeInsets.only(left: 32),
                trailing: const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.primaryDark),
                children: [
                  _menuTile("Terms and Conditions", Icons.description_outlined,
                      () {
                    context.push(
                      '/webview',
                      extra: {
                        'url':
                            'https://vendor.medicompares.com/terms-and-conditions',
                        'title': 'Terms and Conditions'
                      },
                    );
                  }, isSubTile: true),
                  _menuTile("Privacy Policy", Icons.privacy_tip_outlined, () {
                    context.push(
                      '/webview',
                      extra: {
                        'url': 'https://vendor.medicompares.com/privacy-policy',
                        'title': 'Privacy Policy'
                      },
                    );
                  }, isSubTile: true),
                ],
              ),
            ),

            const SizedBox(height: 55),

            /// LOGOUT BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.logout, color: AppColors.white),
                label: Text(
                  "Log Out",
                  style: GoogleFonts.inter(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: _showLogoutDialog,
              ),
            ),

            const SizedBox(height: 12),

            /// DELETE ACCOUNT BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton(
                onPressed: _showDeleteAccountDialog,
                child: Text(
                  "Delete Account",
                  style: GoogleFonts.inter(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                "Version 1.0.0 (1)",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                "© 2026 MediCompares. All rights reserved.",
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  ImageProvider? _buildProfileImage() {
    if (_profileImage != null) return FileImage(_profileImage!);
    if (_profileImageUrl != null) return NetworkImage(_profileImageUrl!);
    return const AssetImage("assets/profile.png");
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Logout",
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18)),
          content: Text("Are you sure you want to log out of your account?",
              style: GoogleFonts.inter(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",
                  style: GoogleFonts.inter(
                      color: AppColors.grey, fontWeight: FontWeight.w500)),
            ),
            TextButton(
              onPressed: () async {
                await TokenStorage.clearAll();
                if (context.mounted) {
                  Navigator.pop(context);
                  context.go('/login');
                }
              },
              child: Text("Logout",
                  style: GoogleFonts.inter(
                      color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text("Delete Account",
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18)),
          content: Text(
              "Are you sure you want to delete your account? Your account will be permanently deleted within 30 days. This action cannot be undone.",
              style: GoogleFonts.inter(fontSize: 14)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel",
                  style: GoogleFonts.inter(
                      color: AppColors.grey, fontWeight: FontWeight.w500)),
            ),
            TextButton(
              onPressed: () async {
                // Perform logout as requested
                await TokenStorage.clearAll();
                if (context.mounted) {
                  Navigator.pop(context);
                  context.go('/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Your account deletion request has been submitted.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text("Delete",
                  style: GoogleFonts.inter(
                      color: Colors.red, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  Widget _menuTile(String title, IconData icon, VoidCallback onTap,
      {bool isSubTile = false}) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isSubTile ? 0 : 16, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSubTile ? Colors.transparent : AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon,
                  color: AppColors.primaryDark, size: isSubTile ? 20 : 24),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(title,
                      style: GoogleFonts.inter(fontSize: isSubTile ? 13 : 14))),
              if (!isSubTile)
                const Icon(Icons.chevron_right, color: AppColors.primaryDark),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubscriptionUpgradeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text(
            "Subscription Upgrade",
            style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          content: Text(
            "To upgrade your plan and unlock additional features, please contact our support team.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/support-ticket');
                    },
                    child: Text(
                      "Contact Support",
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Close",
                      style: GoogleFonts.inter(
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primaryDark),
          const SizedBox(width: 6),
          Flexible(
              child: Text(text,
                  style: GoogleFonts.inter(fontSize: 12),
                  overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
