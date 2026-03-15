import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'features/auth/auth_injection.dart';
import 'features/auth/presentation/providers/register_provider.dart';
import 'features/vendor_profile/vendor_profile_injection.dart';
import 'features/vendor_profile/presentation/providers/vendor_profile_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            updateStepOneUseCase: VendorProfileInjection.provideUpdateStepOneUseCase(),
            updateStepTwoUseCase: VendorProfileInjection.provideUpdateStepTwoUseCase(),
          ),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}
