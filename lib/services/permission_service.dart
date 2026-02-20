import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/core/theme/app_colors.dart';

class PermissionService {
  static Future<bool> requestAllPermissions(BuildContext context) async {
    // Check if all permissions are already granted
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    final notificationStatus = await Permission.notification.status;

    if (cameraStatus.isGranted &&
        micStatus.isGranted &&
        notificationStatus.isGranted) {
      return true;
    }

    if (!context.mounted) return false;

    // Show explanation dialog
    final shouldRequest = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.security, color: AppColors.electricBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'الأذونات المطلوبة',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'يحتاج التطبيق للأذونات التالية:',
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildPermissionItem(
              icon: Icons.camera_alt,
              title: 'الكاميرا',
              description: 'لقراءة العداد بالصورة (OCR)',
            ),
            const SizedBox(height: 12),
            _buildPermissionItem(
              icon: Icons.mic,
              title: 'الميكروفون',
              description: 'لإدخال القراءة بالصوت',
            ),
            const SizedBox(height: 12),
            _buildPermissionItem(
              icon: Icons.notifications,
              title: 'الإشعارات',
              description: 'لتذكيرك بمواعيد القراءة',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'لاحقاً',
              style: GoogleFonts.cairo(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricBlue,
              foregroundColor: Colors.black,
            ),
            child: Text(
              'منح الأذونات',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldRequest != true) {
      return false;
    }

    // Request all permissions
    final Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.microphone,
      Permission.notification,
      Permission.scheduleExactAlarm,
    ].request();

    // Check if all granted
    final allGranted = statuses.values.every((status) => status.isGranted);

    if (!allGranted && context.mounted) {
      // Show warning if some permissions denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'بعض الأذونات لم تُمنح. قد لا تعمل بعض الميزات',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    }

    return allGranted;
  }

  static Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.electricBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.electricBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Check if a specific permission is granted
  static Future<bool> hasPermission(Permission permission) async {
    final status = await permission.status;
    return status.isGranted;
  }

  /// Request a specific permission
  static Future<bool> requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }
}
