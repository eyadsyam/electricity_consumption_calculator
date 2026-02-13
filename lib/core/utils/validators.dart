import '../constants/app_constants.dart';

/// Utility class for input validation
class Validators {
  Validators._(); // Private constructor

  /// Validate email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate Gmail specifically
  static bool isValidGmail(String email) {
    if (!isValidEmail(email)) return false;
    return email.toLowerCase().endsWith('@gmail.com');
  }

  /// Validate phone number (Egyptian format)
  static bool isValidPhone(String phone) {
    if (phone.isEmpty) return false;
    // Egyptian phone: starts with 01 and has 11 digits
    final phoneRegex = RegExp(r'^01[0-2,5]{1}[0-9]{8}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^\d]'), ''));
  }

  /// Validate name
  static bool isValidName(String name) {
    if (name.isEmpty) return false;
    if (name.length < AppConstants.minNameLength ||
        name.length > AppConstants.maxNameLength) {
      return false;
    }
    // Only letters and spaces
    final nameRegex = RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$');
    return nameRegex.hasMatch(name);
  }

  /// Validate reading value
  static bool isValidReading(int reading) {
    return reading >= AppConstants.minReadingValue &&
        reading <= AppConstants.maxReadingValue;
  }

  /// Validate reading comparison (new > old)
  static bool isNewReadingValid(int oldReading, int newReading) {
    return newReading > oldReading;
  }

  /// Validate budget amount
  static bool isValidBudget(double budget) {
    return budget > 0 && budget < 1000000; // Max 1 million
  }

  /// Get email error message
  static String? getEmailError(String email, {bool requireGmail = false}) {
    if (email.isEmpty) return 'Email is required';
    if (!isValidEmail(email)) return 'Invalid email format';
    if (requireGmail && !isValidGmail(email)) {
      return 'Email must be a Gmail address';
    }
    return null;
  }

  /// Get phone error message
  static String? getPhoneError(String phone) {
    if (phone.isEmpty) return 'Phone number is required';
    if (!isValidPhone(phone)) return 'Invalid phone number';
    return null;
  }

  /// Get name error message
  static String? getNameError(String name) {
    if (name.isEmpty) return 'Name is required';
    if (name.length < AppConstants.minNameLength) {
      return 'Name must be at least ${AppConstants.minNameLength} characters';
    }
    if (name.length > AppConstants.maxNameLength) {
      return 'Name must be less than ${AppConstants.maxNameLength} characters';
    }
    if (!isValidName(name)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Get reading error message
  static String? getReadingError(String readingStr) {
    if (readingStr.isEmpty) return 'Reading is required';
    final reading = int.tryParse(readingStr);
    if (reading == null) return 'Invalid reading value';
    if (!isValidReading(reading)) {
      return 'Reading must be between ${AppConstants.minReadingValue} and ${AppConstants.maxReadingValue}';
    }
    return null;
  }

  /// Get reading comparison error
  static String? getReadingComparisonError(int oldReading, int newReading) {
    if (!isNewReadingValid(oldReading, newReading)) {
      return 'New reading must be greater than old reading';
    }
    return null;
  }

  /// Get budget error message
  static String? getBudgetError(String budgetStr) {
    if (budgetStr.isEmpty) return 'Budget is required';
    final budget = double.tryParse(budgetStr);
    if (budget == null) return 'Invalid budget value';
    if (!isValidBudget(budget)) {
      return 'Budget must be a positive value';
    }
    return null;
  }
}
