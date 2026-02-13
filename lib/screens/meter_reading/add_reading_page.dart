import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finalproject/features/devices/domain/entities/meter_reading.dart';
import 'package:uuid/uuid.dart';
import 'package:finalproject/services/online_first_sync_service.dart';
import 'package:finalproject/services/tariff_calculator.dart';
import 'package:finalproject/utils/reading_utils.dart';
import 'package:intl/intl.dart';

class AddReadingPage extends StatefulWidget {
  const AddReadingPage({super.key});

  @override
  State<AddReadingPage> createState() => _AddReadingPageState();
}

class _AddReadingPageState extends State<AddReadingPage> {
  final _formKey = GlobalKey<FormState>();
  final _previousReadingController = TextEditingController();
  final _currentReadingController = TextEditingController();
  final _syncService = OnlineFirstSyncService();

  DateTime _selectedDate = DateTime.now();
  double? _consumption;
  double? _estimatedCost;
  bool _isLoading = false;
  bool _isListening = false;
  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    _loadLastReading();
    _currentReadingController.addListener(_calculateConsumption);
    _previousReadingController.addListener(_calculateConsumption);
  }

  @override
  void dispose() {
    _currentReadingController.removeListener(_calculateConsumption);
    _previousReadingController.removeListener(_calculateConsumption);
    _previousReadingController.dispose();
    _currentReadingController.dispose();
    super.dispose();
  }

  Future<void> _loadLastReading() async {
    try {
      final box = await Hive.openBox<MeterReading>('meter_readings');
      if (box.isNotEmpty) {
        final readings = box.values.toList()
          ..sort((a, b) => b.readingDate.compareTo(a.readingDate));

        final lastReading = readings.first;
        if (mounted) {
          setState(() {
            _previousReadingController.text = lastReading.readingValue
                .toStringAsFixed(0);
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load last reading: $e');
    }
  }

  void _calculateConsumption() {
    final previousReading = double.tryParse(_previousReadingController.text);
    final currentReading = double.tryParse(_currentReadingController.text);

    if (previousReading == null || currentReading == null) {
      if (mounted) {
        setState(() {
          _consumption = null;
          _estimatedCost = null;
        });
      }
      return;
    }

    final consumption = currentReading - previousReading;

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
      final costData = TariffCalculator.calculateProgressiveCost(consumption);
      if (mounted) {
        setState(() {
          _consumption = consumption;
          _estimatedCost = costData['total'] as double?;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Calculation error: $e');
      if (mounted) {
        setState(() {
          _consumption = consumption;
          _estimatedCost = 0.0;
        });
      }
    }
  }

  Future<void> _showEnhancedDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.royalGold,
              onPrimary: Colors.black,
              surface: AppColors.deepSurface,
              onSurface: Colors.white,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.deepSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveReading() async {
    if (!_formKey.currentState!.validate()) return;

    if (_consumption == null || _consumption! <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'القراءة الحالية يجب أن تكون أكبر من القراءة السابقة',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final reading = MeterReading(
        id: const Uuid().v4(),
        readingDate: _selectedDate,
        readingValue: double.parse(_currentReadingController.text),
        consumptionKwh: _consumption!,
        estimatedCost: _estimatedCost ?? 0.0,
        createdAt: DateTime.now(),
      );

      final box = await Hive.openBox<MeterReading>('meter_readings');
      await box.add(reading);

      await _syncService.autoSync();

      if (!mounted) return;
      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ القراءة بنجاح ✅', style: GoogleFonts.cairo()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل حفظ القراءة: $e', style: GoogleFonts.cairo()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 360;
    final isMediumScreen = size.width >= 360 && size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.bgBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSurface,
        elevation: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'إضافة قراءة جديدة',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : 20,
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: isSmallScreen ? 22 : 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            isSmallScreen ? 16 : (isMediumScreen ? 20 : 24),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Previous Reading Card
                _buildCard(
                  isSmallScreen: isSmallScreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: AppColors.royalGold,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 12),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'القراءة السابقة',
                              style: GoogleFonts.cairo(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      TextFormField(
                        controller: _previousReadingController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'مثال: 1500',
                          hintStyle: GoogleFonts.cairo(
                            color: Colors.white24,
                            fontSize: isSmallScreen ? 13 : 15,
                          ),
                          filled: true,
                          fillColor: AppColors.bgBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.royalGold.withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.royalGold.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.royalGold,
                              width: 2,
                            ),
                          ),
                          suffixText: 'كيلووات',
                          suffixStyle: GoogleFonts.cairo(
                            color: AppColors.royalGold,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال القراءة السابقة';
                          }
                          if (double.tryParse(value) == null) {
                            return 'الرجاء إدخال رقم صحيح';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),

                // Current Reading Card with OCR & Voice
                _buildCard(
                  isSmallScreen: isSmallScreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.electric_meter,
                            color: AppColors.royalGold,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 12),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                'القراءة الحالية',
                                style: GoogleFonts.cairo(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      TextFormField(
                        controller: _currentReadingController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'مثال: 1650',
                          hintStyle: GoogleFonts.cairo(
                            color: Colors.white24,
                            fontSize: isSmallScreen ? 13 : 15,
                          ),
                          filled: true,
                          fillColor: AppColors.bgBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.royalGold.withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.royalGold.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.royalGold,
                              width: 2,
                            ),
                          ),
                          suffixText: 'كيلووات',
                          suffixStyle: GoogleFonts.cairo(
                            color: AppColors.royalGold,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال القراءة الحالية';
                          }
                          if (double.tryParse(value) == null) {
                            return 'الرجاء إدخال رقم صحيح';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      // OCR & Voice Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isProcessingImage
                                  ? null
                                  : () async {
                                      await ReadingUtils.extractNumbersFromImage(
                                        context: context,
                                        controller: _currentReadingController,
                                        onProcessingChange: (processing) {
                                          if (mounted) {
                                            setState(() {
                                              _isProcessingImage = processing;
                                            });
                                          }
                                        },
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepSurface,
                                foregroundColor: AppColors.royalGold,
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 10 : 12,
                                ),
                              ),
                              icon: _isProcessingImage
                                  ? SizedBox(
                                      width: isSmallScreen ? 16 : 20,
                                      height: isSmallScreen ? 16 : 20,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.royalGold,
                                      ),
                                    )
                                  : Icon(
                                      Icons.camera_alt,
                                      size: isSmallScreen ? 18 : 20,
                                    ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'صورة',
                                  style: GoogleFonts.cairo(
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                await ReadingUtils.listen(
                                  controller: _currentReadingController,
                                  isListening: _isListening,
                                  onStateChange: (listening) {
                                    if (mounted) {
                                      setState(() {
                                        _isListening = listening;
                                      });
                                    }
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isListening
                                    ? AppColors.royalGold
                                    : AppColors.deepSurface,
                                foregroundColor: _isListening
                                    ? Colors.black
                                    : AppColors.royalGold,
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 10 : 12,
                                ),
                              ),
                              icon: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                size: isSmallScreen ? 18 : 20,
                              ),
                              label: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _isListening ? 'استماع...' : 'صوت',
                                  style: GoogleFonts.cairo(
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),

                // Consumption & Cost Summary Card
                if (_consumption != null && _estimatedCost != null)
                  _buildCard(
                    isSmallScreen: isSmallScreen,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.analytics,
                              color: AppColors.royalGold,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            SizedBox(width: isSmallScreen ? 8 : 12),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                'ملخص الاستهلاك',
                                style: GoogleFonts.cairo(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        _buildSummaryRow(
                          'الاستهلاك',
                          '${_consumption!.toStringAsFixed(0)} كيلووات',
                          Icons.bolt,
                          isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        _buildSummaryRow(
                          'التكلفة التقديرية',
                          '${_estimatedCost!.toStringAsFixed(2)} جنيه',
                          Icons.attach_money,
                          isSmallScreen,
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        _buildSummaryRow(
                          'الشريحة',
                          TariffCalculator.determineTier(_consumption!)['name'],
                          Icons.layers,
                          isSmallScreen,
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: isSmallScreen ? 16 : 20),

                // Date Card - MOVED TO BOTTOM
                _buildCard(
                  isSmallScreen: isSmallScreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.royalGold,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          SizedBox(width: isSmallScreen ? 8 : 12),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'تاريخ القراءة',
                              style: GoogleFonts.cairo(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      InkWell(
                        onTap: _showEnhancedDatePicker,
                        child: Container(
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color: AppColors.bgBlack,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.royalGold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  DateFormat(
                                    'dd/MM/yyyy',
                                    'ar',
                                  ).format(_selectedDate),
                                  style: GoogleFonts.cairo(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.edit_calendar,
                                color: AppColors.royalGold,
                                size: isSmallScreen ? 20 : 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: isSmallScreen ? 50 : 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveReading,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.royalGold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'حفظ القراءة',
                              style: GoogleFonts.cairo(
                                fontSize: isSmallScreen ? 16 : 18,
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
    );
  }

  Widget _buildCard({required bool isSmallScreen, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
      child: child,
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    IconData icon,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.bgBlack,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.royalGold, size: isSmallScreen ? 20 : 24),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  color: Colors.white70,
                  fontSize: isSmallScreen ? 13 : 15,
                ),
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.cairo(
                color: AppColors.royalGold,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
