import 'package:flutter/material.dart';
import 'package:finalproject/core/theme/app_theme.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'package:finalproject/screens/main_layout.dart';
import 'sign_up_page.dart';
import 'package:hive/hive.dart';
import 'package:finalproject/services/google_auth_service.dart';
import 'complete_profile_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isMediumScreen = size.width >= 360 && size.width < 600;

    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Check if name is Arabic-like, if not -> CompleteProfile
            final name = state.user.name ?? "";
            final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(name);

            if (!isArabic) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CompleteProfilePage(
                    initialName: name,
                    photoUrl: state.user.photo,
                  ),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const MainLayout(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  transitionDuration: const Duration(milliseconds: 600),
                ),
              );
            }
          }
        },
        child: Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: AppTheme.luxuryDarkGradient,
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 20 : (isMediumScreen ? 30 : 40),
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    SizedBox(height: isSmallScreen ? 40 : 80),
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, -0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _fadeController,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/app_logo_elegant.png',
                            height: isSmallScreen ? 60 : 80,
                          ),
                          SizedBox(width: isSmallScreen ? 10 : 15),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Electra',
                              style: GoogleFonts.montserrat(
                                color: AppColors.royalGold,
                                fontSize: isSmallScreen ? 24 : 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 20 : 30),
                    SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _fadeController,
                              curve: Curves.easeOut,
                            ),
                          ),
                      child: Column(
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "مرحباً بك",
                              style: GoogleFonts.cairo(
                                fontSize: isSmallScreen ? 26 : 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.royalGold,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "سجل دخولك للمتابعة",
                              style: GoogleFonts.cairo(
                                color: Colors.white54,
                                fontSize: isSmallScreen ? 13 : 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 30 : 40),
                    _buildTextField(
                      controller: _emailController,
                      label: "البريد الإلكتروني",
                      icon: Icons.email_outlined,
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    _buildTextField(
                      controller: _passwordController,
                      label: "كلمة المرور",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 25 : 30),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: isSmallScreen ? 50 : 55,
                              child: ElevatedButton(
                                onPressed: state is AuthLoading
                                    ? null
                                    : () => context.read<AuthCubit>().signIn(
                                        _emailController.text,
                                        _passwordController.text,
                                      ),
                                child: state is AuthLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.black,
                                      )
                                    : FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          "تسجيل الدخول",
                                          style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isSmallScreen ? 14 : 16,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 15),
                            SizedBox(
                              width: double.infinity,
                              height: isSmallScreen ? 50 : 55,
                              child: OutlinedButton(
                                onPressed: () => _showGuestDialog(),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppColors.royalGold.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "الدخول كزائر",
                                    style: GoogleFonts.cairo(
                                      color: AppColors.royalGold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isSmallScreen ? 14 : 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    TextButton(
                      onPressed: () {},
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "نسيت كلمة المرور؟",
                          style: GoogleFonts.cairo(
                            color: AppColors.royalGold.withValues(alpha: 0.7),
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 10),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: Colors.white24,
                            thickness: 1,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "أو",
                            style: GoogleFonts.cairo(
                              color: Colors.white54,
                              fontSize: isSmallScreen ? 11 : 12,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            color: Colors.white24,
                            thickness: 1,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    // Google Sign-In Button with Asset Logo
                    SizedBox(
                      width: double.infinity,
                      height: isSmallScreen ? 50 : 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          final googleAuth = GoogleAuthService();
                          final userData = await googleAuth.signInWithGoogle();

                          if (!mounted) return;

                          if (userData != null) {
                            context.read<AuthCubit>().signInWithGoogle(
                              userData,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'فشل تسجيل الدخول بواسطة Google',
                                  style: GoogleFonts.cairo(),
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1F1F1F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Google Logo from Assets
                            Image.asset(
                              'assets/images/Logo-google-icon-PNG.png',
                              width: isSmallScreen ? 18 : 20,
                              height: isSmallScreen ? 18 : 20,
                            ),
                            SizedBox(width: isSmallScreen ? 10 : 12),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "الدخول بواسطة جوجل",
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w500,
                                    fontSize: isSmallScreen ? 13 : 14,
                                    color: const Color(0xFF1F1F1F),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    SizedBox(
                      width: double.infinity,
                      height: isSmallScreen ? 50 : 55,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const SignUpPage(),
                              transitionsBuilder:
                                  (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(1, 0),
                                          end: Offset.zero,
                                        ).animate(animation),
                                        child: child,
                                      ),
                                    );
                                  },
                              transitionDuration: const Duration(
                                milliseconds: 400,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.royalGold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: Icon(
                          Icons.person_add,
                          color: AppColors.royalGold,
                          size: isSmallScreen ? 20 : 24,
                        ),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            "إنشاء حساب جديد",
                            style: GoogleFonts.cairo(
                              color: AppColors.royalGold,
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 30 : 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.deepSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.royalGold.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: isSmallScreen ? 13 : 15,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(
            color: Colors.white24,
            fontSize: isSmallScreen ? 12 : 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.royalGold,
            size: isSmallScreen ? 20 : 24,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.royalGold.withValues(alpha: 0.7),
                    size: isSmallScreen ? 20 : 24,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 15 : 20,
            vertical: isSmallScreen ? 12 : 15,
          ),
        ),
      ),
    );
  }

  Future<void> _showGuestDialog() async {
    if (!mounted) return;

    final nameController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'الدخول كضيف',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'أدخل اسمك للمتابعة',
              style: GoogleFonts.cairo(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'الاسم',
                hintStyle: GoogleFonts.cairo(color: Colors.white38),
                filled: true,
                fillColor: AppColors.bgBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.person,
                  color: AppColors.royalGold,
                ),
              ),
            ),
          ],
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalGold,
              foregroundColor: Colors.black,
            ),
            child: Text('متابعة', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final name = nameController.text.trim().isEmpty
          ? 'ضيف'
          : nameController.text.trim();

      final authBox = await Hive.openBox('auth');
      await authBox.put('user_name', name);
      await authBox.put('is_guest', true);
      await authBox.put('is_authenticated', true);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainLayout(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }
}
