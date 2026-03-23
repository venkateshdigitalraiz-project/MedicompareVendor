import 'package:MediCompare/core/utils/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'features/auth/auth_injection.dart';
import 'features/auth/presentation/providers/register_provider.dart';
import 'features/dashboard/dashboard_injection.dart';
import 'features/dashboard/presentation/bloc/dashboard_event.dart';
import 'features/slots/slots_injection.dart';
import 'features/slots/presentation/bloc/slots_event.dart';
import 'features/pincodes/pincodes_injection.dart';
import 'features/pincodes/presentation/bloc/pincodes_event.dart';
import 'features/orders/orders_injection.dart';
import 'features/orders/presentation/bloc/orders_event.dart';
import 'features/leads/leads_injection.dart';
import 'features/leads/presentation/bloc/leads_event.dart';
import 'features/vendor_profile/presentation/providers/vendor_profile_provider.dart';
import 'features/vendor_profile/vendor_profile_injection.dart';
import 'features/tickets/tickets_injection.dart';
import 'features/tickets/presentation/bloc/tickets_event.dart';
import 'features/subscription/subscription_injection.dart';
import 'features/subscription/presentation/bloc/subscription_event.dart';
import 'features/medicine/medicine_injection.dart';
import 'features/medicine/presentation/bloc/medicine_event.dart';
import 'features/surgery/surgery_injection.dart';
import 'features/surgery/presentation/bloc/surgery_event.dart';
import 'features/lab_test/lab_test_injection.dart';
import 'features/lab_test/presentation/bloc/lab_test_event.dart';
import 'features/lab_test/presentation/bloc/lab_test_package_event.dart';
import 'features/diagnostic/diagnostic_injection.dart';
import 'features/diagnostic/presentation/bloc/diagnostic_event.dart';
import 'features/home_care/home_care_injection.dart';
import 'features/home_care/presentation/bloc/home_care_event.dart';
import 'features/nursing_care/nursing_care_injection.dart';
import 'features/nursing_care/presentation/bloc/nursing_care_event.dart';
import 'features/dental_service/dental_service_injection.dart';
import 'package:MediCompare/features/dental_service/presentation/bloc/dental_service_event.dart';
import 'package:MediCompare/features/medical_treatment/medical_treatment_injection.dart';
import 'package:MediCompare/features/medical_treatment/presentation/bloc/medical_treatment_event.dart';
import 'package:MediCompare/features/medical_equipment/medical_equipment_injection.dart';
import 'package:MediCompare/features/medical_equipment/presentation/bloc/medical_equipment_event.dart';
import 'package:MediCompare/features/ambulance/ambulance_injection.dart';
import 'package:MediCompare/features/ambulance/presentation/bloc/ambulance_event.dart';
import 'package:MediCompare/core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check for persisted token
  final token = await TokenStorage.getToken();
  final String initialLocation = token != null ? '/bottom-nav' : '/login';

  runApp(MyApp(initialLocation: initialLocation));
}

class MyApp extends StatefulWidget {
  final String initialLocation;
  const MyApp({super.key, required this.initialLocation});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(widget.initialLocation);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RegisterProvider(
            registerUseCase: AuthInjection.provideRegisterUseCase(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorProfileProvider(
            updateStepOneUseCase:
                VendorProfileInjection.provideUpdateStepOneUseCase(),
            updateStepTwoUseCase:
                VendorProfileInjection.provideUpdateStepTwoUseCase(),
          ),
        ),
        BlocProvider(
          create: (_) => DashboardInjection.provideDashboardBloc()
            ..add(GetDashboardEvent()),
        ),
        BlocProvider(
          create: (_) => SlotsInjection.provideSlotsBloc()..add(GetSlotTimingsEvent()),
        ),
        BlocProvider(
          create: (_) => PincodesInjection.providePincodesBloc()..add(GetPincodesEvent()),
        ),
        BlocProvider(
          create: (_) => OrdersInjection.provideOrdersBloc()..add(const GetOrdersEvent()),
        ),
        BlocProvider(
          create: (_) => LeadsInjection.provideLeadsBloc()..add(const GetLeadsEvent()),
        ),
        BlocProvider(
          create: (_) =>
              TicketsInjection.provideTicketsBloc()..add(LoadTicketsEvent()),
        ),
        BlocProvider(
          create: (_) => SubscriptionInjection.provideBloc()..add(LoadSubscriptionDataEvent()),
        ),
        BlocProvider(
          create: (_) => MedicineInjection.provideMedicineBloc()..add(LoadMedicineCategoriesEvent()),
        ),
        BlocProvider(
          create: (_) => SurgeryInjection.provideSurgeryBloc()..add(LoadSurgeryCategoriesEvent()),
        ),
        BlocProvider(
          create: (_) => LabTestInjection.provideLabTestBloc()..add(LoadLabTestCategoriesEvent()),
        ),
        BlocProvider(
          create: (_) => LabTestInjection.provideLabTestPackageBloc()..add(const LoadLabTestPackagesEvent()),
        ),
        BlocProvider(
          create: (_) => DiagnosticInjection.provideDiagnosticBloc()..add(const LoadDiagnosticCategoriesEvent()),
        ),
        BlocProvider(
          create: (_) => HomeCareInjection.provideHomeCareBloc()..add(const LoadHomeCareCategoriesEvent()),
        ),
        BlocProvider(
          create: (_) => NursingCareInjection.provideNursingCareBloc()..add(const LoadNursingCareCategoriesEvent()),
        ),
        BlocProvider(
          create: (_) => DentalServiceInjection.provideDentalServiceBloc()..add(const LoadDentalServiceCategoriesEvent()),
        ),
        BlocProvider(
          create: (_) => MedicalTreatmentInjection.provideMedicalTreatmentBloc()..add(const LoadMedicalTreatmentCategoriesEvent()),
        ),
        BlocProvider(
          create: (_) => MedicalEquipmentInjection.provideMedicalEquipmentBloc()..add(const LoadMedicalEquipmentCategoriesEvent()),
        ),
        BlocProvider(
          create: (_) => AmbulanceInjection.provideAmbulanceBloc()..add(const GetAmbulanceListEvent()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
