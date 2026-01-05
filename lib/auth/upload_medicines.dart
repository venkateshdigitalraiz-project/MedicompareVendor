import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadMedicines extends StatefulWidget {
  const UploadMedicines({super.key});

  @override
  State<UploadMedicines> createState() => _UploadMedicinesState();
}

class _UploadMedicinesState extends State<UploadMedicines> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xff8046f1),
        title: Text(
          "Upload Medicines",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Text(
              "Bulk Upload Medicines",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Manage Medicine Dta Through CSV upload \n or download Template.",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4),

            GestureDetector(
              onTap: () {
                // download template action
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF3EDFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xff8046f1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.download_outlined,
                      color: Color(0xff8046f1),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Download Template",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff8046f1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
