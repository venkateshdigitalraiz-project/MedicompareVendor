import 'dart:io';
import 'package:MediCompare/SupportTicketPage.dart';
import 'package:MediCompare/bankinginformation.dart';
import 'package:MediCompare/businessinformation.dart';
import 'package:MediCompare/changepassword.dart';
import 'package:MediCompare/documentsscreen.dart';
import 'package:MediCompare/profileedit_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:MediCompare/auth/login_page.dart';


class Mainprofile extends StatefulWidget {
  const Mainprofile({super.key});

  @override
  State<Mainprofile> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<Mainprofile> {
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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
                        backgroundColor: const Color(0xFF7C3AED),
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
                          backgroundColor: Colors.white,
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileeditPage()),
              );
            }),
            _menuTile("Change Password", Icons.remove_red_eye_outlined, () {
              
               Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Changepassword()),
              );
            }),
            _menuTile("Business Information", Icons.apartment, () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Businessinformation()),
              );
            }),
            _menuTile("Documents", Icons.description_outlined, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Documentsscreen()),
              );
            }),
            _menuTile("Banking Information", Icons.account_balance, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Bankinginformation()),
              );
            }),
            _menuTile("Ticket List", Icons.support_agent, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SupportTicketsPage()),
              );
            }),
            _menuTile("Settings", Icons.settings_outlined, () {
              
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
                icon: const Icon(Icons.logout, color: Colors.white),
                label: Text(
                  "Log Out",
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(String title, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF7C3AED)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(title, style: GoogleFonts.inter(fontSize: 14)),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF7C3AED)),
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
          Icon(icon, size: 14, color: const Color(0xFF7C3AED)),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.inter(fontSize: 12)),
        ],
      ),
    );
  }
}