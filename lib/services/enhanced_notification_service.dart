import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'tariff_calculator.dart';

class EnhancedNotificationService {
  static final EnhancedNotificationService _instance =
      EnhancedNotificationService._internal();
  factory EnhancedNotificationService() => _instance;
  EnhancedNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // Notification IDs
  static const int readingReminderId = 0;
  static const int budgetAlertId = 1;
  static const int tierChangeId = 2;
  static const int savingsTipId = 3;
  static const int highConsumptionId = 4;

  /// Initialize notifications with Electra branding
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    await _createNotificationChannels();

    _initialized = true;
    debugPrint('✅ Enhanced Notification Service Initialized');
  }

  /// Create themed notification channels
  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'reading_reminder',
        'تذكير القراءة',
        description: 'تذكير شهري لإدخال قراءة العداد',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        ledColor: Color(0xFFD4AF37), // Royal Gold
      ),
      AndroidNotificationChannel(
        'budget_alert',
        'تنبيه الميزانية',
        description: 'تنبيه عند تجاوز الميزانية الشهرية',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        ledColor: Color(0xFFD32F2F), // Red
      ),
      AndroidNotificationChannel(
        'tier_change',
        'تغيير الشريحة',
        description: 'إشعار عند الانتقال لشريحة كهربائية جديدة',
        importance: Importance.high,
        playSound: true,
        ledColor: Color(0xFFFF9800), // Orange
      ),
      AndroidNotificationChannel(
        'savings_tips',
        'نصائح التوفير',
        description: 'نصائح يومية لتوفير الكهرباء',
        importance: Importance.defaultImportance,
        playSound: false,
        ledColor: Color(0xFF4CAF50), // Green
      ),
    ];

    for (final channel in channels) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();

    if (status.isGranted) {
      debugPrint('✅ Notification permission granted');
      return true;
    } else if (status.isDenied) {
      debugPrint('⚠️ Notification permission denied');
      return false;
    } else if (status.isPermanentlyDenied) {
      debugPrint('❌ Notification permission permanently denied');
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Check if permissions are granted
  Future<bool> hasPermissions() async {
    return await Permission.notification.isGranted;
  }

  /// Schedule reading reminder with elegant styling
  Future<void> scheduleReadingReminder({
    required DateTime scheduledDate,
    required TimeOfDay scheduledTime,
  }) async {
    if (!await hasPermissions()) {
      final granted = await requestPermissions();
      if (!granted) return;
    }

    final scheduledDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    final tzScheduledDate = tz.TZDateTime.from(scheduledDateTime, tz.local);

    final box = await Hive.openBox('settings');
    await box.put('reminder_enabled', true);
    await box.put('reminder_date', scheduledDateTime.toIso8601String());

    await _notifications.zonedSchedule(
      readingReminderId,
      '⚡ Electra - تذكير قراءة العداد',
      'حان وقت تسجيل قراءة العداد الشهرية لمتابعة استهلاكك',
      tzScheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reading_reminder',
          'تذكير القراءة',
          channelDescription: 'تذكير شهري لإدخال قراءة العداد',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFD4AF37),
          playSound: true,
          enableVibration: true,
          styleInformation: const BigTextStyleInformation(
            'افتح Electra الآن لتسجيل قراءتك الجديدة وتتبع استهلاكك بدقة',
            contentTitle: '⚡ Electra - تذكير قراءة العداد',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint('✅ Reading reminder scheduled for: $scheduledDateTime');
  }

  /// Cancel reading reminder
  Future<void> cancelReadingReminder() async {
    await _notifications.cancel(readingReminderId);

    final box = await Hive.openBox('settings');
    await box.put('reminder_enabled', false);
    await box.delete('reminder_date');

    debugPrint('✅ Reading reminder cancelled');
  }

  /// Show budget alert with detailed breakdown
  Future<void> showBudgetAlert({
    required double currentCost,
    required double budget,
  }) async {
    if (!await hasPermissions()) return;

    final box = await Hive.openBox('settings');
    final budgetAlertsEnabled = box.get('budget_alerts', defaultValue: true);

    if (!budgetAlertsEnabled) return;

    final exceededAmount = currentCost - budget;
    final percentage = ((currentCost / budget) * 100).toStringAsFixed(0);

    await _notifications.show(
      budgetAlertId,
      '💰 تحذير الميزانية - Electra',
      'لقد تجاوزت ميزانيتك بنسبة $percentage%',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alert',
          'تنبيه الميزانية',
          channelDescription: 'تنبيه عند تجاوز الميزانية الشهرية',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFD32F2F),
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(
            '💸 التكلفة الحالية: ${currentCost.toStringAsFixed(2)} جنيه\n'
            '📊 الميزانية المحددة: ${budget.toStringAsFixed(2)} جنيه\n'
            '⚠️ التجاوز: ${exceededAmount.toStringAsFixed(2)} جنيه\n\n'
            'راجع استهلاكك في Electra لتوفير المزيد',
            contentTitle: '💰 تحذير الميزانية - Electra',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    debugPrint('✅ Budget alert shown');
  }

  /// Show tier change notification
  Future<void> showTierChangeNotification({
    required String oldTier,
    required String newTier,
    required double consumption,
  }) async {
    if (!await hasPermissions()) return;

    final tierColor = TariffCalculator.getTierColor(newTier);
    final tip = TariffCalculator.getSavingsTip(newTier);

    await _notifications.show(
      tierChangeId,
      '📊 تغيير الشريحة - Electra',
      'انتقلت من $oldTier إلى $newTier',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'tier_change',
          'تغيير الشريحة',
          channelDescription: 'إشعار عند الانتقال لشريحة كهربائية جديدة',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(tierColor),
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(
            '⚡ الاستهلاك الحالي: ${consumption.toStringAsFixed(0)} كيلووات\n'
            '📈 الشريحة الجديدة: $newTier\n\n'
            '💡 نصيحة: $tip',
            contentTitle: '📊 تغيير الشريحة - Electra',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );

    debugPrint('✅ Tier change notification shown');
  }

  /// Show daily savings tip
  Future<void> showDailySavingsTip(String tip) async {
    if (!await hasPermissions()) return;

    final box = await Hive.openBox('settings');
    final tipsEnabled = box.get('daily_tips', defaultValue: true);

    if (!tipsEnabled) return;

    await _notifications.show(
      savingsTipId,
      '💡 نصيحة اليوم - Electra',
      tip,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'savings_tips',
          'نصائح التوفير',
          channelDescription: 'نصائح يومية لتوفير الكهرباء',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFF4CAF50),
          playSound: false,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
    );
  }

  /// Show high consumption warning
  Future<void> showHighConsumptionWarning({
    required double dailyConsumption,
    required double projectedMonthly,
  }) async {
    if (!await hasPermissions()) return;

    await _notifications.show(
      highConsumptionId,
      '⚠️ تحذير استهلاك مرتفع - Electra',
      'استهلاكك اليومي أعلى من المعتاد',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alert',
          'تنبيه الميزانية',
          channelDescription: 'تنبيه عند ارتفاع الاستهلاك',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: const Color(0xFFFF5722),
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(
            '📊 الاستهلاك اليومي: ${dailyConsumption.toStringAsFixed(1)} كيلووات\n'
            '📈 الاستهلاك المتوقع للشهر: ${projectedMonthly.toStringAsFixed(0)} كيلووات\n\n'
            'راجع الأجهزة المستخدمة لتقليل الاستهلاك',
            contentTitle: '⚠️ تحذير استهلاك مرتفع - Electra',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Show test notification
  Future<void> showTestNotification() async {
    if (!await hasPermissions()) {
      final granted = await requestPermissions();
      if (!granted) return;
    }

    await _notifications.show(
      999,
      '✅ اختبار الإشعارات - Electra',
      'الإشعارات تعمل بنجاح!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test',
          'اختبار',
          channelDescription: 'قناة اختبار الإشعارات',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFD4AF37),
          styleInformation: BigTextStyleInformation(
            'نظام الإشعارات في Electra يعمل بشكل مثالي ✨',
            contentTitle: '✅ اختبار الإشعارات - Electra',
          ),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📱 Notification tapped: ${response.payload}');
    // Navigation will be handled by the app's navigation system
  }

  /// Get scheduled reminder info
  Future<Map<String, dynamic>?> getScheduledReminder() async {
    final box = await Hive.openBox('settings');
    final enabled = box.get('reminder_enabled', defaultValue: false);
    final dateStr = box.get('reminder_date');

    if (!enabled || dateStr == null) return null;

    return {'enabled': enabled, 'date': DateTime.parse(dateStr)};
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('✅ All notifications cancelled');
  }
}
