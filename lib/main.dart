import 'package:finalproject/screens/chart/chart_screen.dart';
import 'package:finalproject/screens/history/history_screen.dart';
import 'package:finalproject/config/translations/app_language.dart';
import 'package:finalproject/screens/home/home_screen.dart';
import 'package:finalproject/screens/profile/profile_screen.dart';
import 'package:finalproject/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase/supabase.dart';

// Global Supabase client
late SupabaseClient supabase;

// --- Theme Definitions ---
final lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
  scaffoldBackgroundColor: const Color(0xFFF5F7FA),
  fontFamily: 'Poppins',
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.teal,
  scaffoldBackgroundColor: Colors.grey[900],
  fontFamily: 'Poppins',
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey[850],
    foregroundColor: Colors.white,
  ),
);
// -------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase Init (code skipped for brevity)

  // Hive Init
  await Hive.initFlutter();
  await Hive.openBox('readingsBox');
  await Hive.openBox('historyBox');

  await GetStorage.init();
  Get.put(AppTranslation());
  // Register the ThemeService using GetX
  Get.put(ThemeService());

  runApp(const ElectricityApp());
}

class ElectricityApp extends StatelessWidget {
  const ElectricityApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the registered service instance
    final themeService = Get.find<ThemeService>();

    final box = GetStorage();
    String savedLangCode = box.read('languageCode') ?? 'en';
    Locale initialLocale = Locale(savedLangCode);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Electricity App',

      // 1. Localization Setup
      translations: AppTranslation(), // Pass the registered instance
      locale: initialLocale, // Set the initial locale from the service
      fallbackLocale: const Locale('en'), // Ensure there's a fallback
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeService.themeMode,

      // أول صفحة هي RootPage عشان فيها الـ Navbar
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

// ... existing RootPage code ...

class _RootPageState extends State<RootPage> {
  int currentIndex = 0;

  // الصفحات المرتبطة بالـ Navbar
  final pages = const [HomeScreen(), HistoryPage(), ChartPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,

        onTap: (i) => setState(() => currentIndex = i),

        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: "Home".tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: "History".tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.auto_graph),
            label: "Graph".tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: "Profile".tr,
          ),
        ],
      ),
    );
  }
}
