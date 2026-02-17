import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finalproject/features/electricity_tracking/domain/entities/meter_reading.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:finalproject/core/di/injection.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  String _getTierName(double kwh) {
    if (kwh <= 50) return 'الشريحة 1';
    if (kwh <= 100) return 'الشريحة 2';
    if (kwh <= 200) return 'الشريحة 3';
    if (kwh <= 350) return 'الشريحة 4';
    if (kwh <= 650) return 'الشريحة 5';
    if (kwh <= 1000) return 'الشريحة 6';
    return 'الشريحة 7';
  }

  String _formatDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour;
    final period = date.hour >= 12 ? 'م' : 'ص';
    return '${hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.bgBlack),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      "سجل القراءات",
                      style: GoogleFonts.cairo(
                        color: AppColors.royalGold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<MeterReading>(
                    'meter_readings',
                  ).listenable(),
                  builder: (context, Box<MeterReading> box, _) {
                    if (box.isEmpty) {
                      return _buildEmptyState();
                    }

                    final readings = box.values.toList();
                    final indices = List.generate(readings.length, (i) => i);

                    // Sort indices by date
                    indices.sort(
                      (a, b) => readings[b].readingDate.compareTo(
                        readings[a].readingDate,
                      ),
                    );

                    return ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: indices.length,
                      itemBuilder: (context, i) {
                        final index = indices[i];
                        return FadeInUp(
                          delay: Duration(milliseconds: i * 100),
                          child: _buildHistoryCard(
                            context,
                            readings[index],
                            index,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeInUp(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_outlined, size: 100, color: Colors.white24),
            const SizedBox(height: 20),
            Text(
              'لا توجد قراءات بعد',
              style: GoogleFonts.cairo(
                color: Colors.white54,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'ابدأ بإضافة أول قراءة من الصفحة الرئيسية',
              style: GoogleFonts.cairo(color: Colors.white38, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    MeterReading reading,
    int index,
  ) {
    return Dismissible(
      key: Key(reading.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: Icon(Icons.delete_outline, color: Colors.white, size: 30),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.deepSurface,
            title: Text(
              'حذف القراءة',
              style: GoogleFonts.cairo(color: Colors.white),
            ),
            content: Text(
              'هل أنت متأكد من حذف هذه القراءة؟',
              style: GoogleFonts.cairo(color: Colors.white70),
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
                  backgroundColor: AppColors.error,
                ),
                child: Text('حذف', style: GoogleFonts.cairo()),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        // 1. Capture ID before local deletion
        final readingId = reading.id;

        // 2. Delete from Supabase (Cloud)
        try {
          final supabaseClient = sl<SupabaseClient>();
          await supabaseClient
              .from('meter_readings')
              .delete()
              .eq('id', readingId);
          debugPrint('Deleted reading $readingId from Supabase');
        } catch (e) {
          debugPrint('Failed to delete from Supabase: $e');
        }

        // 3. Delete from Hive (Local)
        // Use delete() on the HiveObject directly if possible, or deleteAt via box
        if (reading.isInBox) {
          await reading.delete();
        } else {
          // Fallback if not in box (unlikely with ValueListenable)
          final box = await Hive.openBox<MeterReading>('meter_readings');
          await box.deleteAt(index);
        }

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف القراءة بنجاح', style: GoogleFonts.cairo()),
            backgroundColor: AppColors.royalGold,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.deepSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.royalGold.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.royalGold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.electric_meter, color: AppColors.royalGold),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatDate(reading.readingDate),
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatTime(reading.readingDate),
                        style: GoogleFonts.cairo(
                          color: Colors.white38,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${reading.estimatedCost?.toStringAsFixed(2) ?? '0.00'} جنيه",
                      style: GoogleFonts.cairo(
                        color: AppColors.royalGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      _getTierName(reading.consumptionKwh ?? 0),
                      style: GoogleFonts.cairo(
                        color: Colors.white24,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            Divider(color: Colors.white10),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  'القراءة',
                  '${reading.readingValue.toStringAsFixed(1)} kWh',
                ),
                Container(width: 1, height: 30, color: Colors.white10),
                _buildInfoItem(
                  'الاستهلاك',
                  '${reading.consumptionKwh?.toStringAsFixed(1) ?? '0.0'} kWh',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
