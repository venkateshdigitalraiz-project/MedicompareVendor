import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BankInformationUpload extends StatefulWidget {
  const BankInformationUpload({super.key});

  @override
  State<BankInformationUpload> createState() => _BankInformationUploadState();
}

class _BankInformationUploadState extends State<BankInformationUpload> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9FAFB),

      // AppBar
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
          "Banking Information",
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
              "Banking Information",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            bankingInputField(
              icon: Icons.person_outline,
              hint: "Account Holder",
            ),
            const SizedBox(height: 12),

            bankingInputField(
              icon: Icons.credit_card_outlined,
              hint: "Account Number",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            bankingInputField(
              icon: Icons.confirmation_number_outlined,
              hint: "IFSC Code",
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 12),

            bankingInputField(
              icon: Icons.account_balance_outlined,
              hint: "Bank Name",
            ),
            const SizedBox(height: 12),

            bankingInputField(
              icon: Icons.location_on_outlined,
              hint: "Branch",
            ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/bottom-nav');
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

/// -------- Reusable Banking Input Field --------
Widget bankingInputField({
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
