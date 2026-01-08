import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ViewTicket extends StatefulWidget {
  const ViewTicket({super.key});

  @override
  State<ViewTicket> createState() => _ViewTicketState();
}

class _ViewTicketState extends State<ViewTicket> {
  void _navigateToCreateTicket() {
    context.push('/generate-ticket');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          " Support Ticket",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 48),

            /// FIRST CONTAINER (Create Ticket)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _navigateToCreateTicket,
                child: Container(
                  width: double.infinity,
                  height: 175,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD1D5DB),
                      width: 1.2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      Image.asset(
                        "assets/viewticket.png",
                        height: 74,
                        width: 74,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Create a Ticket",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// SECOND CONTAINER (Ticket Details)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _row("Ticket ID    ", "82383798728"),
                    const SizedBox(height: 10),
                    _row("Subject      ", "Order Placement issue", bold: true),
                    const SizedBox(height: 10),
                    _row(
                      "Status        ",
                      "Open",
                      valueColor: const Color(0xFF10B981),
                    ),
                    const SizedBox(height: 10),
                    _row("CreatedAt  ", "7 Feb 2022 05:34 PM", bold: true),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool bold = false,
    Color valueColor = const Color(0xFF111827),
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            "$label :",
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF7C3AED),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
