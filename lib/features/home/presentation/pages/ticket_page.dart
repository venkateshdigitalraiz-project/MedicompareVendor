import 'package:MediCompare/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  final List<Map<String, String>> tickets = [
    {
      "orderId": "#622318248726487",
      "title": "My order is very late to \ndelivered",
      "date": "21 Oct 2025  08:00 AM",
      "status": "Closed",
    },
    {
      "orderId": "#622318248726487",
      "title": "I’m Not Able to Logout",
      "date": "21 Oct 2025  08:00 AM",
      "status": "Pending",
    },
    {
      "orderId": "#622318248726487",
      "title": "Having Issue in Shopping",
      "date": "21 Oct 2025  08:00 AM",
      "status": "Processing",
    },
    {
      "orderId": "#622318248726487",
      "title": "I’m Not Able to Logout",
      "date": "21 Oct 2025  08:00 AM",
      "status": "Closed",
    },
    {
      "orderId": "#622318248726487",
      "title": "My order is very late to delivered",
      "date": "21 Oct 2025  08:00 AM",
      "status": "Processing",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          "Ticket List",
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Ticket list
            Expanded(
              child: ListView.separated(
                itemCount: tickets.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) => ticketCard(
                  orderId: tickets[index]["orderId"]!,
                  title: tickets[index]["title"]!,
                  date: tickets[index]["date"]!,
                  status: tickets[index]["status"]!,
                ),
              ),
            ),

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to new ticket page
                  context.push('/generate-ticket');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Generate New Ticket",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ticketCard({
    required String orderId,
    required String title,
    required String date,
    required String status,
  }) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case "Open":
        backgroundColor = const Color(0xFFBFD3FF);
        textColor = const Color(0xFF1D4ED8);
        break;
      case "Closed":
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF047857);
        break;
      case "Pending":
        backgroundColor = const Color(0xFFFECACA);
        textColor = const Color(0xFFB91C1C);
        break;
      default:
        backgroundColor = const Color(0xFFBFD3FF);
        textColor = const Color(0xFF1D4ED8);
    }

    return Container(
      height: 95,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Icon
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "assets/ticketicon.png",
              height: 32,
              width: 32,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Order ID: $orderId",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: AppColors.grey600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  date,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              elevation: 0,
              minimumSize: const Size(70, 26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
