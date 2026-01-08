import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:MediCompare/core/constants/app_colors.dart';
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      /// APP BAR
      appBar: AppBar(
        backgroundColor:  AppColors.primaryDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          "Notifications",
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),

      /// BODY
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: const [
          NotificationTile(
            iconBg: Color(0xFFEDE9FE),
            iconColor: AppColors.primaryDark,
            icon: Icons.inventory_2_outlined,
            title: "New Delivery Assigned!",
            subtitle: "Order #MC2345 assigned to you...",
            date: "24 Mar 2025",
            time: "12:00PM",
          ),
          NotificationTile(
            iconBg: Color(0xFFFEF3C7),
            iconColor: Color(0xFFF59E0B),
            icon: Icons.account_balance_wallet_outlined,
            title: "Payment / Wallet",
            subtitle: "₹80 credited for Order #MC2345...",
            date: "24 Mar 2025",
            time: "12:00PM",
          ),
          NotificationTile(
            iconBg: Color(0xFFDBEAFE),
            iconColor: Color(0xFF3B82F6),
            icon: Icons.card_giftcard_outlined,
            title: "Bonus / Incentive",
            subtitle: "Weekly bonus ₹150 added to wallet...",
            date: "24 Mar 2025",
            time: "12:00PM",
          ),
          NotificationTile(
            iconBg: Color(0xFFE0F2FE),
            iconColor: Color(0xFF0284C7),
            icon: Icons.verified_user_outlined,
            title: "Verification / Profile",
            subtitle: "Your ID proof has been verified...",
            date: "24 Mar 2025",
            time: "12:00PM",
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String date;
  final String time;

  const NotificationTile({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ICON
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),

          const SizedBox(width: 12),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Color(0xff000000),
                      fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),

          /// DATE & TIME
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style:
                    GoogleFonts.poppins(fontSize: 8, color: Color(0xff969AA4)),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style:
                    GoogleFonts.poppins(fontSize: 8, color: Color(0xff969AA4)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
