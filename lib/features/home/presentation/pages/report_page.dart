import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final List<Map<String, String>> reportData = [
    {
      "title": "Total Orders",
      "score": "248",
    },
    {
      "title": "Completed",
      "score": "186",
    },
    {
      "title": "Cancelled",
      "score": "12",
    },
    {
      "title": "Total Revenue",
      "score": "₹24.8K",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.white),
        backgroundColor: const Color(0xff8046f1),
        elevation: 0,
        title: Text(
          "Sales Reports",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 14),
              Text(
                "Analyze your medicine sales and earnings performance",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: const Color(0xff4B5563),
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                ),
                itemCount: reportData.length,
                itemBuilder: (context, index) {
                  final item = reportData[index];

                  IconData icon;
                  Color iconColor;
                  Color iconBgColor;

                  switch (index) {
                    case 0:
                      icon = Icons.shopping_cart;
                      iconColor = Colors.green;
                      iconBgColor = Colors.green.withOpacity(0.15);
                      break;
                    case 1:
                      icon = Icons.check_circle;
                      iconColor = Colors.blue;
                      iconBgColor = Colors.blue.withOpacity(0.15);
                      break;
                    case 2:
                      icon = Icons.cancel;
                      iconColor = Colors.red;
                      iconBgColor = Colors.red.withOpacity(0.15);
                      break;
                    case 3:
                      icon = Icons.currency_rupee;
                      iconColor = Colors.orange;
                      iconBgColor = Colors.orange.withOpacity(0.15);
                      break;
                    default:
                      icon = Icons.info;
                      iconColor = AppColors.grey;
                      iconBgColor = AppColors.grey.withOpacity(0.15);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.borderLight,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 18),
                          Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                              color: iconBgColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              icon,
                              size: 14,
                              color: iconColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item["score"]!,
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            item["title"]!,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.grey600),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 12,
              ),
              Row(
                children: [
                  Text(
                    "Sales Trend",
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Spacer(),
                  Icon(Icons.tune),
                ],
              ),
              SizedBox(
                height: 18,
              ),
              Image.asset(
                width: double.infinity,
                "assets/salestrendgraph.png",
                fit: BoxFit.contain,
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Icon(
                    Icons.arrow_upward,
                    color: Color(0xff10B981),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  Text(
                    " Sales increased by 12% compared to the\nprevious period",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400, fontSize: 14),
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Order Status Breakdown",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Completed
                    _statusRow(
                      label: "Completed",
                      percent: "75%",
                      value: 0.75,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _statusRow(
                      label: "Processing",
                      percent: "20%",
                      value: 0.20,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _statusRow(
                      label: "Cancelled",
                      percent: "5%",
                      value: 0.05,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Text(
                          "Recent Sales",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            context.push('/sales-viewall');
                          },
                          child: Text(
                            "View All",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _recentSaleItem(
                      title: "Paracetamol 500mg",
                      subtitle: "#ORD-2024-001 · Today, 2:30 PM",
                      price: "\$45.00",
                      status: "Completed",
                      statusColor: Colors.green,
                    ),
                    const SizedBox(height: 8),

                    // Item 2
                    _recentSaleItem(
                      title: "Amoxicillin 250mg",
                      subtitle: "#ORD-2024-002 · Today, 1:15 PM",
                      price: "\$78.50",
                      status: "Processing",
                      statusColor: Colors.orange,
                    ),
                    const SizedBox(height: 8),

                    // Item 3
                    _recentSaleItem(
                      title: "Ibuprofen 400mg",
                      subtitle: "#ORD-2024-003 · Yesterday, 4:45 PM",
                      price: "\$32.00",
                      status: "Completed",
                      statusColor: Colors.green,
                    ),
                    const SizedBox(height: 8),

                    // Item 4
                    _recentSaleItem(
                      title: "Vitamin D3 1000 IU",
                      subtitle: "#ORD-2024-004 · Yesterday, 11:20 AM",
                      price: "\$25.00",
                      status: "Cancelled",
                      statusColor: Colors.red,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 14,
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Top Selling Medicines",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _topMedicineRow(
                      rank: "1",
                      rankBg: const Color(0xffEDE9FE),
                      rankColor: AppColors.primaryDark,
                      title: "Paracetamol 500mg",
                      subtitle: "156 units sold",
                      amount: "\$2,340",
                    ),
                    const SizedBox(height: 10),
                    _topMedicineRow(
                      rank: "2",
                      rankBg: const Color(0xffF3F4F6),
                      rankColor: const Color(0xff374151),
                      title: "Amoxicillin 250mg",
                      subtitle: "124 units sold",
                      amount: "\$1,860",
                    ),
                    const SizedBox(height: 10),

                    // Item 3
                    _topMedicineRow(
                      rank: "3",
                      rankBg: const Color(0xffF3F4F6),
                      rankColor: const Color(0xff374151),
                      title: "Ibuprofen 400mg",
                      subtitle: "98 units sold",
                      amount: "\$1,470",
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentSaleItem({
    required String title,
    required String subtitle,
    required String price,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
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
                  style:
                      GoogleFonts.inter(fontSize: 11, color: AppColors.grey600),
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
              // SizedBox(height: 20,)
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusRow({
    required String label,
    required String percent,
    required double value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Text(
              percent,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: AppColors.borderLight,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _topMedicineRow({
    required String rank,
    required Color rankBg,
    required Color rankColor,
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Row(
      children: [
        Container(
          height: 28,
          width: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: rankBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            rank,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: rankColor,
            ),
          ),
        ),
        const SizedBox(width: 12),
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
                style:
                    GoogleFonts.inter(fontSize: 11, color: AppColors.grey600),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SalesAreaChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = AppColors.primaryDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Sample data points (Mon → Sun)
    final points = [
      Offset(0, size.height * 0.55),
      Offset(size.width * 0.16, size.height * 0.42),
      Offset(size.width * 0.33, size.height * 0.35),
      Offset(size.width * 0.50, size.height * 0.45),
      Offset(size.width * 0.66, size.height * 0.30),
      Offset(size.width * 0.83, size.height * 0.18),
      Offset(size.width, size.height * 0.25),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    // Close area
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Draw top stroke line
    final strokePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      strokePath.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(strokePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
