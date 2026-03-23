import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:MediCompare/core/utils/token_storage.dart';

class MainprofileScreen extends StatefulWidget {
  const MainprofileScreen({super.key});

  @override
  State<MainprofileScreen> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<MainprofileScreen> {
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  /// PICK IMAGE FUNCTION
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  /// IMAGE PICKER BOTTOM SHEET
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
          "Profile",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 22),

            /// PROFILE IMAGE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.primaryDark,
                        child: CircleAvatar(
                          radius: 39,
                          backgroundImage: _profileImage != null
                              ? FileImage(_profileImage!)
                              : const AssetImage("assets/profile.png")
                                  as ImageProvider,
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

                  /// NAME + DETAILS
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Aman Sharma",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _infoRow(Icons.call, "+91 7891126542"),
                      const SizedBox(height: 4),
                      _infoRow(Icons.mail, "swarna@gmail.com"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// MENU OPTIONS
            _menuTile("Edit Profile", Icons.person_outline, () {
              context.push('/edit-profile');
            }),
            _menuTile("Change Password", Icons.remove_red_eye_outlined, () {
              context.push('/change-password');
            }),
            _menuTile("My Subscription Plan", Icons.subscriptions_outlined, () {
              context.push('/subscription-plan');
            }),
            _menuTile("My Lead Plan History", Icons.history_edu_outlined, () {
              context.push('/lead-plan-history');
            }),
            _menuTile("Medicines", Icons.medication_outlined, () {
              context.push('/medicine-list');
            }),
            _menuTile("Surgeries", Icons.show_chart, () {
              context.push('/surgery-list');
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ExpansionTile(
                leading: const Icon(Icons.science_outlined, color: AppColors.primaryDark),
                title: Text("Lab Tests", style: GoogleFonts.inter(fontSize: 14)),
                shape: const Border(),
                childrenPadding: const EdgeInsets.only(left: 32),
                trailing: const Icon(Icons.keyboard_arrow_down, color: AppColors.primaryDark),
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
            _menuTile("Diagnostics", Icons.biotech_outlined, () {
              context.push('/diagnostic-list');
            }),
            _menuTile("Home Care Services", Icons.home_repair_service_outlined, () {
              context.push('/homecare-list');
            }),
            _menuTile("Care Taker Services", Icons.person_search_outlined, () {
              context.push('/nursing-list');
            }),
            _menuTile("Odontogram Services", Icons.sentiment_satisfied_alt_outlined, () {
              context.push('/dental-list');
            }),
            _menuTile("Medical Treatment Services", Icons.health_and_safety_outlined, () {
              context.push('/medical-treatment-list');
            }),
            _menuTile("Medical Equipment Services", Icons.medical_services_outlined, () {
              context.push('/equipment-list');
            }),
            _menuTile("Ambulance", Icons.airport_shuttle_outlined, () {
              context.push('/ambulance-list');
            }),
            _menuTile("Support & Help Center", Icons.support_agent, () {
              context.push('/support-ticket');
            }),

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
                onPressed: () {
                  _showLogoutDialog();
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 🚪 LOGOUT CONFIRMATION DIALOG
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Logout",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
          content: Text(
            "Are you sure you want to log out of your account?",
            style: GoogleFonts.inter(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: GoogleFonts.inter(
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await TokenStorage.clearAll();
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  context.go('/login'); // Navigate to login
                }
              },
              child: Text(
                "Logout",
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _menuTile(String title, IconData icon, VoidCallback onTap, {bool isSubTile = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSubTile ? 0 : 16, vertical: 6),
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
              Icon(icon, color: AppColors.primaryDark, size: isSubTile ? 20 : 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title, style: GoogleFonts.inter(fontSize: isSubTile ? 13 : 14)),
              ),
              if (!isSubTile) const Icon(Icons.chevron_right, color: AppColors.primaryDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryDark),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.inter(fontSize: 12)),
        ],
      ),
    );
  }
}
