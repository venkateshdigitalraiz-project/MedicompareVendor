import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';

class PdfViewerPage extends StatefulWidget {
  final String url;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.url,
    this.title = 'PDF Viewer',
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        if (response.bodyBytes.isEmpty) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Downloaded file is empty.';
              _isLoading = false;
            });
          }
          return;
        }
        
        final bytes = response.bodyBytes;
        if (bytes.length < 4 || bytes[0] != 37 || bytes[1] != 80 || bytes[2] != 68 || bytes[3] != 70) {
          if (mounted) {
            setState(() {
              _errorMessage = 'Downloaded file is not a valid PDF.\nData starts with: \${String.fromCharCodes(bytes.take(20))}';
              _isLoading = false;
            });
          }
          return;
        }

        if (mounted) {
          setState(() {
            _pdfBytes = response.bodyBytes;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load PDF (HTTP \${response.statusCode})';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading PDF: \$e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _errorMessage.isNotEmpty
              ? Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 16)),
                ))
              : PdfPreview(
                  build: (format) => _pdfBytes!,
                  allowPrinting: false,
                  allowSharing: false,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  useActions: false,
                  padding: EdgeInsets.zero,
                  previewPageMargin: EdgeInsets.zero,
                  scrollViewDecoration: const BoxDecoration(color: Colors.transparent),
                  pdfPreviewPageDecoration: const BoxDecoration(color: Colors.transparent),
                ),
    );
  }
}
