import 'dart:io';
import 'package:finalproject/screens/complaints/complaint_screen.dart';
import 'package:finalproject/services/theme_service.dart';
import 'package:finalproject/config/translations/app_language.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ThemeService themeService = Get.find<ThemeService>();
  final AppTranslation appTranslation = Get.find<AppTranslation>();

  final storage = GetStorage();
  final picker = ImagePicker();

  // المتغيرات اللي هتتغير
  late TextEditingController nameController;
  late TextEditingController emailController;
  String? profileImagePath;

  @override
  void initState() {
    super.initState();

    // جلب البيانات المحفوظة (لو موجودة) وإلا نستخدم قيم افتراضية
    String savedName = storage.read('user_name') ?? "user name";
    String savedEmail = storage.read('user_email') ?? "email@example.com";
    profileImagePath = storage.read('profile_image');

    nameController = TextEditingController(text: savedName);
    emailController = TextEditingController(text: savedEmail);
  }

  // دالة اختيار الصورة (من الجاليري أو الكاميرا)
  Future<void> pickImage() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text('camera'.tr),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (picked != null) {
                  setState(() => profileImagePath = picked.path);
                  await storage.write('profile_image', picked.path);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('gallary'.tr),
              onTap: () async {
                Navigator.pop(context);
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (picked != null) {
                  setState(() => profileImagePath = picked.path);
                  await storage.write('profile_image', picked.path);
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // حفظ الاسم والإيميل
  void saveUserData() {
    storage.write('user_name', nameController.text.trim());
    storage.write('user_email', emailController.text.trim());

    Get.snackbar(
      'saved'.tr,
      'data updated successfully'.tr,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 2),
    );
  }

  Widget buildProfileImage() {
    if (profileImagePath != null && File(profileImagePath!).existsSync()) {
      return CircleAvatar(
        radius: 70,
        backgroundImage: FileImage(File(profileImagePath!)),
      );
    } else {
      return const CircleAvatar(
        radius: 70,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 80, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = themeService.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'.tr),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => themeService.switchThemeMode(),
          ),
          TextButton(
            onPressed: () => appTranslation.changeLanguage('en'),
            child: const Text('EN', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => appTranslation.changeLanguage('ar'),
            child: const Text('AR', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // صورة البروفايل مع زر التعديل
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                buildProfileImage(),
                FloatingActionButton.small(
                  heroTag: "camera",
                  backgroundColor: Colors.blue,
                  onPressed: pickImage,
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // حقل الاسم
            TextField(
              controller: nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                labelText: 'الاسم'.tr,
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
            ),

            const SizedBox(height: 20),

            // حقل الإيميل
            TextField(
              controller: emailController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: 'email'.tr,
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
              ),
            ),

            const SizedBox(height: 40),

            // زر الحفظ
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: saveUserData,
                icon: const Icon(Icons.save),
                label: Text(
                  'add changes'.tr,
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // زر الشكاوى / FAQ
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Get.to(() => ComplaintPage()),
                icon: const Icon(Icons.help_outline),
                label: Text('FAQ'.tr),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
