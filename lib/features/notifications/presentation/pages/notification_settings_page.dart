import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:finalproject/services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // State variables
  bool _budgetAlertsEnabled = true;
  double _budgetThreshold = 100.0; // Default 100%

  bool _readingReminderEnabled = false;
  int _reminderDay = 1;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 9, minute: 0);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox('settings');

    setState(() {
      _budgetAlertsEnabled = box.get('budget_alerts', defaultValue: true);
      _budgetThreshold = box.get('budget_threshold', defaultValue: 100.0);

      _readingReminderEnabled = box.get(
        'reading_reminders',
        defaultValue: false,
      );

      final dateStr = box.get('scheduled_date');
      if (dateStr != null) {
        final date = DateTime.parse(dateStr);
        _reminderDay = date.day;
        _reminderTime = TimeOfDay.fromDateTime(date);
      } else {
        _reminderDay = DateTime.now().day;
        _reminderTime = TimeOfDay.fromDateTime(DateTime.now());
      }

      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    final box = await Hive.openBox('settings');
    await box.put('budget_alerts', _budgetAlertsEnabled);
    await box.put('budget_threshold', _budgetThreshold);
    await box.put('reading_reminders', _readingReminderEnabled);

    final notificationService = NotificationService();

    if (_readingReminderEnabled) {
      // Create a DateTime for the next occurrence of this day/time
      final now = DateTime.now();
      var scheduledDate = DateTime(
        now.year,
        now.month,
        _reminderDay,
        _reminderTime.hour,
        _reminderTime.minute,
      );

      // If day is invalid (e.g., 31st in Feb), Dart handles it by rolling over.
      // Ideally we should clamp or handle closer, but for now we trust the user or Dart's rollover.
      // But we need to save it.

      await box.put('scheduled_date', scheduledDate.toIso8601String());

      await notificationService.cancelReadingReminder();
      await notificationService.scheduleReadingReminder(
        scheduledDate: scheduledDate,
        scheduledTime: _reminderTime,
      );
    } else {
      await box.delete('scheduled_date');
      await notificationService.cancelReadingReminder();
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ الإعدادات بنجاح', style: GoogleFonts.cairo()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBlack,
      appBar: AppBar(
        title: Text(
          "إعدادات التنبيهات",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.royalGold),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.royalGold),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    "تنبيهات الميزانية",
                    Icons.account_balance_wallet,
                  ),
                  const SizedBox(height: 15),
                  _buildBudgetSection(),

                  const SizedBox(height: 40),

                  _buildSectionHeader(
                    "تذكير قراءة العداد",
                    Icons.notifications_active,
                  ),
                  const SizedBox(height: 15),
                  _buildReminderSection(),

                  const SizedBox(height: 40),

                  _buildTestSection(),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.royalGold,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        "حفظ التغييرات",
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.royalGold, size: 28),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.deepSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "تفعيل تنبيهات الميزانية",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "تنبيه عند تجاوز حد معين من الميزانية",
              style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
            ),
            activeColor: AppColors.royalGold,
            value: _budgetAlertsEnabled,
            onChanged: (val) => setState(() => _budgetAlertsEnabled = val),
          ),
          if (_budgetAlertsEnabled) ...[
            const Divider(color: Colors.white10),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "حد التنبيه:",
                  style: GoogleFonts.cairo(color: Colors.white70),
                ),
                Text(
                  "${_budgetThreshold.toInt()}%",
                  style: GoogleFonts.outfit(
                    color: AppColors.royalGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            Slider(
              value: _budgetThreshold,
              min: 50,
              max: 120,
              divisions: 14,
              activeColor: AppColors.royalGold,
              inactiveColor: Colors.white10,
              label: "${_budgetThreshold.toInt()}%",
              onChanged: (val) => setState(() => _budgetThreshold = val),
            ),
            Text(
              "سيتم تنبيهك عندما يصل استهلاكك إلى ${_budgetThreshold.toInt()}% من الميزانية المحددة.",
              style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReminderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.deepSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "تفعيل التذكير الشهري",
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "تذكير لإدخال قراءة العداد كل شهر",
              style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
            ),
            activeColor: AppColors.royalGold,
            value: _readingReminderEnabled,
            onChanged: (val) => setState(() => _readingReminderEnabled = val),
          ),
          if (_readingReminderEnabled) ...[
            const Divider(color: Colors.white10),
            const SizedBox(height: 15),
            _buildPickerRow(
              "يوم التذكير",
              "يوم $_reminderDay من كل شهر",
              Icons.calendar_today,
              () => _pickDay(),
            ),
            const SizedBox(height: 15),
            _buildPickerRow(
              "وقت التذكير",
              _formatTime(_reminderTime),
              Icons.access_time,
              () => _pickTime(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPickerRow(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white54, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.cairo(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white24,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.royalGold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bug_report_outlined, color: AppColors.royalGold),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "اختبار الإشعارات",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "تأكد من أن جهازك يستقبل التنبيهات بنجاح",
                  style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await NotificationService().testNotification();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              side: const BorderSide(color: AppColors.royalGold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              "اختبار",
              style: GoogleFonts.cairo(color: AppColors.royalGold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDay() async {
    // Simple integer picker or just a list of days
    // Using a simple dialog with a list for simplicity and style
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepSurface,
        title: Text(
          "اختر يوم التذكير",
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: 31,
            itemBuilder: (ctx, index) {
              final day = index + 1;
              final isSelected = day == _reminderDay;
              return InkWell(
                onTap: () {
                  setState(() => _reminderDay = day);
                  Navigator.pop(ctx);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.royalGold : Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? null
                        : Border.all(color: Colors.white10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "$day",
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.royalGold,
              onPrimary: Colors.black,
              surface: AppColors.deepSurface,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.deepSurface,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    // Format to Arabic if needed, or just 12h format
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a', 'ar').format(dt);
  }
}
