import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class Businessinformationupload extends StatefulWidget {
  const Businessinformationupload({super.key});

  @override
  State<Businessinformationupload> createState() =>
      _BusinessinformationuploadState();
}

class _BusinessinformationuploadState extends State<Businessinformationupload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      // App Bar
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          "Business Information",
          style: GoogleFonts.inter(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),

      // Body
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Business Information",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            businessInputField(
              icon: Icons.storefront,
              hint: "Business Name",
            ),
            const SizedBox(height: 12),

            businessInputField(
              icon: Icons.email_outlined,
              hint: "Business Email",
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            businessInputField(
              icon: Icons.phone_outlined,
              hint: "Business Contact",
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            businessInputField(
              icon: Icons.location_on_outlined,
              hint: "Address",
            ),
            const SizedBox(height: 12),

            businessInputField(
              icon: Icons.category_outlined,
              hint: "Category",
            ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/documents-upload');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Save",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -------- Input Field Widget --------
Widget businessInputField({
  required IconData icon,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.borderLight),
    ),
    child: TextField(
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        icon: Icon(
          icon,
          size: 18,
          color: AppColors.textSecondary,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
        border: InputBorder.none,
      ),
    ),
  );
}
