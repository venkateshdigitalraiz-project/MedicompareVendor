import 'package:flutter/material.dart';
import 'package:MediCompare/auth/mainprofile.dart';
import 'package:MediCompare/auth/orders_page.dart';
import 'package:MediCompare/home/home_page.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentIndex == 0 ? HomePage() : _currentIndex == 1 ? OrdersPage() : Mainprofile(),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        onTap: (value) {
          setState(() {
            _currentIndex = value;
          });
        },
        currentIndex: _currentIndex,
      selectedItemColor: const Color(0xff8046F1),
      unselectedItemColor: Colors.black,
      selectedIconTheme: IconThemeData(color: Color(0xff8046F1)),
      showUnselectedLabels: true,
        selectedLabelStyle: TextStyle(color: Colors.black),
        items: [
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
            label: "profile",
          ),
        ],
      ),
    );
  }
}
