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
      backgroundColor: const Color(0xffF9FAFB),

      // App Bar
      appBar: AppBar(
        backgroundColor: const Color(0xff7C3AED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Business Information",
          style: GoogleFonts.inter(
            color: Colors.white,
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
                  backgroundColor: const Color(0xff7C3AED),
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
                    color: Colors.white,
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xffE5E7EB)),
    ),
    child: TextField(
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14),
      decoration: InputDecoration(
        icon: Icon(
          icon,
          size: 18,
          color: const Color(0xff9CA3AF),
        ),
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 13,
          color: const Color(0xff9CA3AF),
        ),
        border: InputBorder.none,
      ),
    ),
  );
}
