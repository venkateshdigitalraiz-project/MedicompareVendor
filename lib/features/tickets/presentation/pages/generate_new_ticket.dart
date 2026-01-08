import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class GenerateNewTicket extends StatefulWidget {
  const GenerateNewTicket({super.key});

  @override
  State<GenerateNewTicket> createState() => _GenerateNewTicketState();
}

class _GenerateNewTicketState extends State<GenerateNewTicket> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C3AED),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          "Generate Ticket",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),

      /// BODY CONTENT
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 29),

            Image.asset("assets/generateticketicon.png",
                height: 84, width: 84),

            const SizedBox(height: 31),

            Text(
              "Generate New Ticket",
              style: GoogleFonts.inter(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              "Define your problem here to generate",
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: const Color(0xff8A8A8F),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            /// SUBJECT FIELD
            _subjectField(),

            const SizedBox(height: 10),

            /// DESCRIPTION FIELD
            _descriptionField(),

            /// SPACE TO AVOID BUTTON OVERLAP
            const SizedBox(height: 100),
          ],
        ),
      ),

      /// FIXED BOTTOM BUTTON
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/generated-ticket');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Create Ticket",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16), // ✅ space AFTER button
          ],
        ),
      ),
    );
  }

  /// SUBJECT INPUT (58 HEIGHT)
  Widget _subjectField() {
    return SizedBox(
      height: 58,
      child: TextField(
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Subject",
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF9CA3AF),
          ),
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

  /// DESCRIPTION INPUT (126 HEIGHT)
  Widget _descriptionField() {
    return SizedBox(
      height: 126,
      child: TextField(
        expands: true,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textAlignVertical: TextAlignVertical.top,
        style: GoogleFonts.inter(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Description",
          hintStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF9CA3AF),
          ),
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
}
