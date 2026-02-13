import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:finalproject/main.dart';
import 'package:finalproject/screens/meter_reading/add_reading_page.dart';
import 'package:finalproject/screens/main_layout.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notifications
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    try {
      tz_data.initializeTimeZones();
      // Try setting Cairo, but don't crash if it fails or device locale differs materially
      // Better yet, just rely on tz.local being populated by initializeTimeZones() defaults
      // or try finding 'Africa/Cairo' if you really want to target Egyptians explicitly.
      // But standard practice: Use device time.
      // However, since we use `tz.local` later, we need to ensure `tz.local` is set.
      // `initializeTimeZones` loads database but default `local` might be UTC.

      try {
        tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      } catch (e) {
        debugPrint('Could not set Cairo timezone, falling back to UTC/Default');
      }
    } catch (e) {
      debugPrint('Timezone initialization failed: $e');
    }

    // Android settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS settings
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

    // Create channel for Android 8.0+
    await _createNotificationChannel();

    _initialized = true;
    debugPrint('Notification Service Initialized');
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reading_reminder', // id
      'تذكير القراءة', // name
      description: 'تذكير شهري لإدخال قراءة العداد',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final status = await Permission.notification.request();

    if (status.isPermanentlyDenied) {
      debugPrint('Notification permission permanently denied');
      return false; // Let the UI handle opening settings
    }

    // For Exact Alarm permission (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }

    return status.isGranted;
  }

  /// Check if permissions are granted
  Future<bool> hasPermissions() async {
    return await Permission.notification.isGranted;
  }

  /// Send a test notification immediately
  Future<void> testNotification() async {
    if (!await hasPermissions()) {
      final granted = await requestPermissions();
      if (!granted) return;
    }

    await _notifications.show(
      999, // Test ID
      'تجربة الإشعارات',
      'الإشعارات تعمل بنجاح! سيتم تنبيهك هنا.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reading_reminder', // Use existing channel
          'تذكير القراءة',
          channelDescription: 'تذكير شهري لإدخال قراءة العداد',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFFD4AF37),
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Schedule reading reminder
  Future<void> scheduleReadingReminder({
    required DateTime scheduledDate, // Used for day of month reference
    required TimeOfDay scheduledTime, // Target Time
  }) async {
    if (!await hasPermissions()) {
      final granted = await requestPermissions();
      if (!granted) {
        debugPrint('Cannot schedule: Permissions denied');
        return;
      }
    }

    final now = DateTime.now();

    // Construct the target date next occurrence
    // Start with current month
    var targetDate = DateTime(
      now.year,
      now.month,
      scheduledDate.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    // If day is invalid for this month (e.g. 31st in Feb), DateTime automatically overflows to next month
    // We want to avoid that if possible, or handle it.
    // Standard DateTime handles overflow (e.g. Feb 31 -> March 3).
    // For monthly reminders, usually we want strict "Day X".
    // If the month doesn't have Day X, it might skip or go to last day.
    // However, simplicity first: The user picks a date. We respect the "Day of Month".

    // If the constructed time is in the past, move to next month
    if (targetDate.isBefore(now)) {
      targetDate = DateTime(
        now.year,
        now.month + 1,
        scheduledDate.day,
        scheduledTime.hour,
        scheduledTime.minute,
      );
    }

    // Convert to TZDateTime
    tz.TZDateTime tzScheduledDate;
    try {
      // Ensure local is initialized
      if (tz.local.name == 'UTC' &&
          tz.getLocation('Africa/Cairo').name != 'UTC') {
        try {
          tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
        } catch (_) {}
      }

      tzScheduledDate = tz.TZDateTime.from(targetDate, tz.local);
    } catch (e) {
      tzScheduledDate = tz.TZDateTime.from(targetDate, tz.UTC);
    }

    // Save to Hive Settings
    final settingsBox = await Hive.openBox('settings');
    await settingsBox.put('reminder_enabled', true);
    await settingsBox.put('reminder_date', targetDate.toIso8601String());

    // Cancel old scheduled notification
    await _notifications.cancel(0);

    try {
      await _notifications.zonedSchedule(
        0, // Notification ID
        'تذكير قراءة العداد',
        'حان وقت إدخال قراءة العداد الجديدة',
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reading_reminder',
            'تذكير القراءة',
            channelDescription: 'تذكير شهري لإدخال قراءة العداد',
            importance: Importance.max,
            priority: Priority.max,
            icon: '@mipmap/ic_launcher',
            color: Color(0xFFD4AF37), // Royal Gold
            playSound: true,
            enableVibration: true,
            styleInformation: BigTextStyleInformation(''),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents:
            DateTimeComponents.dayOfMonthAndTime, // Monthly recurrence
        payload: 'add_reading',
      );

      debugPrint('Scheduled Monthly Reminder at: $tzScheduledDate');

      // Optionally add a system log to history
      await _addToHistory(
        'تم جدولة التذكير',
        'سيتم تذكيرك يوم ${targetDate.day} من كل شهر الساعة ${targetDate.hour}:${targetDate.minute.toString().padLeft(2, '0')}',
        'system',
      );
    } catch (e) {
      debugPrint('Error scheduling: $e');
    }
  }

  /// Cancel reading reminder
  Future<void> cancelReadingReminder() async {
    await _notifications.cancel(0);

    final box = await Hive.openBox('settings');
    await box.put('reminder_enabled', false);
    await box.delete('reminder_date');

    debugPrint('Reading reminder cancelled');
  }

  /// Show budget alert (immediate)
  Future<void> showBudgetAlert(double exceededAmount) async {
    final box = await Hive.openBox('settings');
    final enabled = box.get('budget_alerts', defaultValue: true);

    if (!enabled) return;
    if (!await hasPermissions()) return;

    final title = 'تحذير الميزانية!';
    final body =
        'لقد تجاوزت ميزانيتك الشهرية بمقدار ${exceededAmount.toStringAsFixed(2)} جنيه';

    await _notifications.show(
      1, // Notification ID
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'تنبيهات الميزانية',
          channelDescription: 'تنبيه عند تجاوز الميزانية المحددة',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          color: Color(0xFFD4AF37),
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(''),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'budget_alert',
    );

    // Save to History
    await _addToHistory(title, body, 'budget_alert');

    debugPrint('Budget alert shown');
  }

  /// Add notification to persistent history
  Future<void> _addToHistory(String title, String body, String type) async {
    try {
      final historyBox = await Hive.openBox('notifications_history');

      final notificationData = {
        'title': title,
        'body': body,
        'date': DateTime.now().toIso8601String(),
        'type': type,
        'isRead': false,
      };

      await historyBox.add(notificationData);
    } catch (e) {
      debugPrint('Error saving notification history: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');

    if (response.payload == 'add_reading') {
      // Navigate to Add Reading Screen
      // Using a slight delay to ensure the app is ready/resumed
      Future.delayed(const Duration(milliseconds: 200), () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const AddReadingPage()),
        );
      });
    } else if (response.payload == 'budget_alert') {
      // Navigate to Analytics (ChartPage)
      Future.delayed(const Duration(milliseconds: 200), () {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) =>
                const MainLayout(initialIndex: 1), // Index 1 is ChartPage
          ),
          (route) =>
              false, // Clear stack so back button exits app or goes to home logically
        );
      });
    }
  }
}
