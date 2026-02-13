import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/core/theme/app_colors.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "الإشعارات",
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.royalGold),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgBlack,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.bgBlack, Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: FutureBuilder(
            future: Hive.openBox('notifications_history'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.royalGold),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error loading notifications: ${snapshot.error}",
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                );
              }

              // After opening, use ValueListenableBuilder for reactivity
              return ValueListenableBuilder(
                valueListenable: Hive.box('notifications_history').listenable(),
                builder: (context, Box box, _) {
                  if (box.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Convert Map to List and sort by date descending
                  final notifications = box.values.toList().cast<Map>();
                  notifications.sort((a, b) {
                    final dateA =
                        DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
                    final dateB =
                        DateTime.tryParse(b['date'] ?? '') ?? DateTime.now();
                    return dateB.compareTo(dateA); // Newest first
                  });

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _buildNotificationCard(notification);
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.royalGold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 60,
              color: AppColors.royalGold.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "لا توجد إشعارات حالياً",
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "تحديثات استهلاكك وميزانيتك ستظهر هنا",
            style: GoogleFonts.cairo(color: Colors.white30, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map notification) {
    final title = notification['title'] ?? 'إشعار جديد';
    final body = notification['body'] ?? '';
    final dateStr = notification['date'] ?? '';
    final timestamp = DateTime.tryParse(dateStr) ?? DateTime.now();
    final type = notification['type'] ?? 'system';

    // Determine Icon based on Type
    IconData icon = Icons.notifications;
    Color iconColor = AppColors.royalGold;

    if (type == 'budget_alert') {
      icon = Icons.warning_amber_rounded;
      iconColor = AppColors.error;
    } else if (type == 'system') {
      icon = Icons.info_outline;
      iconColor = Colors.blueAccent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.deepSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              body,
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 12, color: Colors.white38),
                const SizedBox(width: 4),
                Text(
                  DateFormat('yyyy/MM/dd  hh:mm a', 'en').format(timestamp),
                  style: GoogleFonts.outfit(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
