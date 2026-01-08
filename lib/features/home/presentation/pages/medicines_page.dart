import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';

class MedicinesPage extends StatefulWidget {
  const MedicinesPage({super.key});

  @override
  State<MedicinesPage> createState() => _MedicinesPageState();
}

class _MedicinesPageState extends State<MedicinesPage> {
  final List<Map<String, String>> recentMedicinesPage = [
    {
      "name": "Paracetamol 500mg",
      "qty": "Pain Relief • 150 units",
      "date": "Today",
      'status': "In Stock",
    },
    {
      "name": "Amoxicillin 250mg",
      "qty": "Antibiotics • 5 units",
      "date": "Yesterday",
      'status': "Out Stock",
    },
    {
      "name": "Ibuprofen 400mg",
      "qty": "Pain Relief • 89 units",
      "date": "2 days ago",
      'status': "In Stock",
    },
    {
      "name": "Amoxicillin 250mg",
      "qty": "Antibiotics • 5 units",
      "date": "Yesterday",
      'status': "Out Stock",
    },
    {
      "name": "Ibuprofen 400mg",
      "qty": "Pain Relief • 89 units",
      "date": "2 days ago",
      'status': "In Stock",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),

      appBar: AppBar(
        backgroundColor: const Color(0xff8046f1),
        foregroundColor: Color(0xffFFFFFF),
        title: Text(
          "All Medicines",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SizedBox(height: 22),
            Row(
              children: [
                Text(
                  "All Medicines",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Icon(Icons.tune_sharp),
              ],
            ),
            SizedBox(height: 18),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentMedicinesPage.length,
              itemBuilder: (context, index) {
                final item = recentMedicinesPage[index];
                final bool outstack = item["status"] == "Out Stock";
                final Color statusColor = outstack
                    ? const Color(0xffE66969)
                    : const Color(0xff22C55E);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item["name"]!,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item["qty"]!,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color.fromARGB(255, 14, 13, 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(LineIcons.edit),
                      SizedBox(width: 15.7),
                      Container(
                        height: 18,
                        width: 55,
                        decoration: BoxDecoration(
                          color: outstack
                              ? const Color(0xffFB3C3C).withOpacity(0.1)
                              : const Color(0xff22C55E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          item["status"]!,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
