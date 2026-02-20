import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:hive_flutter/hive_flutter.dart';
// Updated Import to the correct Entity location
import 'package:finalproject/features/electricity_tracking/domain/entities/meter_reading.dart';
import 'package:uuid/uuid.dart';
import 'package:finalproject/services/online_first_sync_service.dart';
// Updated Import to the new accurate Calculator Service
import 'package:finalproject/services/bill_calculator_service.dart';
import 'package:finalproject/services/tariff_service.dart'; // For tier name
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
  final _installmentsController = TextEditingController();
  final _syncService = OnlineFirstSyncService();
  final _scrollController = ScrollController(); // Added ScrollController
  final _currentReadingFocusNode = FocusNode();
  final _previousReadingFocusNode = FocusNode();

  DateTime _selectedDate = DateTime.now();
  double? _consumption;
  double? _estimatedCost;
  String? _tierName;
  bool _isLoading = false;
  bool _isListening = false;
  bool _isProcessingImage = false;
  bool _showInstallments = false;

  @override
  void initState() {
    super.initState();
    _loadLastReading();
    _currentReadingController.addListener(_calculateConsumption);
    _previousReadingController.addListener(_calculateConsumption);
    _installmentsController.addListener(_calculateConsumption);
  }

  @override
  void dispose() {
    _currentReadingController.removeListener(_calculateConsumption);
    _previousReadingController.removeListener(_calculateConsumption);
    _installmentsController.removeListener(_calculateConsumption);
    _installmentsController.dispose();
    _currentReadingFocusNode.dispose();
    _previousReadingFocusNode.dispose();
    _scrollController.dispose();
    _previousReadingController.dispose();
    _currentReadingController.dispose();
    super.dispose();
  }

  Future<void> _loadLastReading() async {
    try {
      // Ensure specific type is used if already open
      final box = Hive.box<MeterReading>('meter_readings');

      if (box.isNotEmpty) {
        final readings = box.values.toList()
          ..sort((a, b) => b.readingDate.compareTo(a.readingDate));

        final lastReading = readings.first;
        if (mounted) {
          setState(() {
            _previousReadingController.text = lastReading.readingValue
                .toStringAsFixed(0);
          });
          // Focus on current reading if previous exists
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              FocusScope.of(context).requestFocus(_currentReadingFocusNode);
            }
          });
        }
      } else {
        // First time: Focus on previous reading
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            FocusScope.of(context).requestFocus(_previousReadingFocusNode);
          }
        });
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load last reading: $e');
      // If box is not open (edge case), try opening
      try {
        if (!Hive.isBoxOpen('meter_readings')) {
          await Hive.openBox<MeterReading>('meter_readings');
        }
      } catch (e2) {
        debugPrint('Critical Hive Error: $e2');
      }
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
          _tierName = null;
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
          _tierName = null;
        });
      }
      return;
    }

    try {
      final installments = double.tryParse(_installmentsController.text) ?? 0.0;

      // Use the new precise BillCalculatorService
      final billDetails = BillCalculatorService.calculateBill(
        consumption,
        installments: installments,
      );
      final tier = TariffService.getTier(consumption);

      if (mounted) {
        setState(() {
          _consumption = consumption;
          // Use 'final_payable' (rounded integer) or 'adjusted_total' (exact)
          // Showing final payable to match printed bill expectation
          _estimatedCost = (billDetails['final_payable'] as num).toDouble();
          _tierName = 'الشريحة $tier';
        });

        // Auto-scroll to bottom to show summary if consumption is valid
        if (_consumption != null && _consumption! > 0) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            }
          });
        }
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
              primary: AppColors.electricBlue,
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
      final box = Hive.box<MeterReading>('meter_readings');
      final authBox = Hive.box('auth');
      final userId =
          authBox.get('user_id') ?? authBox.get('email') ?? 'local_user';

      final reading = MeterReading(
        id: const Uuid().v4(),
        userId: userId,
        readingDate: _selectedDate,
        readingValue: double.parse(_currentReadingController.text),
        consumptionKwh: _consumption!,
        estimatedCost: _estimatedCost ?? 0.0,
        createdAt: DateTime.now(),
      );

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
          controller: _scrollController, // Attach ScrollController
          padding: EdgeInsets.all(
            isSmallScreen ? 12 : (isMediumScreen ? 16 : 20), // Reduced padding
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Disclaimer Card
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                  margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.electricBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.electricBlue,
                        size: isSmallScreen ? 20 : 24,
                      ),
                      SizedBox(width: isSmallScreen ? 10 : 12),
                      Expanded(
                        child: Text(
                          "خد بالك: الأسعار دي تقريبية، ممكن تفرق عن الوصل الحقيقي عشان في رسوم ووقت ومكان.",
                          style: GoogleFonts.cairo(
                            color: Colors.white70,
                            fontSize: isSmallScreen ? 11 : 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Date Card - Moved to top for visibility as requested
                _buildCard(
                  isSmallScreen: isSmallScreen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppColors.electricBlue,
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
                              color: AppColors.electricBlue.withValues(alpha: 0.3),
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
                                color: AppColors.electricBlue,
                                size: isSmallScreen ? 20 : 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),

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
                            color: AppColors.electricBlue,
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
                        focusNode: _previousReadingFocusNode,
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
                              color: AppColors.electricBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.electricBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.electricBlue,
                              width: 2,
                            ),
                          ),
                          suffixText: 'كيلووات',
                          suffixStyle: GoogleFonts.cairo(
                            color: AppColors.electricBlue,
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
                            color: AppColors.electricBlue,
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
                        focusNode: _currentReadingFocusNode,
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
                              color: AppColors.electricBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.electricBlue.withValues(alpha: 0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.electricBlue,
                              width: 2,
                            ),
                          ),
                          suffixText: 'كيلووات',
                          suffixStyle: GoogleFonts.cairo(
                            color: AppColors.electricBlue,
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
                                foregroundColor: AppColors.electricBlue,
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
                                        color: AppColors.electricBlue,
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
                                    ? AppColors.electricBlue
                                    : AppColors.deepSurface,
                                foregroundColor: _isListening
                                    ? Colors.black
                                    : AppColors.electricBlue,
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

                // Installments / Extra Fees Input (Collapsible)
                _buildCard(
                  isSmallScreen: isSmallScreen,
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _showInstallments = !_showInstallments;
                            if (!_showInstallments) {
                              _installmentsController.clear();
                              _calculateConsumption();
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              color: AppColors.electricBlue,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            SizedBox(width: isSmallScreen ? 8 : 12),
                            Expanded(
                              child: Text(
                                'أقساط / رسوم إضافية',
                                style: GoogleFonts.cairo(
                                  fontSize: isSmallScreen ? 15 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Switch(
                              value: _showInstallments,
                              onChanged: (val) {
                                setState(() {
                                  _showInstallments = val;
                                  if (!val) {
                                    _installmentsController.clear();
                                    _calculateConsumption();
                                  }
                                });
                              },
                              activeColor: AppColors.electricBlue,
                              activeTrackColor: AppColors.electricBlue.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_showInstallments) ...[
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        TextFormField(
                          controller: _installmentsController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: GoogleFonts.cairo(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            label: Text(
                              'قيمة الرسوم',
                              style: GoogleFonts.cairo(color: Colors.white54),
                            ),
                            hintStyle: GoogleFonts.cairo(color: Colors.white24),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.bgBlack,
                            suffixText: 'جنيه',
                            suffixStyle: GoogleFonts.cairo(
                              color: AppColors.electricBlue,
                            ),
                          ),
                        ),
                      ],
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
                              color: AppColors.electricBlue,
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
                          _tierName ?? '-',
                          Icons.layers,
                          isSmallScreen,
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: isSmallScreen ? 16 : 20),

                // Date Card - MOVED TO BOTTOM

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: isSmallScreen ? 50 : 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveReading,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricBlue,
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
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16), // Reduced padding
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
          Icon(icon, color: AppColors.electricBlue, size: isSmallScreen ? 20 : 24),
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
                color: AppColors.electricBlue,
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
