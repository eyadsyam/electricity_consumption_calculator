import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AppTranslation extends Translations {
  final _box = GetStorage();
  final _key = 'languageCode';

  @override
  // TODO: implement keys
  Map<String, Map<String, String>> get keys =>
      {
        'en': {
          // --- PROFILE & GENERAL ---
          'FAQ': 'FAQ',
          'APP_TITLE': 'Electricity Tracker',
          'SYSTEM': 'System',
          // Theme toggle mode name

          // --- MONTHS & YEAR (For HomeScreen list/data storage) ---
          'JANUARY': 'January',
          'FEBRUARY': 'February',
          'MARCH': 'March',
          'APRIL': 'April',
          'MAY': 'May',
          'JUNE': 'June',
          'JULY': 'July',
          'AUGUST': 'August',
          'SEPTEMBER': 'September',
          'OCTOBER': 'October',
          'NOVEMBER': 'November',
          'DECEMBER': 'December',
          'YEAR_2025': '2025',

          // --- COMPLAINT PAGE STRINGS ---
          'ERROR': 'Error',
          'EMAIL_VALIDATION': 'Email must be a Gmail address',
          'MESSAGE_VALIDATION': 'Please write the complaint content',
          'SENT_SUCCESS_TITLE': 'Sent Successfully',
          'SENT_SUCCESS_BODY': 'The complaint has been sent to the Ministry',
          'SENT_FAILURE_BODY': 'Failed to send the complaint',
          'FORM_NAME': 'Name',
          'FORM_EMAIL': 'Email',
          'FORM_PHONE': 'Phone Number',
          'FORM_DATE': 'Date',
          'FORM_MESSAGE': 'Complaint Content',
          'FORM_SEND_BUTTON': 'Send',

          // --- HISTORY PAGE KEYS (REUSED IN HOMESCREEN) ---
          'HISTORY_TITLE': 'History',
          'HISTORY_EMPTY_TITLE': 'No History Yet',
          'HISTORY_EMPTY_SUBTITLE': 'Start adding your electricity readings',
          'HISTORY_TRANSACTIONS_PLURAL': 'transactions',
          'HISTORY_TRANSACTION_SINGULAR': 'transaction',
          'HISTORY_DELETE_SNACKBAR': 'Transaction Deleted',
          'HISTORY_BILL_TITLE': 'Electricity Bill',
          'HISTORY_READING_OLD': 'Old',
          'HISTORY_READING_NEW': 'New',
          'HISTORY_CONSUMPTION': 'Consumption',

          // --- HOME SCREEN SPECIFIC KEYS ---
          'BALANCE_CARD_TITLE': 'My finances in 2025',
          'NET_BALANCE_LABEL': 'Net Balance',
          'BUDGET_BUTTON': 'Budget',
          'BUDGET_LABEL': 'Budget: EGP @amount',
          // GetX param
          'OVER_BUDGET_STATUS': 'Over Budget',
          'FOR_MONTH_LABEL': 'for @month',
          // GetX param

          'SELECT_MONTH_TITLE': 'Select Month',
          'RECENT_TRANSACTION_TITLE': 'Recent Transaction',
          'ADD_READING_BUTTON': 'Add Reading',

          'NO_TRANSACTIONS_FOR_MONTH': 'No transactions for @month',
          // GetX param
          'ADD_FIRST_READING_HINT': 'Add your first reading',

          'SET_BUDGET_TITLE': 'Set Budget for @month',
          // GetX param
          'BUDGET_DIALOG_MESSAGE': 'Enter your monthly electricity budget',
          'BUDGET_AMOUNT_LABEL': 'Budget Amount',
          'REMOVE_BUDGET_BUTTON': 'Remove Budget',
          'CANCEL_BUTTON': 'Cancel',
          'SAVE_BUTTON': 'Save',

          // --- ADD READING SHEET KEYS ---
          'READING_SHEET_TITLE': 'Add Reading for @month',
          'READING_FIELD_OLD_LABEL': 'Old Reading (Start of Month)',
          'READING_FIELD_NEW_LABEL': 'New Reading (End of Month)',
          'READING_FIELD_HINT': 'Enter reading',

          'VALIDATION_ENTER_READINGS': 'Please enter valid readings',
          'VALIDATION_NEW_GREATER': 'New reading must be greater than old reading',
          'SUCCESS_SAVE_SNACKBAR': 'Reading saved! Bill: EGP @bill',

          'BUTTON_CALCULATE_SAVE': 'Calculate & Save',

          // --- UTILITY/VOICE/OCR KEYS (ReadingUtils) ---
          'PERMISSION_MIC_DENIED': 'Mic permission denied. Please allow it in settings.',
          'SPEECH_NOT_AVAILABLE': 'Speech recognition not available',

          'IMAGE_SOURCE_CAMERA': 'Camera',
          'IMAGE_SOURCE_GALLERY': 'Gallery',

          'OCR_READING_DETECTED': 'Reading detected: @numbers',
          // GetX param
          'OCR_NO_NUMBERS': 'No numbers found in image',
          'OCR_ERROR': 'Error: @error',
          // GetX param
        },

        'ar':
        {
          // --- PROFILE & GENERAL ---
          'FAQ': 'الأسئلة المتكررة',
          'APP_TITLE': 'متتبع الكهرباء',
          'SYSTEM': 'النظام',

          // --- MONTHS & YEAR (For HomeScreen list/data storage) ---
          'JANUARY': 'يناير',
          'FEBRUARY': 'فبراير',
          'MARCH': 'مارس',
          'APRIL': 'أبريل',
          'MAY': 'مايو',
          'JUNE': 'يونيو',
          'JULY': 'يوليو',
          'AUGUST': 'أغسطس',
          'SEPTEMBER': 'سبتمبر',
          'OCTOBER': 'أكتوبر',
          'NOVEMBER': 'نوفمبر',
          'DECEMBER': 'ديسمبر',
          'YEAR_2025': '٢٠٢٥',

          // --- COMPLAINT PAGE STRINGS ---
          'ERROR': 'خطأ',
          'EMAIL_VALIDATION': 'الإيميل يجب أن يكون Gmail',
          'MESSAGE_VALIDATION': 'اكتب محتوى الشكوى',
          'SENT_SUCCESS_TITLE': 'تم الإرسال',
          'SENT_SUCCESS_BODY': 'تم إرسال الشكوى للوزارة',
          // labels
          'SENT_FAILURE_BODY': 'فشل إرسال الشكوى',
          'FORM_NAME': 'الإسم',
          'FORM_EMAIL': 'البريد الإلكتروني',
          'FORM_PHONE': 'رقم الهاتف',
          'FORM_DATE': 'التاريخ',
          'FORM_MESSAGE': 'محتوى الشكوى',
          'FORM_SEND_BUTTON': 'إرسال',


          // --- HISTORY PAGE KEYS (REUSED IN HOMESCREEN) ---
          'HISTORY_TITLE': 'السجل',
          'HISTORY_EMPTY_TITLE': 'لا يوجد سجل بعد',
          'HISTORY_EMPTY_SUBTITLE': 'ابدأ بإضافة قراءات عداد الكهرباء',
          'HISTORY_TRANSACTIONS_PLURAL': 'تعاملات',
          'HISTORY_TRANSACTION_SINGULAR': 'تعامل',
          'HISTORY_DELETE_SNACKBAR': 'تم حذف التعامل',
          'HISTORY_BILL_TITLE': 'فاتورة الكهرباء',
          'HISTORY_READING_OLD': 'القديمة',
          'HISTORY_READING_NEW': 'الجديدة',
          'HISTORY_CONSUMPTION': 'الاستهلاك',

          // --- HOME SCREEN SPECIFIC KEYS ---
          'BALANCE_CARD_TITLE': 'حساباتي في ٢٠٢٥',
          'NET_BALANCE_LABEL': 'صافي الرصيد',
          'BUDGET_BUTTON': 'الميزانية',
          'BUDGET_LABEL': 'الميزانية: @amount جنيه',
          'OVER_BUDGET_STATUS': 'تجاوزت الميزانية',
          'FOR_MONTH_LABEL': 'لشهر @month',

          'SELECT_MONTH_TITLE': 'اختر الشهر',
          'RECENT_TRANSACTION_TITLE': 'آخر تعامل',
          'ADD_READING_BUTTON': 'إضافة قراءة',

          'NO_TRANSACTIONS_FOR_MONTH': 'لا توجد تعاملات لشهر @month',
          'ADD_FIRST_READING_HINT': 'أضف أول قراءة لك',

          'SET_BUDGET_TITLE': 'تحديد ميزانية لشهر @month',
          'BUDGET_DIALOG_MESSAGE': 'أدخل ميزانية الكهرباء الشهرية',
          'BUDGET_AMOUNT_LABEL': 'قيمة الميزانية',
          'REMOVE_BUDGET_BUTTON': 'إزالة الميزانية',
          'CANCEL_BUTTON': 'إلغاء',
          'SAVE_BUTTON': 'حفظ',

          // --- ADD READING SHEET KEYS ---
          'READING_SHEET_TITLE': 'إضافة قراءة لشهر @month',
          'READING_FIELD_OLD_LABEL': 'القراءة القديمة (بداية الشهر)',
          'READING_FIELD_NEW_LABEL': 'القراءة الجديدة (نهاية الشهر)',
          'READING_FIELD_HINT': 'أدخل القراءة',

          'VALIDATION_ENTER_READINGS': 'الرجاء إدخال قراءات صحيحة',
          'VALIDATION_NEW_GREATER': 'يجب أن تكون القراءة الجديدة أكبر من القديمة',
          'SUCCESS_SAVE_SNACKBAR': 'تم حفظ القراءة! الفاتورة: @bill جنيه',

          'BUTTON_CALCULATE_SAVE': 'حساب وحفظ',

          // --- UTILITY/VOICE/OCR KEYS (ReadingUtils) ---
          'PERMISSION_MIC_DENIED': 'تم رفض إذن الميكروفون. يرجى السماح به في الإعدادات.',
          'SPEECH_NOT_AVAILABLE': 'التعرف على الكلام غير متوفر',

          'IMAGE_SOURCE_CAMERA': 'الكاميرا',
          'IMAGE_SOURCE_GALLERY': 'المعرض',

          'OCR_READING_DETECTED': 'تم الكشف عن القراءة: @numbers',
          'OCR_NO_NUMBERS': 'لم يتم العثور على أرقام في الصورة',
          'OCR_ERROR': 'خطأ: @error',


        }
      };

// Method to get the stored locale code or default to 'en'
  String get initialLanguage => _box.read(_key) ?? 'en';

  // Method to change the language and store the preference
  void changeLanguage(String langCode) {
    if (langCode != Get.locale?.languageCode) {
      final newLocale = Locale(langCode);

      // 1. Update GetX locale
      Get.updateLocale(newLocale);

      // 2. Persist the choice
      _box.write(_key, langCode);
    }
  }
}