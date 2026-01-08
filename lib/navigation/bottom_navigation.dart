import 'package:MediCompare/features/earnings/presentation/pages/earnings.dart';
import 'package:MediCompare/features/orders/presentation/pages/order_page.dart';
import 'package:MediCompare/features/profile/presentation/pages/main_profile_page.dart';
import 'package:flutter/material.dart';

import '../features/home/presentation/pages/home_page.dart';
import '../core/constants/app_colors.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    OrdersPage(),
    EarningsScreen(),
    MainprofileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },

        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.greyText,
        showUnselectedLabels: true,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lock),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Earnings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
