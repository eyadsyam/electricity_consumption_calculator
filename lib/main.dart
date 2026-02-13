import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:finalproject/core/theme/app_theme.dart';
import 'package:finalproject/features/auth/presentation/pages/onboarding_page.dart';
import 'package:finalproject/features/auth/presentation/pages/login_page.dart';
import 'package:finalproject/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:finalproject/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:finalproject/features/devices/presentation/cubit/device_cubit.dart';
import 'package:finalproject/features/devices/domain/entities/user_device.dart';
import 'package:finalproject/features/devices/domain/entities/meter_reading.dart';
import 'package:finalproject/screens/main_layout.dart';
import 'package:finalproject/services/notification_service.dart';
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

  // Initialize Dependency Injection
  await di.init();

  // Initialize Notification Service
  await NotificationService().initialize();

  // Register Hive Adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserDeviceAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(MeterReadingAdapter());
  }

  // Open Hive boxes
  await Hive.openBox<UserDevice>('user_devices');
  await Hive.openBox<MeterReading>('meter_readings');
  await Hive.openBox('app_settings');
  await Hive.openBox('auth');
  await Hive.openBox('notifications_history');

  // Initialize GetStorage
  await GetStorage.init();

  runApp(const ElectraApp());
}

class ElectraApp extends StatelessWidget {
  const ElectraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthCubit>()..checkAuth()),
        BlocProvider(create: (_) => di.sl<NotificationCubit>()),
        BlocProvider(create: (_) => di.sl<DeviceCubit>()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Electra - Smart Energy Tracker',
        theme: AppTheme.darkTheme,
        home: const AppInitializer(),
      ),
    );
  }
}

/// Determines which page to show on app start
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  Future<Widget> _determineInitialPage() async {
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
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFD4AF37), // Royal Gold
            ),
          ),
        );
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
