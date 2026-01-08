import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final ImagePicker _picker = ImagePicker();

  final Map<String, File?> uploadedFiles = {
    "Business Registration Certificate": null,
    "GST Registration Certificate": null,
    "Business Registration Certificate 2": null,
    "PAN Card number": null,
  };

  Future<void> pickFile(String key) async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (file != null) {
      setState(() {
        uploadedFiles[key] = File(file.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff7C4DFF),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Documents Screen",
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Documents",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
        
              ...uploadedFiles.keys.map(
                (title) => documentItem(
                  title: title,
                  file: uploadedFiles[title],
                  onUpload: () => pickFile(title),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget documentItem({
    required String title,
    required File? file,
    required VoidCallback onUpload,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.description_outlined, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),

                /// Upload Container
                InkWell(
                  onTap: onUpload,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: Center(
                      child: file == null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.upload_file,
                                    color: Colors.grey),
                                SizedBox(width: 6),
                                Text(
                                  "Upload Document",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          : Text(
                              "Uploaded ✔",
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
