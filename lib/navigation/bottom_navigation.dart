import 'package:MediCompare/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:MediCompare/features/pincodes/presentation/pages/pincodes_page.dart';
import 'package:MediCompare/features/profile/presentation/pages/main_profile_page.dart';
import 'package:MediCompare/features/slots/presentation/pages/slot_timings_page.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    SlotTimingsPage(),
    PincodesPage(),
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
        unselectedItemColor: AppColors.grey,
        showUnselectedLabels: true,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: "Slot Timings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "Pincodes",
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
