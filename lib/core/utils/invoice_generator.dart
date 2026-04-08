import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/subscription/data/models/subscription_model.dart';

class InvoiceGenerator {
  static Future<void> generateAndDownloadInvoice(CurrentPack pack) async {
    final pdf = pw.Document();

    final String invNo = pack.id.substring(pack.id.length - 6).toUpperCase();
    final String date = DateFormat('dd MMM, yyyy').format(pack.createdAt);
    final String billingPeriod = DateFormat('MMM yyyy').format(pack.createdAt);
    final String planName = pack.plan?.name ?? 'Lead Plan';
    final String billingCycle = pack.plan?.billingCycle ?? 'monthly';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  '#INV-$invNo',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 24),

                // Info Sections
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Plan Information
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Plan Information'),
                          pw.SizedBox(height: 12),
                          _infoRow('Plan Name:', planName),
                          _infoRow('Billing Period:', '$billingPeriod • $billingCycle'),
                          _infoRow('Status:', 'active'),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 40),
                    // Usage Details
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          _sectionTitle('Usage Details'),
                          pw.SizedBox(height: 12),
                          _infoRow('Leads Used:', '${pack.usage} / ${pack.plan?.limit ?? 0}'),
                          _infoRow('Renewed On:', date),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 48),

                // Table
                pw.Table(
                  border: const pw.TableBorder(
                    bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
                  ),
                  children: [
                    // Table Header
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey100,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                    // Table Row
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: pw.Text('$planName Plan - $billingPeriod • $billingCycle', style: const pw.TextStyle(fontSize: 11)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                          child: pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text('₹${pack.amount}', style: const pw.TextStyle(fontSize: 11)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 32),

                // Total Amount
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        'Total Amount: ',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '₹${pack.amount}',
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                pw.Spacer(),

                // Footer
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Divider(thickness: 1, color: PdfColors.grey200),
                      pw.SizedBox(height: 16),
                      pw.Text(
                        'Thank you for your subscription!',
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'This is a computer-generated invoice.',
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Show preview and allow download/save
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'INV-$invNo.pdf',
    );
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Container(
          height: 1,
          width: 80,
          color: PdfColors.grey400,
        ),
      ],
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(width: 4),
          pw.Text(
            value,
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
