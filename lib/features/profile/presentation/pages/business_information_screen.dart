import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class BusinessInformationScreen extends StatefulWidget {
  const BusinessInformationScreen({super.key});

  @override
  State<BusinessInformationScreen> createState() => _BusinessInformationScreenState();
}

class _BusinessInformationScreenState extends State<BusinessInformationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff8046f1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          "Business Information",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Business Information",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Business Name
          Card(
            color: Color(0xffF9F9F9),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.business),
              title: Text("Business Name",
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w400)),
              subtitle: Text("Apollo Hospitals",
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w400)),
            ),
          ),

          // Business Email
          Card(
            color: Color(0xffF9F9F9),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.email),
              title: Text("Business Email",
                 style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w400)),
              subtitle: Text("apollo@gmail.com",
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w400)),
            ),
          ),

          // Business Contact
          Card(
            color: Color(0xffF9F9F9),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.phone),
              title: Text("Business Contact",
                 style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w400)),
              subtitle: Text("+91 8973582789",
                 style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w400)),
            ),
          ),

          // Address
          Card(
            color: Color(0xffF9F9F9),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.location_on),
              title: Text("Address",
                 style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w400)),
              subtitle: Text("Manjeera Majesty, Lulu mall beside, Hyderabad",
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w400)),
            ),
          ),

          // Category
          Card(
            color: Color(0xffF9F9F9),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.category),
              title: Text("Category",
                 style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w400)),
              subtitle: Text("Medicine",
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
    );
  }
}
