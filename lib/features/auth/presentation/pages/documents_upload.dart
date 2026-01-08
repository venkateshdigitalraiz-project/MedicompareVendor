import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentsUpload extends StatefulWidget {
  const DocumentsUpload({super.key});

  @override
  State<DocumentsUpload> createState() => _DocumentsUploadState();
}

class _DocumentsUploadState extends State<DocumentsUpload> {
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
            context.pop();
          },
        ),
        title: Text(
          "Documents",
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
              "Documents",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            documentUploadTile(
              title: "Business Registration Certificate",
            ),
            const SizedBox(height: 14),

            documentUploadTile(
              title: "GST Registration Certificate",
            ),
            const SizedBox(height: 14),

            documentUploadTile(
              title: "Business Registration Certificate",
            ),
            const SizedBox(height: 14),

            documentUploadTile(
              title: "PAN Card number",
            ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.go('/bank-info-upload');
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

/// -------- Document Upload Tile --------
Widget documentUploadTile({required String title}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          const Icon(
            Icons.description_outlined,
            size: 18,
            color: Color(0xff374151),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffE5E7EB)),
        ),
        child: Row(
          children: [
            Text(
              "Upload File",
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xff9CA3AF),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.upload_file,
              color: Color(0xff7C3AED),
              size: 20,
            ),
          ],
        ),
      ),
    ],
  );
}
