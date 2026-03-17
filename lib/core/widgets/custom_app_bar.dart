import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class CustomHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showUserInfo;
  final String? userName;
  final String? userImageUrl;

  const CustomHomeAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showUserInfo = false,
    this.userName,
    this.userImageUrl,
  });

  @override
  Widget build(BuildContext context) {

    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Stack(
            children: [
              Icon(Icons.notifications_none_outlined, color: Colors.white),
              Positioned(
                right: 2,
                top: 2,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
        if (showUserInfo) ...[
          const SizedBox(width: 4),
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white.withOpacity(0.2),
            backgroundImage: userImageUrl != null ? NetworkImage(userImageUrl!) : null,
            child: userImageUrl == null
                ? Text(
                    userName?.isNotEmpty == true ? userName![0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          const SizedBox(width: 16),
        ] else
          const SizedBox(width: 12),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}
