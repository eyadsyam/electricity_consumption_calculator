/// Application-wide constants
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // App Info
  static const String appName = 'Electricity Tracker';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String themeKey = 'themeMode';
  static const String languageKey = 'languageCode';
  static const String readingsBoxName = 'readingsBox';
  static const String historyBoxName = 'historyBox';
  static const String userBoxName = 'userBox';

  // User Profile Keys
  static const String userNameKey = 'user_name';
  static const String userEmailKey = 'user_email';
  static const String profileImageKey = 'profile_image';

  // Budget Keys
  static const String budgetPrefix = 'budget_';

  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String monthYearFormat = 'MMMM yyyy';

  // Validation
  static const int minReadingValue = 0;
  static const int maxReadingValue = 999999;
  static const int minNameLength = 2;
  static const int maxNameLength = 50;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const int animationDuration = 300; // milliseconds

  // Electricity Rates (Fallback - should come from Supabase)
  static const List<Map<String, dynamic>> defaultElectricityRates = [
    {'rangeStart': 0, 'rangeEnd': 50, 'pricePerKwh': 0.48},
    {'rangeStart': 50, 'rangeEnd': 100, 'pricePerKwh': 0.58},
    {'rangeStart': 100, 'rangeEnd': 150, 'pricePerKwh': 0.77},
    {'rangeStart': 150, 'rangeEnd': 200, 'pricePerKwh': 0.90},
    {'rangeStart': 200, 'rangeEnd': 250, 'pricePerKwh': 1.20},
    {'rangeStart': 250, 'rangeEnd': null, 'pricePerKwh': 1.45},
  ];

  // Supabase Tables
  static const String electricityRatesTable = 'Electricity Rates';
  static const String complaintsTable = 'Complaints';

  // Error Messages
  static const String networkErrorMessage = 'No internet connection';
  static const String serverErrorMessage = 'Server error occurred';
  static const String cacheErrorMessage = 'Local storage error';
  static const String unknownErrorMessage = 'An unknown error occurred';

  // Months (for storage keys - untranslated)
  static const List<String> monthKeys = [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ];
}
