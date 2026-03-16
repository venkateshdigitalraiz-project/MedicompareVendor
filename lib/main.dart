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
import 'router/app_router.dart';

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
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
      ),
    );
  }
}
