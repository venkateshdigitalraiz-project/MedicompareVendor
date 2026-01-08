import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BankInformationScreen extends StatefulWidget {
  const BankInformationScreen({super.key});

  @override
  State<BankInformationScreen> createState() => _BankInformationScreenState();
}

class _BankInformationScreenState extends State<BankInformationScreen> {
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Banking Information",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Banking Information",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Color(0xffF9F9F9),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.account_box),
              title: Text("Account Holder name",
                  style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w400)),
              subtitle: Text("Velpula Annapurna",
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w400)),
            ),
          ),
          Card(
            color: Color(0xffF9F9F9),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: Text("Account Number",
                 style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w400)),
              subtitle: Text("××××××××× 4769",
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w400)),
            ),
          ),
          Card(
            color: Color(0xffF9F9F9),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.code),
              title: Text("IFSC Code",
                 style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w400)),
              subtitle: Text("HDFC100243C",
                 style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w400)),
            ),
          ),
          Card(
            color: Color(0xffF9F9F9),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.account_balance),
              title: Text("Bank Name",
                 style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w400)),
              subtitle: Text("HDFC Bank",
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w400)),
            ),
          ),
          Card(
            color: Color(0xffF9F9F9),
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.location_city_rounded),
              title: Text("Branch",
                 style: GoogleFonts.inter(
                      fontSize: 14, fontWeight: FontWeight.w400)),
              subtitle: Text("HDFC Bank, Kukatpally, Hyderabad",
                  style: GoogleFonts.poppins(
                      fontSize: 12, fontWeight: FontWeight.w400)),
            ),
          ),
        ],
      ),
    );
  }
}
