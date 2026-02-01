import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final box = Hive.box('historyBox');

  @override
  Widget build(BuildContext context) {

// Get theme colors for dynamic styling
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;


    // فلترة الـ keys عشان نجيب الشهور بس (نتجاهل budget_)
    final allKeys = box.keys.toList();
    final months = allKeys
        .where((key) => key is String && !key.toString().startsWith('budget_'))
        .toList();

    return Scaffold(
      // 1. Use theme's background color
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        // 2. Use theme's background color
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          'HISTORY_TITLE'.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            // 3. Use theme's primary text color
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        centerTitle: true,
      ),
      body: months.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'HISTORY_EMPTY_TITLE'.tr,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'HISTORY_EMPTY_SUBTITLE'.tr,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          final history = box.get(month, defaultValue: []);

          // التأكد إن history فعلاً List
          if (history is! List || history.isEmpty) {
            return const SizedBox();
          }

          final count = history.length;
          final transactionWord = count > 1
              ? 'HISTORY_TRANSACTIONS_PLURAL'.tr
              : 'HISTORY_TRANSACTION_SINGULAR'.tr;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// اسم الشهر
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.calendar_month,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      month.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$count $transactionWord',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              /// جميع تعاملات الشهر
              ...history.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;

                // التأكد إن item هو Map
                if (item is! Map) {
                  return const SizedBox();
                }

                return Dismissible(
                  key: Key(
                    '$month-$i-${DateTime.now().millisecondsSinceEpoch}',
                  ),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  onDismissed: (direction) {
                    final updated = List<Map<String, dynamic>>.from(
                      history.map(
                            (e) => Map<String, dynamic>.from(e as Map),
                      ),
                    );
                    updated.removeAt(i);
                    box.put(month, updated);

                    setState(() {});

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('HISTORY_DELETE_SNACKBAR'.tr),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        /// Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bolt,
                            color: Colors.amber,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 16),

                        /// Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'HISTORY_BILL_TITLE'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${'HISTORY_READING_OLD'.tr}: ${item['oldReading']} kWh → ${'HISTORY_READING_NEW'.tr}: ${item['newReading']} kWh',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${'HISTORY_CONSUMPTION'.tr}: ${item['consumption']} kWh',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Right Side
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'EGP ${(item['bill'] ?? 0).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item['date']?.toString() ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}