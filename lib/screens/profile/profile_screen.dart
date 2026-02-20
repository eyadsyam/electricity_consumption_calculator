import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finalproject/features/auth/presentation/pages/login_page.dart';
import 'package:finalproject/screens/profile/developer_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'User';
  String userEmail = '';
  String userPhone = '';
  String? googlePhotoUrl;
  bool isGuest = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authBox = await Hive.openBox('auth');
    setState(() {
      userName = authBox.get('user_name', defaultValue: 'مستخدم');
      userEmail = authBox.get('email', defaultValue: '');
      userPhone = authBox.get('user_phone', defaultValue: '');
      googlePhotoUrl = authBox.get('photo');
      isGuest = authBox.get('is_guest', defaultValue: false);
    });
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: userName);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.edit, color: AppColors.electricBlue),
            const SizedBox(width: 10),
            Text(
              'تعديل الملف الشخصي',
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'الاسم',
                labelStyle: GoogleFonts.cairo(color: Colors.white54),
                filled: true,
                fillColor: AppColors.bgBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.person,
                  color: AppColors.electricBlue,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                final box = await Hive.openBox('auth');
                await box.put('user_name', newName);
                setState(() => userName = newName);
                if (ctx.mounted) Navigator.pop(ctx);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تحديث الاسم بنجاح',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: AppColors.electricBlue,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricBlue,
              foregroundColor: Colors.black,
            ),
            child: Text('حفظ', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      final bytes = await File(pickedFile.path).readAsBytes();
      final base64String = base64Encode(bytes);

      final box = await Hive.openBox('auth');
      await box.put('profile_image', base64String);

      if (mounted) {
        // Reload data to reflect changes
        _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تحديث الصورة الشخصية بنجاح',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: AppColors.electricBlue,
          ),
        );
      }
    }
  }

  Future<void> _budgetSettings() async {
    final settingsBox = await Hive.openBox('settings');
    final currentBudget = settingsBox.get('monthly_budget');
    final controller = TextEditingController(
      text: currentBudget?.toStringAsFixed(0) ?? '',
    );

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.account_balance_wallet,
              color: AppColors.electricBlue,
            ),
            const SizedBox(width: 10),
            Text(
              'إعدادات الميزانية',
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'حدد الميزانية الشهرية المتوقعة للكهرباء',
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'مثال: 500',
                hintStyle: GoogleFonts.cairo(color: Colors.white38),
                filled: true,
                fillColor: AppColors.bgBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                suffixText: 'جنيه',
                suffixStyle: GoogleFonts.cairo(color: AppColors.electricBlue),
                prefixIcon: const Icon(Icons.money, color: AppColors.electricBlue),
              ),
            ),
          ],
        ),
        actions: [
          if (currentBudget != null)
            TextButton(
              onPressed: () async {
                await settingsBox.delete('monthly_budget');
                if (ctx.mounted) Navigator.pop(ctx);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم إزالة الميزانية',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: AppColors.electricBlue,
                  ),
                );
              },
              child: Text('إزالة', style: GoogleFonts.cairo(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                await settingsBox.put('monthly_budget', value);
                if (ctx.mounted) Navigator.pop(ctx);

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تحديد الميزانية: ${value.toStringAsFixed(0)} جنيه',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: AppColors.electricBlue,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricBlue,
              foregroundColor: Colors.black,
            ),
            child: Text('حفظ', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  Future<void> _helpSupport() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.help, color: AppColors.electricBlue),
            const SizedBox(width: 10),
            Text(
              'المساعدة والدعم',
              style: GoogleFonts.cairo(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HelpItem(
                question: 'كيف أضيف قراءة جديدة؟',
                answer:
                    'اضغط على زر "تسجيل قراءة جديدة" في الصفحة الرئيسية، ثم أدخل القراءة الحالية.',
              ),
              const SizedBox(height: 15),
              _HelpItem(
                question: 'كيف يتم حساب الفاتورة؟',
                answer:
                    'يتم الحساب بناءً على أسعار الكهرباء الرسمية لعام 2024/2025 في مصر.',
              ),
              const SizedBox(height: 15),
              _HelpItem(
                question: 'ما هي ميزة مسح العداد؟',
                answer:
                    'يمكنك استخدام الكاميرا لقراءة العداد تلقائياً بدلاً من الكتابة اليدوية لضمان الدقة.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إغلاق',
              style: GoogleFonts.cairo(color: AppColors.electricBlue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepSurface,
        title: Text(
          'تسجيل الخروج',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        content: Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: GoogleFonts.cairo(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('تسجيل الخروج', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final authBox = await Hive.openBox('auth');
      await authBox.put('is_authenticated', false);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.bgBlack),
        child: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: Hive.box('auth').listenable(),
            builder: (context, Box box, _) {
              final userName = box.get('user_name', defaultValue: 'مستخدم');
              final userEmail = box.get('email', defaultValue: '');
              final isGuest = box.get('is_guest', defaultValue: false);
              final profileImageBase64 = box.get('profile_image');

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    FadeInDown(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.electricBlue,
                                    AppColors.electricBlue.withValues(alpha: 0.7),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: AppColors.deepSurface,
                                backgroundImage: googlePhotoUrl != null
                                    ? NetworkImage(googlePhotoUrl!)
                                    : (profileImageBase64 != null
                                              ? MemoryImage(
                                                  base64Decode(
                                                    profileImageBase64,
                                                  ),
                                                )
                                              : null)
                                          as ImageProvider?,
                                child:
                                    (googlePhotoUrl == null &&
                                        profileImageBase64 == null)
                                    ? Text(
                                        userName.isNotEmpty
                                            ? userName[0].toUpperCase()
                                            : 'U',
                                        style: GoogleFonts.outfit(
                                          fontSize: 48,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.electricBlue,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                            FloatingActionButton.small(
                              onPressed: _pickImage,
                              backgroundColor: AppColors.electricBlue,
                              child: const Icon(
                                Icons.edit,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    FadeInUp(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                userName,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: _editProfile,
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.electricBlue,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (userEmail.isNotEmpty)
                            Text(
                              userEmail,
                              style: GoogleFonts.cairo(
                                color: AppColors.electricBlue,
                                fontSize: 13,
                              ),
                            ),
                          if (isGuest)
                            Container(
                              margin: const EdgeInsets.only(top: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.electricBlue.withValues(
                                  alpha: 0.2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'وضع الضيف',
                                style: GoogleFonts.cairo(
                                  color: AppColors.electricBlue,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildProfileOption(
                      Icons.person_outline,
                      "تعديل الملف الشخصي",
                      _editProfile,
                    ),
                    _buildProfileOption(
                      Icons.account_balance_wallet_outlined,
                      "إعدادات الميزانية",
                      _budgetSettings,
                    ),

                    _buildProfileOption(
                      Icons.help_outline,
                      "المساعدة والدعم",
                      _helpSupport,
                    ),
                    _buildProfileOption(Icons.info_outline, "المطور", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeveloperScreen(),
                        ),
                      );
                    }),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _signOut,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        label: Text(
                          "تسجيل الخروج",
                          style: GoogleFonts.cairo(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return FadeInRight(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.deepSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.electricBlue, size: 24),
          ),
          title: Text(
            title,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white24,
            size: 16,
          ),
        ),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String question;
  final String answer;

  const _HelpItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: GoogleFonts.cairo(
            color: AppColors.electricBlue,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          answer,
          style: GoogleFonts.cairo(
            color: Colors.white70,
            fontSize: 12,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}
