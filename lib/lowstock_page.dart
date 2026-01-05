import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LowstockPage extends StatefulWidget {
  const LowstockPage({super.key});

  @override
  State<LowstockPage> createState() => _LowstockPageState();
}

class _LowstockPageState extends State<LowstockPage> {
  final GlobalKey _filterKey = GlobalKey();

  final List<Map<String, String>> recentMedicines = [
    {
      "medicinename": "Amoxicillin 500mg",
      "type": "Antibiotic",
      "status": "Critical",
      'availableunits': "8 Units",
      'requiredunits': "50 Units",
      'button': "Restock Now",
    },
    {
      "medicinename": "Paracetamol 650mg",
      "type": "Pain Reliever",
      "status": "Critical",
      'availableunits': "12 Units",
      'requiredunits': "100 Units",
      'button': "Restock Now",
    },
    {
      "medicinename": "Omeprazole 20mg",
      "type": "Gastric",
      "status": " Low",
      'availableunits': "18 Units",
      'requiredunits': "30 Units",
      'button': "Update Now",
    },
    {
      "medicinename": "Losartan 50mg",
      "type": "Blood Pressure",
      "status": "Low",
      'availableunits': "15 Units",
      'requiredunits': "25 Units",
      'button': "Restock Now",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
      iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xff8046f1),
        elevation: 0,
        title: Text(
          "Low Stock",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        // Inside AppBar actions
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              key: _filterKey, // Add a GlobalKey to the InkWell
              onTap: () {
                final RenderBox renderBox =
                    _filterKey.currentContext!.findRenderObject() as RenderBox;
                final Offset offset = renderBox.localToGlobal(Offset.zero);
                final Size size = renderBox.size;

                final RenderBox overlay =
                    Overlay.of(context).context.findRenderObject() as RenderBox;

                showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                      offset.dx,
                      offset.dy + size.height,
                      offset.dx + size.width,
                      offset.dy),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  items: [
                    PopupMenuItem(
                      value: "Tablets",
                      child: Text("Tablets",
                          style: GoogleFonts.poppins(fontSize: 14)),
                    ),
                    PopupMenuItem(
                      value: "Syrups",
                      child: Text("Syrups",
                          style: GoogleFonts.poppins(fontSize: 14)),
                    ),
                    PopupMenuItem(
                      value: "Injections",
                      child: Text("Injections",
                          style: GoogleFonts.poppins(fontSize: 14)),
                    ),
                    PopupMenuItem(
                      value: "Ointments",
                      child: Text("Ointments",
                          style: GoogleFonts.poppins(fontSize: 14)),
                    ),
                    PopupMenuItem(
                      value: "Medical Devices",
                      child: Text("Medical Devices",
                          style: GoogleFonts.poppins(fontSize: 14)),
                    ),
                  ],
                ).then((value) {
                  if (value != null) {
                    print("Selected Filter: $value");
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.tune,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 22,
            ),
            Text(
              "Low Stock Medicines",
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Total Medicines",
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff6B7280)),
                      ),
                      SizedBox(
                        height: 11,
                      ),
                      Text(
                        "24",
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 37.5,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Critical Stock",
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff6B7280)),
                      ),
                      SizedBox(
                        height: 11,
                      ),
                      Text(
                        "5",
                        style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffDC2626)),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 37.5,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Low Stock",
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xff6B7280)),
                      ),
                      SizedBox(
                        height: 11,
                      ),
                      Text(
                        "8",
                        style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xffF59E0B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 17,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: recentMedicines.length,
                itemBuilder: (context, index) {
                  final medicine = recentMedicines[index];

                  final String status = medicine['status']?.trim() ?? '';
                  final bool isCritical = status.toLowerCase() == 'critical';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isCritical
                            ? const Color(0xffFEE2E2)
                            : const Color(0xffFEF3C7),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  medicine['medicinename']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  medicine['type']!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xff6B7280),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isCritical
                                    ? Colors.red.withOpacity(0.12)
                                    : const Color(0xffFEF3C7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 5,
                                    backgroundColor: isCritical
                                        ? Colors.red
                                        : const Color(0xffF59E0B),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    medicine['status']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isCritical
                                          ? const Color(0xffDC2626)
                                          : const Color(0xffF59E0B),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Stock Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xffF9FAFB),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Available Stock",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff4B5563)),
                                  ),
                                  Text(
                                    medicine['availableunits']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Minimum Required",
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff4B5563)),
                                  ),
                                  Text(
                                    medicine['requiredunits']!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Button
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.inventory_2, size: 18),
                            label: Text(
                              medicine['button']!,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCritical
                                  ? Colors.red
                                  : const Color(0xffF59E0B),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showFilterMenu(BuildContext context, Offset offset) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromLTWH(offset.dx, offset.dy, 0, 0), // position of the menu
        Offset.zero & overlay.size, // screen size
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      items: [
        PopupMenuItem(
          value: "Tablets",
          child: Text("Tablets", style: GoogleFonts.poppins(fontSize: 14)),
        ),
        PopupMenuItem(
          value: "Syrups",
          child: Text("Syrups", style: GoogleFonts.poppins(fontSize: 14)),
        ),
        PopupMenuItem(
          value: "Injections",
          child: Text("Injections", style: GoogleFonts.poppins(fontSize: 14)),
        ),
        PopupMenuItem(
          value: "Ointments",
          child: Text("Ointments", style: GoogleFonts.poppins(fontSize: 14)),
        ),
        PopupMenuItem(
          value: "Medical Devices",
          child:
              Text("Medical Devices", style: GoogleFonts.poppins(fontSize: 14)),
        ),
      ],
    ).then((value) {
      if (value != null) {
        // Apply filter logic here
        print("Selected Filter: $value");
      }
    });
  }
}
