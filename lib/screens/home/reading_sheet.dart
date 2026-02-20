import 'package:finalproject/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finalproject/services/bill_calculator_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/features/electricity_tracking/domain/entities/meter_reading.dart';
import 'package:uuid/uuid.dart';

class AddReadingSheet extends StatefulWidget {
  final String month;
  const AddReadingSheet({super.key, required this.month});

  @override
  State<AddReadingSheet> createState() => _AddReadingSheetState();
}

class _AddReadingSheetState extends State<AddReadingSheet> {
  final TextEditingController _currentController = TextEditingController();
  double? _previousReading;
  double? _consumption;
  double? _estimatedCost;

  @override
  void initState() {
    super.initState();
    _loadLastReading();
    _currentController.addListener(_calculateConsumption);
  }

  @override
  void dispose() {
    _currentController.removeListener(_calculateConsumption);
    _currentController.dispose();
    super.dispose();
  }

  Future<void> _loadLastReading() async {
    try {
      final box = await Hive.openBox<MeterReading>('meter_readings');
      if (box.isNotEmpty) {
        final readings = box.values.toList()
          ..sort((a, b) => b.readingDate.compareTo(a.readingDate));
        if (mounted) {
          setState(() {
            _previousReading = readings.first.readingValue;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading last reading: $e');
    }
  }

  void _calculateConsumption() {
    final currentReading = double.tryParse(_currentController.text);

    if (currentReading == null || _previousReading == null) {
      if (mounted) {
        setState(() {
          _consumption = null;
          _estimatedCost = null;
        });
      }
      return;
    }

    final consumption = currentReading - _previousReading!;

    if (consumption < 0) {
      if (mounted) {
        setState(() {
          _consumption = null;
          _estimatedCost = null;
        });
      }
      return;
    }

    try {
      final costData = BillCalculatorService.calculateBill(consumption);
      if (mounted) {
        setState(() {
          _consumption = consumption;
          _estimatedCost = costData['final_payable'] as double;
        });
      }
    } catch (e) {
      debugPrint('Calculation error: $e');
    }
  }

  Future<void> _saveReading() async {
    final currentReading = double.tryParse(_currentController.text);

    if (currentReading == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء إدخال قراءة صحيحة', style: GoogleFonts.cairo()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_consumption == null || _consumption! <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'القراءة الحالية يجب أن تكون أكبر من السابقة',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final authBox = Hive.box('auth');
      final userId = authBox.get('email') ?? 'local_user';

      final reading = MeterReading(
        id: const Uuid().v4(),
        userId: userId,
        readingDate: DateTime.now(),
        readingValue: currentReading,
        consumptionKwh: _consumption!,
        estimatedCost: _estimatedCost ?? 0.0,
        createdAt: DateTime.now(),
      );

      final box = Hive.box<MeterReading>('meter_readings');
      await box.add(reading);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم الحفظ - التكلفة: ${_estimatedCost?.toStringAsFixed(2)} جنيه',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.electricBlue,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل الحفظ', style: GoogleFonts.cairo()),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.deepSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "تسجيل قراءة جديدة",
              style: GoogleFonts.cairo(
                color: AppColors.electricBlue,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            if (_previousReading != null) ...[
              const SizedBox(height: 10),
              Text(
                "القراءة السابقة: ${_previousReading!.toStringAsFixed(0)} كيلووات",
                style: GoogleFonts.cairo(color: Colors.white54, fontSize: 14),
              ),
            ],
            const SizedBox(height: 30),
            TextField(
              controller: _currentController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "القراءة الحالية",
                hintStyle: const TextStyle(color: Colors.white12),
                suffixText: "كيلووات",
                suffixStyle: const TextStyle(color: AppColors.electricBlue),
              ),
            ),
            if (_consumption != null && _estimatedCost != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgBlack,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.electricBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الاستهلاك:',
                          style: GoogleFonts.cairo(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_consumption!.toStringAsFixed(0)} كيلووات',
                          style: GoogleFonts.cairo(
                            color: AppColors.electricBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'التكلفة التقديرية:',
                          style: GoogleFonts.cairo(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_estimatedCost!.toStringAsFixed(2)} جنيه',
                          style: GoogleFonts.cairo(
                            color: AppColors.electricBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _saveReading,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                  foregroundColor: Colors.black,
                ),
                child: Text(
                  "حفظ القراءة",
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
