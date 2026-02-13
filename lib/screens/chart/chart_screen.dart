import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:finalproject/core/theme/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finalproject/features/devices/domain/entities/meter_reading.dart';

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: AppColors.bgBlack),
        child: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: Hive.box<MeterReading>(
              'meter_readings',
            ).listenable(),
            builder: (context, Box<MeterReading> box, _) {
              if (box.isEmpty) {
                return _buildEmptyState();
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      "التحليلات",
                      style: GoogleFonts.cairo(
                        color: AppColors.royalGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildChartContainer(box),
                    const SizedBox(height: 40),
                    _buildStatsRow(box),
                    const SizedBox(height: 40),
                    _buildMonthlyBreakdown(box),
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
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
            Icon(Icons.analytics_outlined, size: 100, color: Colors.white24),
            const SizedBox(height: 20),
            Text(
              'لا توجد بيانات كافية',
              style: GoogleFonts.cairo(
                color: Colors.white54,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'أضف قراءات لمشاهدة التحليلات',
              style: GoogleFonts.cairo(color: Colors.white38, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContainer(Box<MeterReading> box) {
    final readings = box.values.toList()
      ..sort((a, b) => a.readingDate.compareTo(b.readingDate));

    final spots = <FlSpot>[];
    for (int i = 0; i < readings.length && i < 7; i++) {
      spots.add(FlSpot(i.toDouble(), readings[i].consumptionKwh ?? 0));
    }

    if (spots.isEmpty) {
      spots.add(const FlSpot(0, 0));
    }

    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    return FadeInUp(
      child: Container(
        height: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.deepSurface,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الاستهلاك اليومي (kWh)',
              style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.white10, strokeWidth: 1);
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= readings.length) {
                            return const SizedBox.shrink();
                          }
                          final date = readings[index].readingDate;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${date.day}/${date.month}',
                              style: GoogleFonts.cairo(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 45,
                        interval: maxY > 0 ? (maxY * 1.2) / 4 : 1,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) {
                            return Text(
                              '0',
                              style: GoogleFonts.cairo(
                                color: Colors.white54,
                                fontSize: 10,
                              ),
                            );
                          }
                          return Text(
                            '${value.toInt()}',
                            style: GoogleFonts.cairo(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY * 1.2,
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < readings.length) {
                            final reading = readings[index];
                            return LineTooltipItem(
                              '${reading.consumptionKwh?.toStringAsFixed(1)} kWh\n${reading.readingDate.day}/${reading.readingDate.month}',
                              GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.royalGold,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: AppColors.royalGold,
                            strokeWidth: 2,
                            strokeColor: AppColors.bgBlack,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.royalGold.withValues(alpha: 0.3),
                            Colors.transparent,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(Box<MeterReading> box) {
    final readings = box.values.toList();
    final totalConsumption = readings.fold<double>(
      0,
      (sum, r) => sum + (r.consumptionKwh ?? 0),
    );
    final avgDaily = readings.isEmpty
        ? 0.0
        : totalConsumption / readings.length;
    final totalCost = readings.fold<double>(
      0,
      (sum, r) => sum + (r.estimatedCost ?? 0),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatBox("المتوسط اليومي", "${avgDaily.toStringAsFixed(1)} kWh"),
        _buildStatBox("إجمالي القراءات", "${readings.length}"),
        _buildStatBox("الإجمالي", "${totalCost.toStringAsFixed(0)} جنيه"),
      ],
    );
  }

  Widget _buildStatBox(String label, String val) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.deepSurface,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(color: Colors.white54, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              val,
              style: GoogleFonts.cairo(
                color: AppColors.royalGold,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyBreakdown(Box<MeterReading> box) {
    final now = DateTime.now();
    final monthlyReadings = box.values.where((r) {
      return r.readingDate.month == now.month && r.readingDate.year == now.year;
    }).toList();

    if (monthlyReadings.isEmpty) {
      return const SizedBox.shrink();
    }

    final monthlyConsumption = monthlyReadings.fold<double>(
      0,
      (sum, r) => sum + (r.consumptionKwh ?? 0),
    );
    final monthlyCost = monthlyReadings.fold<double>(
      0,
      (sum, r) => sum + (r.estimatedCost ?? 0),
    );

    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "ملخص الشهر الحالي",
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.deepSurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildBreakdownItem(
                  "الاستهلاك الكلي",
                  "${monthlyConsumption.toStringAsFixed(1)} kWh",
                  Icons.electric_bolt,
                ),
                const SizedBox(height: 15),
                Divider(color: Colors.white10),
                const SizedBox(height: 15),
                _buildBreakdownItem(
                  "التكلفة الإجمالية",
                  "${monthlyCost.toStringAsFixed(2)} جنيه",
                  Icons.payments_outlined,
                ),
                const SizedBox(height: 15),
                Divider(color: Colors.white10),
                const SizedBox(height: 15),
                _buildBreakdownItem(
                  "عدد القراءات",
                  "${monthlyReadings.length}",
                  Icons.receipt_long_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.royalGold.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.royalGold, size: 20),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.cairo(color: Colors.white70, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            color: AppColors.royalGold,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
