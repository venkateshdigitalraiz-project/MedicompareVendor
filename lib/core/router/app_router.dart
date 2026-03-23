import 'package:flutter/material.dart';
import 'package:MediCompare/features/auth/presentation/pages/bank_information_upload.dart';
import 'package:MediCompare/features/auth/presentation/pages/business_information_upload.dart';
import 'package:MediCompare/features/auth/presentation/pages/documents_upload.dart';
import 'package:MediCompare/features/auth/presentation/pages/forget_password_page.dart';
import 'package:MediCompare/features/auth/presentation/pages/login_page.dart';
import 'package:MediCompare/features/auth/presentation/pages/registration_page.dart';
import 'package:MediCompare/features/auth/presentation/pages/vendor_onboarding_screen.dart';
import 'package:MediCompare/features/profile/presentation/pages/change_password_screen.dart';
import 'package:MediCompare/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:MediCompare/features/profile/presentation/pages/main_profile_page.dart';
import 'package:MediCompare/features/tickets/presentation/pages/support_help_center_page.dart';
import 'package:MediCompare/features/vendor_profile/presentation/pages/step1_personal_details_screen.dart';
import 'package:MediCompare/features/vendor_profile/presentation/pages/step2_business_details_screen.dart';
import 'package:MediCompare/features/orders/presentation/pages/order_page.dart';
import 'package:MediCompare/features/leads/presentation/pages/leads_page.dart';
import 'package:MediCompare/features/subscription/presentation/pages/subscription_plan_page.dart';
import 'package:MediCompare/features/subscription/presentation/pages/lead_plan_history_page.dart';
import 'package:MediCompare/features/orders/presentation/pages/order_details_page.dart';
import 'package:MediCompare/features/medicine/presentation/pages/medicine_list_page.dart';
import 'package:MediCompare/features/medicine/presentation/pages/medicine_details_page.dart';
import 'package:MediCompare/features/medicine/data/models/medicine_model.dart';
import 'package:MediCompare/features/surgery/presentation/pages/surgery_list_page.dart';
import 'package:MediCompare/features/surgery/presentation/pages/surgery_details_page.dart';
import 'package:MediCompare/features/surgery/data/models/surgery_model.dart';
import 'package:MediCompare/features/lab_test/presentation/pages/lab_test_list_page.dart';
import 'package:MediCompare/features/lab_test/presentation/pages/lab_test_details_page.dart';
import 'package:MediCompare/features/lab_test/presentation/pages/lab_test_package_list_page.dart';
import 'package:MediCompare/features/lab_test/presentation/pages/lab_test_package_details_page.dart';
import 'package:MediCompare/features/lab_test/data/models/lab_test_model.dart';
import 'package:MediCompare/features/lab_test/data/models/lab_test_package_model.dart';
import 'package:MediCompare/features/diagnostic/presentation/pages/diagnostic_list_page.dart';
import 'package:MediCompare/features/diagnostic/presentation/pages/diagnostic_details_page.dart';
import 'package:MediCompare/features/diagnostic/data/models/diagnostic_model.dart';
import 'package:MediCompare/features/home_care/presentation/pages/home_care_list_page.dart';
import 'package:MediCompare/features/home_care/presentation/pages/home_care_details_page.dart';
import 'package:MediCompare/features/home_care/data/models/home_care_model.dart';
import 'package:MediCompare/features/nursing_care/presentation/pages/nursing_care_list_page.dart';
import 'package:MediCompare/features/nursing_care/presentation/pages/nursing_care_details_page.dart';
import 'package:MediCompare/features/nursing_care/data/models/nursing_care_model.dart';
import 'package:MediCompare/features/dental_service/presentation/pages/dental_service_list_page.dart';
import 'package:MediCompare/features/dental_service/presentation/pages/dental_service_details_page.dart';
import 'package:MediCompare/features/dental_service/data/models/dental_service_model.dart';
import 'package:MediCompare/features/medical_treatment/presentation/pages/medical_treatment_list_page.dart';
import 'package:MediCompare/features/medical_treatment/presentation/pages/medical_treatment_details_page.dart';
import 'package:MediCompare/features/medical_treatment/data/models/medical_treatment_model.dart';
import 'package:MediCompare/features/medical_equipment/presentation/pages/medical_equipment_list_page.dart';
import 'package:MediCompare/features/medical_equipment/presentation/pages/medical_equipment_details_page.dart';
import 'package:MediCompare/features/medical_equipment/data/models/medical_equipment_model.dart';
import 'package:MediCompare/features/orders/orders_injection.dart';
import 'package:MediCompare/navigation/bottom_navigation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter(String initialLocation) => GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: initialLocation,
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
      path: '/step1-personal-details',
      builder: (_, __) => const Step1PersonalDetailsScreen(),
    ),
    GoRoute(
      path: '/step2-business-details',
      builder: (_, __) => const Step2BusinessDetailsScreen(),
    ),
    GoRoute(
      path: '/step3-banking-info',
      builder: (_, __) => const Scaffold(body: Center(child: Text("Step 3: Banking Information"))),
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
      path: '/profile-screen',
      builder: (_, __) => const MainprofileScreen(),
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
      path: '/support-ticket',
      builder: (_, __) => const SupportHelpCenterPage(),
    ),
    GoRoute(
      path: '/orders',
      builder: (_, __) => const OrdersPage(),
    ),
    GoRoute(
      path: '/leads',
      builder: (_, __) => const LeadsPage(),
    ),
    GoRoute(
      path: '/subscription-plan',
      builder: (_, __) => const SubscriptionPlanPage(),
    ),
    GoRoute(
      path: '/lead-plan-history',
      builder: (_, __) => const LeadPlanHistoryPage(),
    ),
    GoRoute(
      path: '/medicine-list',
      builder: (_, __) => const MedicineListPage(),
    ),
    GoRoute(
      path: '/medicine-details',
      builder: (context, state) => MedicineDetailsPage(medicine: state.extra as MedicineItem),
    ),
    GoRoute(
      path: '/order-details/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return BlocProvider(
          create: (_) => OrdersInjection.provideOrdersBloc(),
          child: OrderDetailPage(orderId: id),
        );
      },
    ),
    GoRoute(
      path: '/surgery-list',
      builder: (_, __) => const SurgeryListPage(),
    ),
    GoRoute(
      path: '/surgery-details',
      builder: (context, state) => SurgeryDetailsPage(surgery: state.extra as SurgeryItem),
    ),
    GoRoute(
      path: '/lab-test-list',
      builder: (_, __) => const LabTestListPage(),
    ),
    GoRoute(
      path: '/lab-test-details',
      builder: (context, state) => LabTestDetailsPage(item: state.extra as LabTestItem),
    ),
    GoRoute(
      path: '/lab-test-package-list',
      builder: (_, __) => const LabTestPackageListPage(),
    ),
    GoRoute(
      path: '/lab-test-package-details',
      builder: (context, state) => LabTestPackageDetailsPage(package: state.extra as LabTestPackageItem),
    ),
    GoRoute(
      path: '/diagnostic-list',
      builder: (_, __) => const DiagnosticListPage(),
    ),
    GoRoute(
      path: '/diagnostic-details',
      builder: (context, state) => DiagnosticDetailsPage(item: state.extra as DiagnosticItem),
    ),
    GoRoute(
      path: '/homecare-list',
      builder: (context, state) => const HomeCareListPage(),
    ),
    GoRoute(
      path: '/homecare-details',
      builder: (context, state) => HomeCareDetailsPage(item: state.extra as HomeCareItem),
    ),
    GoRoute(
      path: '/nursing-list',
      builder: (context, state) => const NursingCareListPage(),
    ),
    GoRoute(
      path: '/nursing-details',
      builder: (context, state) => NursingCareDetailsPage(item: state.extra as NursingCareItem),
    ),
    GoRoute(
      path: '/dental-list',
      builder: (context, state) => const DentalServiceListPage(),
    ),
    GoRoute(
      path: '/dental-details',
      builder: (context, state) => DentalServiceDetailsPage(item: state.extra as DentalServiceItem),
    ),
    GoRoute(
      path: '/medical-treatment-list',
      builder: (context, state) => const MedicalTreatmentListPage(),
    ),
    GoRoute(
      path: '/medical-treatment-details',
      builder: (context, state) => MedicalTreatmentDetailsPage(item: state.extra as MedicalTreatmentItem),
    ),
    GoRoute(
      path: '/equipment-list',
      builder: (context, state) => const MedicalEquipmentListPage(),
    ),
    GoRoute(
      path: '/equipment-details',
      builder: (context, state) => MedicalEquipmentDetailsPage(item: state.extra as MedicalEquipmentItem),
    ),
  ],
);
