import 'package:flutter/material.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'تتبع استهلاكك',
      description: 'راقب استهلاك الكهرباء بدقة عالية في الوقت الفعلي',
      imagePath: 'assets/images/onboarding_track_lux.png',
    ),
    OnboardingItem(
      title: 'وفر أموالك',
      description: 'وفر المال بذكاء مع نظام الميزانية الذكي',
      imagePath: 'assets/images/onboarding_save_lux.png',
    ),
    OnboardingItem(
      title: 'تحليلات تفصيلية',
      description: 'شاهد أنماط استهلاكك برسوم بيانية جميلة',
      imagePath: 'assets/images/onboarding_analytics.png',
    ),
  ];

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
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    // Save flag to never show onboarding again
    final box = await Hive.openBox('app_settings');
    await box.put('onboarding_completed', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.bgBlack),
        child: SafeArea(
          child: Stack(
            children: [
              // Page View
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _buildPage(_items[index], index, isSmallScreen);
                },
              ),

              // Top Logo + App Name
              Positioned(
                top: isSmallScreen ? 30 : 60,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/app_logo_elegant.png',
                          height: isSmallScreen ? 40 : 50,
                        ),
                        SizedBox(width: isSmallScreen ? 10 : 15),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Electra',
                            style: GoogleFonts.montserrat(
                              color: AppColors.electricBlue,
                              fontSize: isSmallScreen ? 20 : 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Controls
              Positioned(
                bottom: isSmallScreen ? 30 : 50,
                left: isSmallScreen ? 20 : 30,
                right: isSmallScreen ? 20 : 30,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Indicators
                      Row(
                        children: List.generate(
                          _items.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index
                                ? (isSmallScreen ? 28 : 32)
                                : (isSmallScreen ? 8 : 10),
                            height: isSmallScreen ? 8 : 10,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.electricBlue
                                  : AppColors.electricBlue.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),

                      // Next/Get Started Button
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _items.length - 1) {
                            _completeOnboarding();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricBlue,
                          foregroundColor: Colors.black,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 24 : 32,
                            vertical: isSmallScreen ? 12 : 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _currentPage == _items.length - 1
                                    ? 'ابدأ الآن'
                                    : 'التالي',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                              ),
                            ),
                            SizedBox(width: isSmallScreen ? 6 : 8),
                            Icon(
                              Icons.arrow_forward,
                              size: isSmallScreen ? 18 : 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Skip Button
              if (_currentPage < _items.length - 1)
                Positioned(
                  top: isSmallScreen ? 30 : 60,
                  left: isSmallScreen ? 20 : 30,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'تخطي',
                        style: GoogleFonts.cairo(
                          color: AppColors.electricBlue.withValues(alpha: 0.7),
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingItem item, int index, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: isSmallScreen ? 80 : 120),
          // Image
          Image.asset(
            item.imagePath,
            height: isSmallScreen ? 200 : 280,
            fit: BoxFit.contain,
          ),
          SizedBox(height: isSmallScreen ? 40 : 60),
          // Title
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              item.title,
              style: GoogleFonts.cairo(
                fontSize: isSmallScreen ? 24 : 32,
                fontWeight: FontWeight.bold,
                color: AppColors.electricBlue,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          // Description
          Text(
            item.description,
            style: GoogleFonts.cairo(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
