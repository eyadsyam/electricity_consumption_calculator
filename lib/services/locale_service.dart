import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LocaleController extends GetxController {
  final _box = GetStorage();
  final String _key = 'languageCode';


  String get currentLanguage => _box.read(_key) ?? 'en';


  void changeLanguage(String langCode) {

    final newLocale = Locale(langCode);
    // Update the language in the GetMaterialApp
    Get.updateLocale(newLocale);

    // Save the new language code to local storage for persistence
    _box.write(_key, langCode);
  }
}