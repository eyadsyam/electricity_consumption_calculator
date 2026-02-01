import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  late Box box;

  @override
  void initState() {
    super.initState();
    box = Hive.box('historyBox');
  }

  // Helper: Convert Arabic/English month name + year → DateTime for sorting
  DateTime _parseMonthKey(String monthKey) {
    try {
      // Example keys: "يناير 2025", "February 2025", "ديسمبر 2024"
      final parts = monthKey.trim().split(' ');
      if (parts.length != 2) return DateTime.now();

      final year = int.tryParse(parts.last) ?? DateTime.now().year;

      // Map Arabic month names to numbers
      const arabicMonths = {
        'يناير': 1,
        'فبراير': 2,
        'مارس': 3,
        'أبريل': 4,
        'مايو': 5,
        'يونيو': 6,
        'يوليو': 7,
        'أغسطس': 8,
        'سبتمبر': 9,
        'أكتوبر': 10,
        'نوفمبر': 11,
        'ديسمبر': 12,
      };

      int month;
      if (arabicMonths.containsKey(parts.first)) {
        month = arabicMonths[parts.first]!;
      } else {
        // English fallback
        month = DateFormat.MMMM().parse(parts.first).month;
      }

      return DateTime(year, month);
    } catch (e) {
      return DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get all month keys (exclude budget_)
    final allKeys = box.keys
        .where((k) => k is String && !k.toString().startsWith('budget_'))
        .toList();

    if (allKeys.isEmpty) {
      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.show_chart, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'CHART_NO_DATA'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'CHART_NO_DATA_SUB'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Parse and sort months chronologically
    final sortedMonths = allKeys.map((key) {
      final date = _parseMonthKey(key.toString());
      return MapEntry(key.toString(), date);
    }).toList()..sort((a, b) => a.value.compareTo(b.value));

    // Build data points: x = index (0,1,2...), y = total bill of that month
    final List<FlSpot> spots = [];
    final List<String> monthLabels = [];

    for (int i = 0; i < sortedMonths.length; i++) {
      final monthKey = sortedMonths[i].key;
      final history = box.get(monthKey, defaultValue: []) as List;

      double totalBill = 0.0;
      for (var item in history) {
        if (item is Map && item['bill'] is num) {
          totalBill += item['bill'] as num;
        }
      }

      spots.add(FlSpot(i.toDouble(), totalBill));
      monthLabels.add(monthKey);
    }

    final maxY = spots.isNotEmpty
        ? spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) * 1.2
        : 100.0; // +20% padding
    final minY = 0.0;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CHART_TITLE'.tr,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: maxY / 5,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= monthLabels.length)
                            return const SizedBox();
                          final label = monthLabels[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Transform.rotate(
                              angle: -0.5, // slight tilt for better readability
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()} EGP',
                            style: const TextStyle(fontSize: 12),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  minX: 0,
                  maxX: (spots.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 4,
                      color: Colors.blueAccent,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor: Colors.blueAccent,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blueAccent.withOpacity(0.4),
                            Colors.blueAccent.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  // FIXED LineTouchData here:
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) =>
                          Colors.blueAccent.withOpacity(0.95),
                      tooltipPadding: const EdgeInsets.all(12),
                      tooltipMargin: 10,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots
                            .map((spot) {
                              final index = spot.x.toInt();
                              if (index >= monthLabels.length) return null;
                              final month = monthLabels[index];
                              return LineTooltipItem(
                                '$month\n${spot.y.toStringAsFixed(2)} EGP',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            })
                            .whereType<LineTooltipItem>()
                            .toList();
                      },
                    ),
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
