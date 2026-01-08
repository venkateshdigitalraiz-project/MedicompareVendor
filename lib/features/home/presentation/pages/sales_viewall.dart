import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalesViewall extends StatefulWidget {
  const SalesViewall({super.key});

  @override
  State<SalesViewall> createState() => _SalesViewallState();
}

class _SalesViewallState extends State<SalesViewall> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff8046f1),
        elevation: 0,
        title: Text(
          "Sales Reports",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  "All Medicines",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.tune, size: 20),
              ],
            ),
            const SizedBox(height: 16),

            // List
            Expanded(
              child: ListView(
                children: [
                  _medicineItem(
                    title: "Paracetamol 500mg",
                    subtitle: "#ORD-2024-001 · Today, 2:30 PM",
                    price: "\$45.00",
                    status: "Completed",
                    statusColor: Colors.green,
                  ),
                  const SizedBox(height: 8),

                  _medicineItem(
                    title: "Amoxicillin 250mg",
                    subtitle: "#ORD-2024-002 · Today, 1:15 PM",
                    price: "\$78.50",
                    status: "Processing",
                    statusColor: Colors.orange,
                  ),
                  const SizedBox(height: 8),

                  _medicineItem(
                    title: "Ibuprofen 400mg",
                    subtitle: "#ORD-2024-003 · Yesterday, 4:45 PM",
                    price: "\$32.00",
                    status: "Completed",
                    statusColor: Colors.green,
                  ),
                  const SizedBox(height: 8),

                  _medicineItem(
                    title: "Vitamin D3 1000 IU",
                    subtitle: "#ORD-2024-004 · Yesterday, 11:20 AM",
                    price: "\$25.00",
                    status: "Cancelled",
                    statusColor: Colors.red,
                  ),
                  const SizedBox(height: 8),

                  // repeated items (as in image)
                  _medicineItem(
                    title: "Paracetamol 500mg",
                    subtitle: "#ORD-2024-001 · Today, 2:30 PM",
                    price: "\$45.00",
                    status: "Completed",
                    statusColor: Colors.green,
                  ),
                  const SizedBox(height: 8),

                  _medicineItem(
                    title: "Amoxicillin 250mg",
                    subtitle: "#ORD-2024-002 · Today, 1:15 PM",
                    price: "\$78.50",
                    status: "Processing",
                    statusColor: Colors.orange,
                  ),
                  const SizedBox(height: 8),

                  _medicineItem(
                    title: "Ibuprofen 400mg",
                    subtitle: "#ORD-2024-003 · Yesterday, 4:45 PM",
                    price: "\$32.00",
                    status: "Completed",
                    statusColor: Colors.green,
                  ),
                  const SizedBox(height: 8),

                  _medicineItem(
                    title: "Vitamin D3 1000 IU",
                    subtitle: "#ORD-2024-004 · Yesterday, 11:20 AM",
                    price: "\$25.00",
                    status: "Cancelled",
                    statusColor: Colors.red,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _medicineItem({
    required String title,
    required String subtitle,
    required String price,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xff6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}