import 'package:MediCompare/features/auth/presentation/pages/bank_information_upload.dart';
import 'package:MediCompare/features/auth/presentation/pages/business_information_upload.dart';
import 'package:MediCompare/features/auth/presentation/pages/documents_upload.dart';
import 'package:MediCompare/features/auth/presentation/pages/forget_password_page.dart';
import 'package:MediCompare/features/auth/presentation/pages/login_page.dart';
import 'package:MediCompare/features/auth/presentation/pages/registration_page.dart';
import 'package:MediCompare/features/auth/presentation/pages/vendor_onboarding_screen.dart';
import 'package:MediCompare/features/home/presentation/pages/add_medicine_page.dart';
import 'package:MediCompare/features/home/presentation/pages/bulk_upload_page.dart';
import 'package:MediCompare/features/home/presentation/pages/home_page.dart';
import 'package:MediCompare/features/home/presentation/pages/low_stock_page.dart';
import 'package:MediCompare/features/home/presentation/pages/medicines_page.dart';
import 'package:MediCompare/features/home/presentation/pages/notification_page.dart';
import 'package:MediCompare/features/home/presentation/pages/report_page.dart';
import 'package:MediCompare/features/home/presentation/pages/sales_viewall.dart';
import 'package:MediCompare/features/home/presentation/pages/ticket_page.dart';
import 'package:MediCompare/features/profile/presentation/pages/bank_information_screen.dart';
import 'package:MediCompare/features/profile/presentation/pages/business_information_screen.dart';
import 'package:MediCompare/features/profile/presentation/pages/change_password_screen.dart';
import 'package:MediCompare/features/profile/presentation/pages/documents_screen.dart';
import 'package:MediCompare/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:MediCompare/features/profile/presentation/pages/support_ticket_screen.dart';
import 'package:MediCompare/features/tickets/presentation/pages/generate_new_ticket.dart';
import 'package:MediCompare/features/tickets/presentation/pages/generated_ticket.dart';
import 'package:MediCompare/features/tickets/presentation/pages/view_ticket.dart';
import 'package:MediCompare/navigation/bottom_navigation.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegistrationPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (_, __) => const ForgetPasswordPage(),
    ),
    GoRoute(
      path: '/vendor-onboarding',
      builder: (_, __) => const VendorOnboardingScreen(),
    ),
    GoRoute(
      path: '/business-info-upload',
      builder: (_, __) => const Businessinformationupload(),
    ),
    GoRoute(
      path: '/documents-upload',
      builder: (_, __) => const DocumentsUpload(),
    ),
    GoRoute(
      path: '/bank-info-upload',
      builder: (_, __) => const BankInformationUpload(),
    ),
    GoRoute(
      path: '/bottom-nav',
      builder: (_, __) => const BottomNavigation(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomePage(),
    ),
    GoRoute(
      path: '/tickets-page',
      builder: (_, __) => const TicketPage(),
    ),
    GoRoute(
      path: '/notification',
      builder: (_, __) => const NotificationPage(),
    ),
    GoRoute(
      path: '/medicines',
      builder: (_, __) => const MedicinesPage(),
    ),
    GoRoute(
      path: '/add-medicine',
      builder: (_, __) => const AddMedicinePage(),
    ),
    GoRoute(
      path: '/bulk-upload',
      builder: (_, __) => const BulkUploadPage(),
    ),
    GoRoute(
      path: '/low-stock',
      builder: (_, __) => const LowStockPage(),
    ),
    GoRoute(
      path: '/reports',
      builder: (_, __) => const ReportPage(),
    ),
    GoRoute(
      path: '/sales-viewall',
      builder: (_, __) => const SalesViewall(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (_, __) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (_, __) => const ChangePasswordScreen(),
    ),
    GoRoute(
      path: '/business-info',
      builder: (_, __) => const BusinessInformationScreen(),
    ),
    GoRoute(
      path: '/bank-info',
      builder: (_, __) => const BankInformationScreen(),
    ),
    GoRoute(
      path: '/documents',
      builder: (_, __) => const DocumentsScreen(),
    ),
    GoRoute(
      path: '/support-ticket',
      builder: (_, __) => const SupportTicketScreen(),
    ),
    GoRoute(
      path: '/generate-ticket',
      builder: (_, __) => const GenerateNewTicket(),
    ),
    GoRoute(
      path: '/generated-ticket',
      builder: (_, __) => const GeneratedTicket(),
    ),
    GoRoute(
      path: '/view-ticket',
      builder: (_, __) => const ViewTicket(),
    ),
  ],
);
