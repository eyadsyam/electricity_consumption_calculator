import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finalproject/core/core.dart';
import 'package:finalproject/screens/home/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Logo
                      PulseAnimation(
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.electric_bolt,
                            size: 100,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // App Title
                      Text(
                        'WELCOME_TITLE'.tr,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        'WELCOME_SUBTITLE'.tr,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Features List
                      _buildFeature(
                        Icons.analytics_outlined,
                        'FEATURE_TRACK'.tr,
                        0,
                      ),
                      const SizedBox(height: 16),
                      _buildFeature(
                        Icons.savings_outlined,
                        'FEATURE_SAVE'.tr,
                        1,
                      ),
                      const SizedBox(height: 16),
                      _buildFeature(
                        Icons.insights_outlined,
                        'FEATURE_INSIGHTS'.tr,
                        2,
                      ),
                      const SizedBox(height: 60),

                      // Login Button
                      ScaleAnimationController.scaleWithFade(
                        duration: const Duration(milliseconds: 600),
                        child: AnimatedButton(
                          text: 'LOGIN'.tr,
                          icon: Icons.login,
                          width: double.infinity,
                          backgroundColor: Colors.white,
                          textColor: AppColors.primary,
                          onPressed: () {
                            Get.snackbar(
                              'INFO'.tr,
                              'LOGIN_COMING_SOON'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.white,
                              colorText: AppColors.primary,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                              duration: const Duration(seconds: 2),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Guest Button
                      ScaleAnimationController.scaleWithFade(
                        duration: const Duration(milliseconds: 700),
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  AppPageTransitions.createRoute(
                                    page: const HomeScreen(),
                                    transitionsBuilder:
                                        AppPageTransitions.slideAndFade,
                                  ),
                                );
                              },
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'CONTINUE_GUEST'.tr,
                                      style: theme.textTheme.titleMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ],
                                ),
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
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text, int index) {
    return StaggeredListAnimation.createStaggeredItem(
      index: index,
      delay: const Duration(milliseconds: 200),
      child: GlassMorphismContainer(
        blur: 10,
        opacity: 0.15,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
