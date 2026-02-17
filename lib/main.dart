import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:finalproject/core/theme/app_theme.dart';
import 'package:finalproject/features/auth/presentation/pages/onboarding_page.dart';
import 'package:finalproject/features/auth/presentation/pages/login_page.dart';
import 'package:finalproject/features/auth/presentation/cubit/auth_cubit.dart';

import 'package:finalproject/features/devices/presentation/cubit/device_cubit.dart';
import 'package:finalproject/features/devices/domain/entities/user_device.dart';
import 'package:finalproject/features/electricity_tracking/domain/entities/meter_reading.dart';
import 'package:finalproject/features/electricity_tracking/domain/entities/budget_config.dart';
import 'package:finalproject/screens/main_layout.dart';
import 'package:finalproject/screens/splash/splash_screen.dart';

import 'package:finalproject/services/permission_service.dart';
import 'package:finalproject/core/di/injection.dart' as di;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Intl for Arabic locale
  await initializeDateFormatting('ar', null);
  Intl.defaultLocale = 'ar';

  // Initialize Hive first
  await Hive.initFlutter();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://bmchbrtqsqmrlzthjdod.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJtY2hicnRxc3Ftcmx6dGhqZG9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMzQyNjIsImV4cCI6MjA4NTgxMDI2Mn0.RuDnSoGFkf2oK1brpcF50xCaKORbg7xdwd1BLmx1FlA',
  );

  // Initialize Dependency Injection
  await di.init();

  // Register Hive Adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserDeviceAdapter());
  }
  // Register MeterReadingAdapter (Type 5 based on entity file)
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(MeterReadingAdapter());
  }
  // Register BudgetConfigAdapter (Type 2 based on entity file)
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(BudgetConfigAdapter());
  }
  // Register Tariff Entities if needed (Type 3 & 4)

  // Open Hive boxes
  await Hive.openBox<UserDevice>('user_devices');
  await Hive.openBox<MeterReading>('meter_readings');
  await Hive.openBox<BudgetConfig>('budget_configs');
  await Hive.openBox('app_settings');
  await Hive.openBox('auth');

  runApp(const ElectraApp());
}

class ElectraApp extends StatelessWidget {
  const ElectraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()..checkAuth()),

        BlocProvider(create: (_) => di.sl<DeviceCubit>()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Electra - Smart Energy Tracker',
        theme: AppTheme.darkTheme,
        builder: (context, child) {
          // Force text scale factor to 1.0 to respect the design
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: child!,
          );
        },
        home: const AppInitializer(),
      ),
    );
  }
}

/// Determines which page to show on app start
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  Future<Widget> _determineInitialPage() async {
    // Show splash for at least 2.5 seconds
    await Future.delayed(const Duration(milliseconds: 2500));

    final settingsBox = Hive.box('app_settings');
    final authBox = Hive.box('auth');

    // Check if onboarding was completed
    final onboardingCompleted = settingsBox.get(
      'onboarding_completed',
      defaultValue: false,
    );

    // Check if user is authenticated
    final isAuthenticated = authBox.get(
      'is_authenticated',
      defaultValue: false,
    );

    // Check if permissions were requested
    final permissionsRequested = settingsBox.get(
      'permissions_requested',
      defaultValue: false,
    );

    Widget initialPage;
    if (!onboardingCompleted) {
      // First time user - show onboarding
      initialPage = const OnboardingPage();
    } else if (isAuthenticated) {
      // User is logged in - go to main app
      initialPage = const MainLayout();
    } else {
      // User completed onboarding but not logged in - show login
      initialPage = const LoginPage();
    }

    // Request permissions after login/onboarding
    if (onboardingCompleted && !permissionsRequested) {
      return _PermissionRequestWrapper(
        child: initialPage,
        onPermissionsHandled: () async {
          await settingsBox.put('permissions_requested', true);
        },
      );
    }

    return initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _determineInitialPage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return snapshot.data ?? const OnboardingPage();
        }
        // Show splash screen while determining
        return const SplashScreen();
      },
    );
  }
}

/// Wrapper to request permissions after app initialization
class _PermissionRequestWrapper extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onPermissionsHandled;

  const _PermissionRequestWrapper({
    required this.child,
    required this.onPermissionsHandled,
  });

  @override
  State<_PermissionRequestWrapper> createState() =>
      _PermissionRequestWrapperState();
}

class _PermissionRequestWrapperState extends State<_PermissionRequestWrapper> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Wait a bit for the UI to settle
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      await PermissionService.requestAllPermissions(context);
      await widget.onPermissionsHandled();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
