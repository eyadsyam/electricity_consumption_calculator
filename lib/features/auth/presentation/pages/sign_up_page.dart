import 'package:flutter/material.dart';
import 'package:finalproject/core/theme/app_theme.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'package:finalproject/screens/main_layout.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message, style: GoogleFonts.cairo()),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
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
                                color: AppColors.electricBlue,
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
                              "إنشاء حساب جديد",
                              style: GoogleFonts.cairo(
                                fontSize: isSmallScreen ? 26 : 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.electricBlue,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              "أنشئ حسابك للبدء",
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
                      controller: _nameController,
                      label: "الاسم",
                      icon: Icons.person_outline,
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 15 : 20),
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
                      isPasswordField: true,
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: "تأكيد كلمة المرور",
                      icon: Icons.lock_reset,
                      isPassword: true,
                      isConfirmPassword: true,
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 30 : 40),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: double.infinity,
                          height: isSmallScreen ? 50 : 55,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    if (_passwordController.text !=
                                        _confirmPasswordController.text) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "كلمات المرور غير متطابقة",
                                            style: GoogleFonts.cairo(),
                                          ),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                      return;
                                    }
                                    context.read<AuthCubit>().signUp(
                                      _emailController.text,
                                      _passwordController.text,
                                      _nameController.text.isEmpty
                                          ? 'مستخدم'
                                          : _nameController.text,
                                    );
                                  },
                            child: state is AuthLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.black,
                                  )
                                : FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      "إنشاء الحساب",
                                      style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: isSmallScreen ? 15 : 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          text: "لديك حساب بالفعل؟ ",
                          style: GoogleFonts.cairo(
                            color: Colors.white54,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                          children: [
                            TextSpan(
                              text: "تسجيل الدخول",
                              style: GoogleFonts.cairo(
                                color: AppColors.electricBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 13 : 14,
                              ),
                            ),
                          ],
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
    bool isPasswordField = false,
    bool isConfirmPassword = false,
    required bool isSmallScreen,
  }) {
    final bool obscureText =
        isPassword &&
        (isPasswordField
            ? !_isPasswordVisible
            : isConfirmPassword
            ? !_isConfirmPasswordVisible
            : true);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.deepSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricBlue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
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
            color: AppColors.electricBlue,
            size: isSmallScreen ? 20 : 24,
          ),
          suffixIcon: (isPasswordField || isConfirmPassword)
              ? IconButton(
                  icon: Icon(
                    (isPasswordField
                            ? _isPasswordVisible
                            : _isConfirmPasswordVisible)
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.electricBlue.withValues(alpha: 0.7),
                    size: isSmallScreen ? 20 : 24,
                  ),
                  onPressed: () {
                    setState(() {
                      if (isPasswordField) {
                        _isPasswordVisible = !_isPasswordVisible;
                      } else {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      }
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
}
