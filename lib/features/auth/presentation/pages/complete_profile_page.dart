import 'package:finalproject/core/theme/app_colors.dart';
import 'package:finalproject/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:finalproject/screens/main_layout.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CompleteProfilePage extends StatefulWidget {
  final String? initialName;
  final String? photoUrl;
  const CompleteProfilePage({super.key, this.initialName, this.photoUrl});

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _localImagePath;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _photoUrl = widget.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _localImagePath = image.path;
      });
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final box = await Hive.openBox('auth');
    await box.put('user_name', name);

    // Save local image path if selected
    if (_localImagePath != null) {
      await box.put('user_local_image', _localImagePath);
    }

    if (!mounted) return;

    // Navigate to Home
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainLayout()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBlack,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.luxuryDarkGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.electricBlue,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.deepSurface,
                          backgroundImage: _localImagePath != null
                              ? FileImage(File(_localImagePath!))
                                    as ImageProvider
                              : (_photoUrl != null
                                        ? NetworkImage(_photoUrl!)
                                        : const AssetImage(
                                            'assets/images/user_avatar.png',
                                          ))
                                    as ImageProvider,
                          child: _localImagePath == null && _photoUrl == null
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white54,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.electricBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "استكمال البيانات",
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.electricBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "يرجى إدخال اسمك بالكامل باللغة العربية",
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  const SizedBox(height: 40),
                  TextFormField(
                    autofocus: true, // Auto-focus enabled
                    controller: _nameController,
                    style: GoogleFonts.cairo(color: Colors.white),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.deepSurface,
                      hintText:
                          widget.initialName != null &&
                              widget.initialName!.isNotEmpty
                          ? widget.initialName
                          : "الاسم بالكامل",
                      hintStyle: GoogleFonts.cairo(color: Colors.white38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: AppColors.electricBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(
                          color: AppColors.electricBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: AppColors.electricBlue,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: AppColors.electricBlue,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return "الرجاء إدخال الاسم";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.electricBlue,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "حفظ ومتابعة",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
