import 'package:finalproject/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'reading_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final months = [
    'JANUARY'.tr,
    'FEBRUARY'.tr,
    'MARCH'.tr,
    'APRIL'.tr,
    'MAY'.tr,
    'JUNE'.tr,
    'JULY'.tr,
    'AUGUST'.tr,
    'SEPTEMBER'.tr,
    'OCTOBER'.tr,
    'NOVEMBER'.tr,
    'DECEMBER'.tr,
  ];

  String selectedMonth = 'JANUARY'.tr;

  @override
  void initState() {
    // Hive.box('historyBox').clear();
    super.initState();
    final now = DateTime.now();
    // We use the untranslated key to lookup the month list for the index, then select the translated string
    final untranslatedMonths = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    final monthKey = untranslatedMonths[now.month - 1];
    selectedMonth = monthKey.tr;
  }

  double _getMonthBalance(String month) {
    final box = Hive.box('historyBox');
    double total = 0;

    final history = box.get(month, defaultValue: []);
    if (history is List && history.isNotEmpty) {
      for (var entry in history) {
        if (entry is Map) {
          total += (entry['bill'] ?? 0);
        }
      }
    }
    return total;
  }

  double _getMonthBudget(String month) {
    final box = Hive.box('historyBox');
    return box.get('budget_$month', defaultValue: 0.0);
  }

  void _setMonthBudget(String month, double budget) {
    final box = Hive.box('historyBox');
    box.put('budget_$month', budget);
  }

  @override
  Widget build(BuildContext context) {
    final historyBox = Hive.box('historyBox');

    // 1. Get the Theme Service
    final ThemeService themeService = Get.find<ThemeService>();

    // 2. Check current visual mode (handles System mode correctly)
    final bool isDarkMode = themeService.isDarkMode;

    // Helper colors based on theme, NOW DEFINED LOCALLY IN BUILD
    final Color cardBackgroundColor = Theme.of(context).cardColor;

    // Robustly get primary and secondary text colors
    // Note: We use bodyLarge!.color! to get the non-nullable color value.
    final Color primaryTextColor = Theme.of(
      context,
    ).textTheme.bodyLarge!.color!;
    final Color secondaryTextColor = primaryTextColor.withOpacity(0.7);

    final Color iconBackgroundColor = isDarkMode
        ? Colors.blue.shade900
        : Colors.blue.shade50;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'APP_TITLE'.tr,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BALANCE CARD
            ValueListenableBuilder(
              valueListenable: historyBox.listenable(),
              builder: (context, box, _) {
                final balance = _getMonthBalance(selectedMonth);
                final budget = _getMonthBudget(selectedMonth);
                final isOverBudget = budget > 0 && balance > budget;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isOverBudget
                          ? [Colors.red.shade400, Colors.red.shade600]
                          : [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (isOverBudget ? Colors.red : Colors.blue)
                            .withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BALANCE_CARD_TITLE'.tr,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          InkWell(
                            onTap: () =>
                                // Context is available here
                                _showBudgetDialog(context, selectedMonth),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'BUDGET_BUTTON'.tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'NET_BALANCE_LABEL'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'EGP ${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (budget > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'BUDGET_LABEL'.trParams({
                                'amount': budget.toStringAsFixed(2),
                              }),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isOverBudget)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'OVER_BUDGET_STATUS'.tr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            'FOR_MONTH_LABEL'.trParams({
                              'month': selectedMonth,
                            }),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // SELECT MONTH
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'SELECT_MONTH_TITLE'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // MONTH LIST
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: months.length,
                itemBuilder: (context, index) {
                  final month = months[index];
                  final selected = month == selectedMonth;

                  return GestureDetector(
                    onTap: () => setState(() => selectedMonth = month),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: selected ? Colors.blue : cardBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDarkMode ? 0.2 : 0.05,
                            ),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            month.substring(0, 3),
                            style: TextStyle(
                              color: selected ? Colors.white : primaryTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'YEAR_2025'.tr,
                            style: TextStyle(
                              color: selected
                                  ? Colors.white70
                                  : secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Recent Transaction + ADD READING
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT_TRANSACTION_TITLE'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      _showAddReadingDialog(context, selectedMonth);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_circle,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ADD_READING_BUTTON'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // LAST TRANSACTION ONLY — NO DELETE HERE
            ValueListenableBuilder(
              valueListenable: historyBox.listenable(),
              builder: (context, box, _) {
                final history = box.get(selectedMonth, defaultValue: []);

                if (history is! List || history.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: cardBackgroundColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 60,
                          color: isDarkMode
                              ? Colors.grey.shade700
                              : Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'NO_TRANSACTIONS_FOR_MONTH'.trParams({
                            'month': selectedMonth,
                          }),
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'ADD_FIRST_READING_HINT'.tr,
                          style: TextStyle(
                            color: secondaryTextColor.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final entry = history.last;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(
                          isDarkMode ? 0.2 : 0.05,
                        ),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: iconBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.bolt,
                          color: Colors.amber,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HISTORY_BILL_TITLE'.tr,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${'HISTORY_READING_OLD'.tr}: ${entry['oldReading']} → ${'HISTORY_READING_NEW'.tr}: ${entry['newReading']}',
                              style: TextStyle(
                                color: secondaryTextColor,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${'HISTORY_CONSUMPTION'.tr}: ${entry['consumption']} kWh',
                              style: TextStyle(
                                color: secondaryTextColor,
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
                            'EGP ${entry['bill'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry['date'] ?? '',
                            style: TextStyle(
                              color: secondaryTextColor.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddReadingDialog(BuildContext context, String month) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReadingSheet(month: month),
    );
  }

  void _showBudgetDialog(BuildContext context, String month) {
    final currentBudget = _getMonthBudget(month);
    final controller = TextEditingController(
      text: currentBudget > 0 ? currentBudget.toStringAsFixed(0) : '',
    );

    // --- REDEFINED THEME COLORS INSIDE THE DIALOG BUILDER ---
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color dialogBackgroundColor = Theme.of(context).dialogBackgroundColor;
    final Color primaryTextColor = Theme.of(
      context,
    ).textTheme.bodyLarge!.color!;
    final Color secondaryTextColor = primaryTextColor.withOpacity(0.7);
    final Color iconBackgroundColor = isDarkMode
        ? Colors.blue.shade900
        : Colors.blue.shade50;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'SET_BUDGET_TITLE'.trParams({'month': month}),
              style: TextStyle(fontSize: 18, color: primaryTextColor),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BUDGET_DIALOG_MESSAGE'.tr,
              style: TextStyle(color: secondaryTextColor, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'BUDGET_AMOUNT_LABEL'.tr,
                prefixText: 'EGP ',
                filled: true,
                // Use the theme-aware input color derived from the context inside the builder
                fillColor:
                    Theme.of(context).inputDecorationTheme.fillColor ??
                    (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (currentBudget > 0)
            TextButton(
              onPressed: () {
                _setMonthBudget(month, 0);
                // Context is available here
                Navigator.pop(context);
                setState(() {});
              },
              child: Text(
                'REMOVE_BUDGET_BUTTON'.tr,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL_BUTTON'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              final budget = double.tryParse(controller.text) ?? 0;
              if (budget > 0) {
                _setMonthBudget(month, budget);
                // Context is available here
                Navigator.pop(context);
                setState(() {});
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('SAVE_BUTTON'.tr),
          ),
        ],
      ),
    );
  }
}
