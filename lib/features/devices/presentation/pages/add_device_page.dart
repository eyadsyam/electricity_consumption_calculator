import 'package:flutter/material.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:finalproject/features/devices/data/device_database.dart';
import 'package:finalproject/features/devices/data/device_mapper.dart';
import 'package:finalproject/features/devices/domain/entities/user_device.dart';
import 'package:finalproject/services/tariff_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/device_cubit.dart';
import 'barcode_scanner_page.dart';
import 'package:animate_do/animate_do.dart';

class AddDevicePage extends StatefulWidget {
  const AddDevicePage({super.key});

  @override
  State<AddDevicePage> createState() => _AddDevicePageState();
}

class _AddDevicePageState extends State<AddDevicePage> {
  final TextEditingController _searchController = TextEditingController();

  // Use MapEntry to keep both the Arabic Name (Key) and the Data (Value)
  List<MapEntry<String, DeviceData>> _filteredSuggestions = DeviceDatabase
      .commonDevices
      .entries
      .toList();

  void _onSearch(String query) {
    setState(() {
      _filteredSuggestions = DeviceDatabase.commonDevices.entries
          .where(
            (entry) =>
                entry.key.contains(query) || // Search by Arabic Name
                entry.value.category.contains(query), // Or Category
          )
          .toList();
    });
  }

  void _addDevice(String name, DeviceData data) {
    // Show a dialog to get usage hours and quantity
    // Watts are taken from database directly
    final hoursController = TextEditingController(text: '1');
    final quantityController = TextEditingController(text: '1');
    double currentHours = 1.0;
    int currentQuantity = 1;

    // Helper to calculate costs
    Map<String, String> calculateEstimates(double hours, int quantity) {
      if (hours <= 0 || quantity <= 0) return {'kwh': '0', 'cost': '0'};

      final dailyKwh = (data.avgWatts * hours * quantity) / 1000;
      final monthlyKwh = dailyKwh * 30;

      // Calculate estimated monthly cost for this device alone
      final estimatedCost = TariffService.calculateCost(monthlyKwh);

      return {
        'dailyKwh': dailyKwh.toStringAsFixed(2),
        'monthlyKwh': monthlyKwh.toStringAsFixed(1),
        'cost': estimatedCost.toStringAsFixed(1),
      };
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final estimates = calculateEstimates(currentHours, currentQuantity);

          return AlertDialog(
            backgroundColor: AppColors.deepSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(_getIcon(data.icon), color: AppColors.royalGold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "إضافة $name",
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgBlack,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "متوسط القدرة:",
                          style: GoogleFonts.cairo(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "${data.avgWatts.toInt()} وات",
                          style: GoogleFonts.outfit(
                            color: AppColors.royalGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quantity Input
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.cairo(color: Colors.white),
                    onChanged: (val) {
                      setState(() {
                        currentQuantity = int.tryParse(val) ?? 1;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "العدد",
                      labelStyle: GoogleFonts.cairo(color: Colors.white54),
                      filled: true,
                      fillColor: AppColors.bgBlack,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.format_list_numbered,
                        color: AppColors.royalGold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Hours Input
                  TextField(
                    controller: hoursController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: GoogleFonts.cairo(color: Colors.white),
                    onChanged: (val) {
                      setState(() {
                        currentHours = double.tryParse(val) ?? 0;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "ساعات التشغيل اليومية",
                      labelStyle: GoogleFonts.cairo(color: Colors.white54),
                      suffixText: "ساعة",
                      filled: true,
                      fillColor: AppColors.bgBlack,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.access_time,
                        color: AppColors.royalGold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Live Estimates
                  if (currentHours > 0) ...[
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 10),
                    _buildEstimateRow(
                      "الاستهلاك اليومي:",
                      "${estimates['dailyKwh']} كيلووات",
                    ),
                    const SizedBox(height: 8),
                    _buildEstimateRow(
                      "الاستهلاك الشهري:",
                      "${estimates['monthlyKwh']} كيلووات",
                    ),
                    const SizedBox(height: 8),
                    _buildEstimateRow(
                      "التكلفة الشهرية المتوقعة:",
                      "${estimates['cost']} جنيه",
                      isHighlight: true,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  "إلغاء",
                  style: GoogleFonts.cairo(color: Colors.white54),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final hours = double.tryParse(hoursController.text) ?? 0;
                  final quantity = int.tryParse(quantityController.text) ?? 1;

                  if (hours <= 0 || quantity <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "يرجى إدخال بيانات صحيحة",
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  final device = UserDevice(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    deviceName: name,
                    category: data.category,
                    powerWatts: data.avgWatts, // Using database value directly
                    iconName: data.icon,
                    usageHoursPerDay: hours,
                    quantity: quantity,
                    createdAt: DateTime.now(),
                  );

                  context.read<DeviceCubit>().addDevice(device);
                  Navigator.pop(ctx);

                  // Show success with details
                  final est = calculateEstimates(hours, quantity);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "تمت الإضافة بنجاح\nتكلفة شهرية متوقعة: ${est['cost']} جنيه",
                          style: GoogleFonts.cairo(),
                          textAlign: TextAlign.right,
                        ),
                        backgroundColor: AppColors.royalGold,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.royalGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "حفظ وإضافة",
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEstimateRow(
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: isHighlight ? AppColors.royalGold : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isHighlight ? 16 : 14,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "إضافة جهاز جديد",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.bgBlack,
        iconTheme: const IconThemeData(color: AppColors.royalGold),
      ),
      body: Container(
        decoration: const BoxDecoration(color: AppColors.bgBlack),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSearchAndScan(),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _filteredSuggestions.length,
                itemBuilder: (context, index) {
                  final item = _filteredSuggestions[index];
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 50),
                    child: _buildSuggestionTile(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndScan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              style: GoogleFonts.cairo(color: Colors.white),
              decoration: InputDecoration(
                hintText: "بحث عن جهاز...",
                hintStyle: GoogleFonts.cairo(color: Colors.white38),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.royalGold,
                ),
                filled: true,
                fillColor: AppColors.deepSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: () async {
              // Note: Ensure BarcodeScannerPage is also localized if needed
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
              );
              if (result != null && result['name'] != null) {
                // Here we might receive English name from barcode, we can try to map it or just use it
                final englishName = result['name'];
                final mapped = DeviceMapper.mapProductToDevice(englishName);
                // Try to translate the name for the user
                final arabicName = _translateCategory(englishName);
                _addDevice(arabicName, mapped);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.royalGold,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.qr_code_scanner, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionTile(MapEntry<String, DeviceData> entry) {
    final name = entry.key;
    final data = entry.value;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.deepSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.royalGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(_getIcon(data.icon), color: AppColors.royalGold),
        ),
        title: Text(
          name,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "متوسط الاستهلاك: ${data.avgWatts.toInt()} وات",
          style: GoogleFonts.cairo(color: Colors.white38, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_circle, color: AppColors.royalGold),
          onPressed: () => _addDevice(name, data),
        ),
      ),
    );
  }

  String _translateCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('tv') || lower.contains('television')) return 'تلفزيون';
    if (lower.contains('fridge') || lower.contains('refrigerator'))
      return 'ثلاجة';
    if (lower.contains('ac') || lower.contains('air conditioner'))
      return 'تكييف';
    if (lower.contains('microwave')) return 'ميكروويف';
    if (lower.contains('oven')) return 'فرن كهربائي';
    if (lower.contains('washing') || lower.contains('washer')) return 'غسالة';
    if (lower.contains('dishwasher')) return 'غسالة أطباق';
    if (lower.contains('iron')) return 'مكواة';
    if (lower.contains('kettle')) return 'كاتل (غلاية)';
    if (lower.contains('heater')) return 'سخان';
    if (lower.contains('fan')) return 'مروحة';
    if (lower.contains('pc') ||
        lower.contains('laptop') ||
        lower.contains('computer'))
      return 'كمبيوتر / لابتوب';
    if (lower.contains('light') || lower.contains('lamp'))
      return 'إضاءة / لمبة';
    if (lower.contains('router')) return 'راوتر';
    if (lower.contains('pump')) return 'موتور مياه';

    return category; // Fallback to English if not found
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
