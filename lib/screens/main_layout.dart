import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:finalproject/screens/home/home_screen.dart';
import 'package:finalproject/screens/history/history_screen.dart';
import 'package:finalproject/screens/chart/chart_screen.dart';
import 'package:finalproject/screens/profile/profile_screen.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;
  const MainLayout({super.key, this.initialIndex = 0});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _selectedIndex;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pages = [
      const HomeScreen(),
      const ChartPage(),
      const HistoryPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(color: AppColors.bgBlack),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        decoration: BoxDecoration(
          color: AppColors.deepSurface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 20,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: GNav(
              rippleColor: AppColors.electricBlue.withValues(alpha: 0.2),
              hoverColor: AppColors.electricBlue.withValues(alpha: 0.1),
              haptic: true,
              tabBorderRadius: 20,
              curve: Curves.easeOutExpo,
              duration: const Duration(milliseconds: 400),
              gap: 8,
              color: AppColors.navUnselected,
              activeColor: AppColors.electricBlue,
              iconSize: 24,
              tabBackgroundColor: AppColors.electricBlue.withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              tabs: const [
                GButton(icon: Icons.dashboard_outlined, text: 'الرئيسية'),
                GButton(icon: Icons.bar_chart_outlined, text: 'التحليلات'),
                GButton(icon: Icons.history_outlined, text: 'السجل'),
                GButton(icon: Icons.person_outline, text: 'الحساب'),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          ),
        ),
      ),
    );
  }
}
