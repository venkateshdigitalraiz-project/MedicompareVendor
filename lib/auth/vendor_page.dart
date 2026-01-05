import 'package:MediCompare/businessinformationupload.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

class VendorPage extends StatefulWidget {
  const VendorPage({super.key});

  @override
  State<VendorPage> createState() => _VendorPageState();
}

class _VendorPageState extends State<VendorPage> {
  String? selectedVendorType = "Business";
  String? hasCertificates = "Yes";
  String? uploadedFileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Vendor Onboarding Details",
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "Enter your Details in below Field",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 9),
              Row(
                children: [
                  Radio<String>(
                    value: "Business",
                    groupValue: selectedVendorType,
                    activeColor: Colors.deepPurple,
                    onChanged: (value) {
                      setState(() {
                        selectedVendorType = value!;
                      });
                    },
                  ),
                  Text(
                    "Business",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(width: 55),
                  Radio<String>(
                    value: "Individual",
                    groupValue: selectedVendorType,
                    activeColor: Colors.deepPurple,
                    onChanged: (value) {
                      setState(() {
                        selectedVendorType = value!;
                      });
                    },
                  ),
                  Text(
                    "Individual",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 13),
              _inputField(hint: "Name"),
              SizedBox(height: 16),
              _inputField(hint: "Business Name"),
              SizedBox(height: 16),
              _inputField(hint: "Email"),
              SizedBox(height: 16),
              _inputField(hint: "Please Select State"),
              SizedBox(height: 16),
              _inputField(hint: "Please Select City"),
              SizedBox(height: 16),
              _inputField(hint: "Pincode"),
              SizedBox(height: 28),
              Text(
                "Do you have relevant valid certificates and \n licenses?",
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 18),
              Row(
                children: [
                  Radio<String>(
                    value: "Yes",
                    groupValue: hasCertificates,
                    activeColor: Colors.deepPurple,
                    onChanged: (value) {
                      setState(() {
                        hasCertificates = value!;
                      });
                    },
                  ),
                  Text(
                    "Yes",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Radio<String>(
                    value: "No",
                    groupValue: hasCertificates,
                    activeColor: Colors.deepPurple,
                    onChanged: (value) {
                      setState(() {
                        hasCertificates = value!;
                      });
                    },
                  ),
                  Text(
                    "No",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18),
              if (hasCertificates == "Yes") _uploadFileButton(),

              SizedBox(height: 29),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C4DFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {

                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Businessinformationupload();
                      },
                    ),
                  );
                  },
                  child: Text(
                    "Continue",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 35),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _inputField({required String hint}) {
    return SizedBox(
      height: 48,
      child: TextField(
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
          ),
        ),
      ),
    );
  }

  Widget _uploadFileButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        onPressed: _pickFile,
        child: Row(
          children: [
            const Icon(Icons.upload_file, color: Color(0xFF7C4DFF)),
            const SizedBox(width: 10),

            /// File name / placeholder
            Expanded(
              child: Text(
                uploadedFileName ?? "Upload File",
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: uploadedFileName == null
                      ? const Color(0xFF9CA3AF)
                      : Colors.black,
                ),
              ),
            ),

            /// ❌ Cross icon (only after upload)
            if (uploadedFileName != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    uploadedFileName = null;
                  });
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        uploadedFileName = result.files.single.name;
      });
    }
  }
}
