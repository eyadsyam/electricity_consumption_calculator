import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:finalproject/core/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finalproject/features/devices/domain/entities/user_device.dart';
import 'package:finalproject/features/electricity_tracking/domain/entities/meter_reading.dart';
import 'package:finalproject/services/bill_calculator_service.dart';
import 'package:finalproject/services/tariff_service.dart';

import 'package:finalproject/features/devices/presentation/pages/device_inventory_page.dart';
import 'package:finalproject/screens/meter_reading/add_reading_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = 'User';
  double currentMonthCost = 0.0;
  double currentMonthKwh = 0.0;
  String currentTier = 'لا يوجد';
  int readingsCount = 0;
  double? monthlyBudget; // Budget feature

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    // Ensure boxes are open (should be from main.dart)
    final authBox = Hive.box('auth');
    final readingsBox = Hive.box<MeterReading>('meter_readings');
    // Use 'app_settings' consistent with main.dart
    final settingsBox = Hive.box('app_settings');

    setState(() {
      userName = authBox.get('user_name', defaultValue: 'User');
      readingsCount = readingsBox.length;
      monthlyBudget = settingsBox.get('monthly_budget');

      if (readingsBox.isNotEmpty) {
        final now = DateTime.now();
        final thisMonthReadings = readingsBox.values.where((r) {
          return r.readingDate.month == now.month &&
              r.readingDate.year == now.year;
        }).toList();

        if (thisMonthReadings.isNotEmpty) {
          // Calculate total consumption for the month
          currentMonthKwh = thisMonthReadings.fold(
            0.0,
            (sum, item) => sum + (item.consumptionKwh ?? 0.0),
          );

          // Use accurate service
          final billDetails = BillCalculatorService.calculateBill(
            currentMonthKwh,
          );
          currentMonthCost = (billDetails['final_payable'] as num).toDouble();

          final tier = TariffService.getTier(currentMonthKwh);
          currentTier = 'الشريحة $tier';
        }
      }
    });
  }

  bool get _isOverBudget {
    if (monthlyBudget == null || readingsCount == 0) return false;
    return currentMonthCost > monthlyBudget!;
  }

  Future<void> _showBudgetDialog() async {
    final controller = TextEditingController(
      text: monthlyBudget?.toStringAsFixed(0) ?? '',
    );

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.deepSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: AppColors.royalGold),
            SizedBox(width: 10),
            Text(
              'تحديد الميزانية الشهرية',
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
            SizedBox(height: 20),
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
                suffixStyle: GoogleFonts.cairo(color: AppColors.royalGold),
                prefixIcon: Icon(Icons.money, color: AppColors.royalGold),
              ),
            ),
          ],
        ),
        actions: [
          if (monthlyBudget != null)
            TextButton(
              onPressed: () async {
                final box = Hive.box('app_settings');
                await box.delete('monthly_budget');
                setState(() => monthlyBudget = null);
                Navigator.pop(ctx);
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
                final box = Hive.box('app_settings');
                await box.put('monthly_budget', value);
                setState(() => monthlyBudget = value);
                Navigator.pop(ctx);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم تحديد الميزانية: ${value.toStringAsFixed(0)} جنيه',
                      style: GoogleFonts.cairo(),
                    ),
                    backgroundColor: AppColors.royalGold,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.royalGold,
              foregroundColor: Colors.black,
            ),
            child: Text('حفظ', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.bgBlack),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMonthlyCard(),
                    // Disclaimer removed as requested
                    const SizedBox(height: 20),
                    _buildAddReadingButton(context),
                    const SizedBox(height: 30),
                    if (readingsCount > 0) ...[
                      _buildSectionTitle('الشريحة الحالية'),
                      const SizedBox(height: 15),
                      _buildTierStatus(),
                      const SizedBox(height: 30),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSectionTitle('أجهزتي'),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DeviceInventoryPage(),
                            ),
                          ),
                          child: const Text(
                            "عرض الكل",
                            style: TextStyle(color: AppColors.royalGold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _buildDevicesList(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.bgBlack,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 20, bottom: 12),
        expandedTitleScale: 1.0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, // Start is Right in RTL
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/app_logo_elegant.png',
                  width: 45, // Increased size
                  height: 45,
                ),
                const SizedBox(width: 10),
                Text(
                  "Electra",
                  style: GoogleFonts.outfit(
                    color: AppColors.royalGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 22, // Slightly larger text
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 4,
              ), // Align text slightly
              child: Text(
                "مرحباً, $userName",
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      actions: [
        /*
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.royalGold,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationPage()),
          ),
        ),
        */
      ],
    );
  }

  Widget _buildMonthlyCard() {
    return FadeInUp(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: _isOverBudget
              ? LinearGradient(
                  colors: [Colors.red.shade900, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : readingsCount == 0
              ? LinearGradient(
                  colors: [Colors.grey.shade800, Colors.grey.shade700],
                )
              : AppTheme.luxuryGoldGradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _isOverBudget
                  ? Colors.red.withValues(alpha: 0.4)
                  : readingsCount == 0
                  ? Colors.black26
                  : AppColors.royalGold.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with budget icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FittedBox(
                  child: Text(
                    "الاستهلاك شهري", // Shortened slightly or rely on FittedBox
                    style: GoogleFonts.cairo(
                      color: _isOverBudget ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                InkWell(
                  onTap: _showBudgetDialog,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isOverBudget
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: _isOverBudget ? Colors.white : Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),

            // Warning if over budget
            if (_isOverBudget) ...[
              SizedBox(height: 15),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'تجاوزت الميزانية المحددة!',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            if (readingsCount == 0) ...[
              Icon(
                Icons.electric_meter_outlined,
                size: 50,
                color: Colors.white54,
              ),
              const SizedBox(height: 10),
              Text(
                "لم تقم بإدخال أي قراءة",
                style: GoogleFonts.cairo(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                "اضغط على الزر أدناه لإضافة أول قراءة",
                style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
              ),
            ] else ...[
              Text(
                "${currentMonthCost.toStringAsFixed(2)} جنيه",
                style: GoogleFonts.cairo(
                  color: _isOverBudget ? Colors.white : AppColors.luxuryBlack,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _isOverBudget
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${currentMonthKwh.toStringAsFixed(1)} وات",
                  style: GoogleFonts.cairo(
                    color: _isOverBudget ? Colors.white : Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Budget info
              if (monthlyBudget != null) ...[
                SizedBox(height: 10),
                Text(
                  'الميزانية: ${monthlyBudget!.toStringAsFixed(0)} جنيه',
                  style: GoogleFonts.cairo(
                    color: _isOverBudget ? Colors.white70 : Colors.black54,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddReadingButton(BuildContext context) {
    return FadeInUp(
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton.icon(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddReadingPage()),
            );
            _loadUserData();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.royalGold,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
          ),
          icon: const Icon(Icons.add_circle_outline, size: 28),
          label: Text(
            "إضافة قراءة جديدة",
            style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return FadeInLeft(
      child: Text(
        title,
        style: GoogleFonts.cairo(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTierStatus() {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.deepSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.royalGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.trending_up,
                color: AppColors.royalGold,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentTier,
                    style: GoogleFonts.cairo(
                      color: AppColors.royalGold,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${currentMonthKwh.toStringAsFixed(1)} كيلووات/ساعة",
                    style: GoogleFonts.cairo(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevicesList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<UserDevice>('user_devices').listenable(),
      builder: (context, Box<UserDevice> box, _) {
        if (box.isEmpty) {
          return _buildEmptyDevices();
        }

        final devices = box.values.take(3).toList();

        return Column(
          children: devices.map((device) => _buildDeviceCard(device)).toList(),
        );
      },
    );
  }

  Widget _buildEmptyDevices() {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: AppColors.deepSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(Icons.devices_other, size: 50, color: Colors.white24),
            const SizedBox(height: 15),
            Text(
              "لا توجد أجهزة مسجلة",
              style: GoogleFonts.cairo(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(UserDevice device) {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.deepSurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.royalGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIcon(device.iconName),
                color: AppColors.royalGold,
                size: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.deviceName,
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "العدد: ${device.quantity} | الاستهلاك: ${(device.monthlyConsumptionKwh).toStringAsFixed(1)} كيلووات/شهر",
                    style: GoogleFonts.cairo(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "التكلفة المتوقعة: ${TariffService.calculateCost(device.monthlyConsumptionKwh).toStringAsFixed(1)} جنيه",
                    style: GoogleFonts.cairo(
                      color: AppColors.royalGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'tv':
        return Icons.tv;
      case 'kitchen':
        return Icons.kitchen;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'microwave':
        return Icons.microwave;
      case 'laptop':
        return Icons.laptop;
      case 'wind_power':
        return Icons.wind_power;
      case 'local_laundry_service':
      case 'wash':
        return Icons.local_laundry_service;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'iron':
        return Icons.iron;
      case 'water_drop':
        return Icons.water_drop;
      default:
        return Icons.electrical_services;
    }
  }
}
