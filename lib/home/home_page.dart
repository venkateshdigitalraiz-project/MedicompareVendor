import 'package:MediCompare/lowstock_page.dart';
import 'package:MediCompare/report_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'package:MediCompare/addnewmedicine.dart';
import 'package:MediCompare/auth/bulk_page.dart';
import 'package:MediCompare/auth/medicines.dart';
import 'package:MediCompare/auth/notification_page.dart';
import 'package:MediCompare/auth/ticket_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> overviewItems = [
    "Total Medicines",
    "Earnings",
    "Low Stock",
    "Expiring Soon",
  ];
  final List<String> score = ["1,247", "24", "18", "7"];
  final List<String> value = ["+12%", "+2", "+5", "+3"];
  final List<String> overviewImages = [
    "assets/Medicines.png",
    "assets/Earnings.png",
    "assets/stock.png",
    "assets/Expiring.png",
  ];
  final List<String> quickactions = [
    "assets/inventory.png",
    "assets/bulk upload.png",
    "assets/low stock.png",
    "assets/report.png",
  ];
  final List<String> actionname = [
    "Add Medicine",
    "Bulk Upload",
    "Low Stock",
    "Reports",
  ];
  final List<String> subaction = [
    "Add new inventory Medicines",
    "Upload Multiple Medicines",
    "View Low Stock Items",
    "Generate Inventory Reports",
  ];

  final List<Map<String, String>> recentMedicines = [
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
      'status': "Low Stock",
    },
    {
      "name": "Ibuprofen 400mg",
      "qty": "Pain Relief • 89 units",
      "date": "2 days ago",
      'status': "In Stock",
    },
  ];

  String currentDateTime = "";

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final formatted = DateFormat('EEE, dd MMM yyyy • hh:mm a').format(now);

    setState(() {
      currentDateTime = formatted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xff8046f1),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 35),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 17),
              Text(
                "Hi, Arun",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Text(
                currentDateTime,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 17),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.support_agent), // or settings
                color: Colors.white,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),

                onPressed: () {
                   Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return TicketPage();
                          },
                        ),
                      );
                },
              ),

              IconButton(
                icon: const Icon(Icons.notifications),
                color: Colors.white,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  // notification click
                  Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return NotificationPage();
                          },
                        ),
                      );
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 18),
              Text(
                "Today's Overview",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6),
              SizedBox(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 165.5 / 118,
                  ),
                  itemCount: overviewItems.length,
                  itemBuilder: (context, index) {
                    Color valueColor;
                    Color valueBgColor;

                    switch (index) {
                      case 0:
                      case 1:
                        valueColor = Colors.green;
                        valueBgColor = Colors.green.withOpacity(0.1);
                        break;
                      case 2:
                        valueColor = Colors.orange;
                        valueBgColor = Colors.orange.withOpacity(0.1);
                        break;
                      case 3:
                        valueColor = Colors.red;
                        valueBgColor = Colors.red.withOpacity(0.1);
                        break;
                      default:
                        valueColor = Colors.black;
                        valueBgColor = Colors.grey.withOpacity(0.1);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 19),
                            Row(
                              children: [
                                Image.asset(
                                  overviewImages[index],
                                  height: 24,
                                  width: 24,
                                ),
                                SizedBox(width: 100),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: valueBgColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    value[index],
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: valueColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              score[index],
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              overviewItems[index],
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 19),
              Row(
                children: [
                  Text(
                    "Recent Medicines",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return Medicines();
                          },
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      "View All",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: const Color(0xff8046F1),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentMedicines.length,
                itemBuilder: (context, index) {
                  final item = recentMedicines[index];
                  final bool isLowStock = item["status"] == "Low Stock";
                  final Color statusColor = isLowStock
                      ? const Color(0xffFB923C)
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
                            color: isLowStock
                                ? const Color(0xffFB923C).withOpacity(0.1)
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
              SizedBox(height: 19),
              Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
              SizedBox(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 13.5,
                    mainAxisSpacing: 13.5,
                    childAspectRatio: 164 / 108,
                  ),
                  itemCount: quickactions.length,
                  itemBuilder: (context, index) {
                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          switch (index) {
                            case 0:
                              // Add Medicine
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Addnewmedicine(),
                                ),
                              );
                              break;
                            case 1:
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BulkPage(),
                                ),
                              );
                              break;
                            case 2:
                             Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LowstockPage(),
                                ),
                              );
                              break;
                            case 3:
                              // Reports
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ReportPage(),
                                ),
                              );
                              break;
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Color(0xffE5E7EB),
                            border: Border.all(
                              color: const Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 15),
                              Image.asset(
                                quickactions[index],
                                height: 22,
                                width: 22,
                              ),

                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      actionname[index],
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  Icon(
                                    Icons.chevron_right,
                                    size: 22,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                              Text(
                                subaction[index],
                                maxLines: 1,
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              SizedBox(height: 18),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
