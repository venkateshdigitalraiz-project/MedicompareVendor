import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BulkUploadPage extends StatefulWidget {
  const BulkUploadPage({super.key});

  @override
  State<BulkUploadPage> createState() => _BulkUploadPageState();
}

class _BulkUploadPageState extends State<BulkUploadPage> {
  String? uploadedFileName;

  void _downloadTemplate() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Downloading template...")),
    );
  }

  Future<void> _uploadCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      setState(() {
        uploadedFileName = result.files.single.name;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Uploaded: $uploadedFileName")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No file selected")),
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff8046f1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          "Upload Medicines",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: AppColors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 29),
            Text(
              "Bulk Upload Medicines",
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Manage Medicine Data Through CSV upload\nor download Template.",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 14),

            /// DOWNLOAD TEMPLATE BUTTON
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _downloadTemplate,
              child: Container(
                height: 58,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xff8046F1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Download Template",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.file_download_outlined,
                      color: AppColors.white,
                      size: 24,
                    ),
                    SizedBox(
                      width: 20.75,
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 31),

            /// DOTTED UPLOAD CONTAINER (NO PACKAGE)
            GestureDetector(
              onTap: _uploadCSV,
              child: CustomPaint(
                painter: DottedBorderPainter(),
                child: Container(
                  width: double.infinity,
                  height: 268,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/downloadicon.png',
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        uploadedFileName ?? "Drop Your CSV file here",
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "or click to Browse files",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 279,
                        height: 58,
                        child: ElevatedButton.icon(
                          onPressed: _uploadCSV,
                          icon: const Icon(
                            Icons.file_upload_outlined,
                            color: AppColors.white,
                            size: 32,
                          ),
                          label: Text(
                            "Upload CSV File",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff8046F1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
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

/// ================= DOTTED BORDER PAINTER =================
class DottedBorderPainter extends CustomPainter {
  final double radius;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  DottedBorderPainter({
    this.radius = 16,
    this.color = AppColors.borderLight,
    this.strokeWidth = 2,
    this.dashLength = 10,
    this.gapLength = 6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashLength),
          paint,
        );
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
