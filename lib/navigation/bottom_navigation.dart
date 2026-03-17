import 'package:MediCompare/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:MediCompare/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:MediCompare/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:MediCompare/features/pincodes/presentation/bloc/pincodes_bloc.dart';
import 'package:MediCompare/features/pincodes/presentation/bloc/pincodes_state.dart';
import 'package:MediCompare/features/pincodes/presentation/pages/pincodes_page.dart';
import 'package:MediCompare/features/profile/presentation/pages/main_profile_page.dart';
import 'package:MediCompare/features/slots/presentation/bloc/slots_bloc.dart';
import 'package:MediCompare/features/slots/presentation/bloc/slots_state.dart';
import 'package:MediCompare/features/slots/presentation/pages/slot_timings_page.dart';
import 'package:MediCompare/features/tickets/presentation/bloc/tickets_bloc.dart';
import 'package:MediCompare/features/tickets/presentation/bloc/tickets_state.dart';
import 'package:MediCompare/features/subscription/presentation/bloc/subscription_bloc.dart';
import 'package:MediCompare/features/subscription/presentation/bloc/subscription_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:MediCompare/core/utils/token_storage.dart';

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

  void _handleUnauthorized(BuildContext context) {
    debugPrint('Global: Unauthorized access detected. Redirecting to login...');
    TokenStorage.clearAll().then((_) {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DashboardBloc, DashboardState>(
          listener: (context, state) {
            if (state is DashboardError && state.message == 'UNAUTHORIZED_ACCESS_401') {
              _handleUnauthorized(context);
            }
          },
        ),
        BlocListener<SlotsBloc, SlotsState>(
          listener: (context, state) {
            if (state is SlotsError && state.message == 'UNAUTHORIZED_ACCESS_401') {
              _handleUnauthorized(context);
            }
          },
        ),
        BlocListener<PincodesBloc, PincodesState>(
          listener: (context, state) {
            if (state is PincodesError && state.message == 'UNAUTHORIZED_ACCESS_401') {
              _handleUnauthorized(context);
            }
          },
        ),
        BlocListener<TicketsBloc, TicketsState>(
          listener: (context, state) {
            if (state is TicketsError && state.message == 'UNAUTHORIZED_ACCESS_401') {
              _handleUnauthorized(context);
            }
          },
        ),
        BlocListener<SubscriptionBloc, SubscriptionState>(
          listener: (context, state) {
            if (state is SubscriptionError && state.message == 'UNAUTHORIZED_ACCESS_401') {
              _handleUnauthorized(context);
            }
          },
        ),
      ],
      child: Scaffold(
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
          iconSize: 22,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_outlined),
              activeIcon: Icon(Icons.access_time_filled),
              label: "Slot Timings",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined),
              activeIcon: Icon(Icons.location_on),
              label: "Pincodes",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
