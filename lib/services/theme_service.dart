// lib/theme_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeService extends GetxService {
  final _box = Hive.box('readingsBox'); // Use your existing box
  final _key = 'themeMode';

  // 1. Get the current ThemeMode (defaults to System)
  ThemeMode get themeMode {
    final modeString = _box.get(_key) ?? 'system';
    return ThemeMode.values.firstWhere(
          (e) => e.name == modeString,
      orElse: () => ThemeMode.system,
    );
  }

  // 2. Cycle through modes (System -> Light -> Dark -> System)
  void switchThemeMode() {
    ThemeMode nextMode;
    switch (themeMode) {
      case ThemeMode.system:
        nextMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        nextMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        nextMode = ThemeMode.system;
        break;
    }

    // Apply the theme change immediately
    Get.changeThemeMode(nextMode);

    // Save the new mode for persistence
    _box.put(_key, nextMode.name);
  }

  // 3. Helper to determine the *currently displayed* brightness for UI icons
  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      // Check the platform brightness if ThemeMode.system is active
      return Get.isPlatformDarkMode;
    }
    return themeMode == ThemeMode.dark;
  }
}