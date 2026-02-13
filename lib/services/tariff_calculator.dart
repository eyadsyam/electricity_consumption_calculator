/// Electricity Tariff Calculator for Egypt (2024/2025)
/// Calculates the correct tier based on consumption and applies official rates.
class TariffCalculator {
  /// Egyptian Electricity Tariff Tiers
  static const Map<String, Map<String, dynamic>> tariffs = {
    'tier1': {
      'name': 'الشريحة الأولى',
      'min': 0,
      'max': 50,
      'rate': 0.68,
      'description': 'حتى 50 كيلووات ساعة',
    },
    'tier2': {
      'name': 'الشريحة الثانية',
      'min': 51,
      'max': 100,
      'rate': 0.78,
      'description': 'من 51 إلى 100 كيلووات ساعة',
    },
    'tier3': {
      'name': 'الشريحة الثالثة',
      'min': 0,
      'max': 200,
      'rate': 0.95,
      'description': 'من 0 إلى 200 كيلووات ساعة',
    },
    'tier4': {
      'name': 'الشريحة الرابعة',
      'min': 201,
      'max': 350,
      'rate': 1.55,
      'description': 'من 201 إلى 350 كيلووات ساعة',
    },
    'tier5': {
      'name': 'الشريحة الخامسة',
      'min': 351,
      'max': 650,
      'rate': 1.95,
      'description': 'من 351 إلى 650 كيلووات ساعة',
    },
    'tier6': {
      'name': 'الشريحة السادسة',
      'min': 0,
      'max': 1000,
      'rate': 2.10,
      'description': 'من 0 إلى 1000 كيلووات ساعة',
    },
    'tier7': {
      'name': 'الشريحة السابعة',
      'min': 0,
      'max': double.infinity,
      'rate': 2.23,
      'description': 'أكثر من 1000 كيلووات ساعة',
    },
  };

  /// Service fees based on consumption bracket
  static double getServiceFee(double consumption) {
    if (consumption <= 50) return 6.0;
    if (consumption <= 100) return 15.0;
    if (consumption <= 200) return 25.0;
    if (consumption <= 350) return 30.0;
    if (consumption <= 650) return 35.0;
    if (consumption <= 1000) return 45.0;
    return 50.0; // > 1000
  }

  /// Determine which tier the consumption falls into
  static Map<String, dynamic> determineTier(double consumption) {
    if (consumption <= 50) return tariffs['tier1']!;
    if (consumption <= 100) return tariffs['tier2']!;
    if (consumption <= 200) return tariffs['tier3']!;
    if (consumption <= 350) return tariffs['tier4']!;
    if (consumption <= 650) return tariffs['tier5']!;
    if (consumption <= 1000) return tariffs['tier6']!;
    return tariffs['tier7']!;
  }

  /// Calculate cost based on Egyptian electricity rules
  static Map<String, dynamic> calculateProgressiveCost(double consumption) {
    double totalCost = 0.0;
    final List<Map<String, dynamic>> breakdown = [];
    String currentTierKey = '';

    if (consumption <= 50) {
      // Tier 1 only
      currentTierKey = 'tier1';
      final rate = (tariffs['tier1']!['rate'] as num).toDouble();
      final cost = consumption * rate;
      totalCost = cost;
      breakdown.add({
        'tier': tariffs['tier1']!['name'],
        'consumption': consumption,
        'rate': rate,
        'cost': cost,
      });
    } else if (consumption <= 100) {
      // Tier 1 (50) + Tier 2 (remaining)
      currentTierKey = 'tier2';

      // First 50 kwh
      final rate1 = (tariffs['tier1']!['rate'] as num).toDouble();
      final cost1 = 50 * rate1;
      totalCost += cost1;
      breakdown.add({
        'tier': tariffs['tier1']!['name'],
        'consumption': 50.0,
        'rate': rate1,
        'cost': cost1,
      });

      // Remaining
      final remaining = consumption - 50;
      final rate2 = (tariffs['tier2']!['rate'] as num).toDouble();
      final cost2 = remaining * rate2;
      totalCost += cost2;
      breakdown.add({
        'tier': tariffs['tier2']!['name'],
        'consumption': remaining,
        'rate': rate2,
        'cost': cost2,
      });
    } else if (consumption <= 200) {
      // Tier 3 covers entire consumption (0-200)
      currentTierKey = 'tier3';
      final rate = (tariffs['tier3']!['rate'] as num).toDouble();
      final cost = consumption * rate;
      totalCost = cost;
      breakdown.add({
        'tier': tariffs['tier3']!['name'],
        'consumption': consumption,
        'rate': rate,
        'cost': cost,
      });
    } else if (consumption <= 350) {
      // Tier 3 (200) + Tier 4 (remaining)
      currentTierKey = 'tier4';

      // First 200 kwh
      final rate3 = (tariffs['tier3']!['rate'] as num).toDouble();
      final cost3 = 200 * rate3;
      totalCost += cost3;
      breakdown.add({
        'tier': tariffs['tier3']!['name'],
        'consumption': 200.0,
        'rate': rate3,
        'cost': cost3,
      });

      // Remaining
      final remaining = consumption - 200;
      final rate4 = (tariffs['tier4']!['rate'] as num).toDouble();
      final cost4 = remaining * rate4;
      totalCost += cost4;
      breakdown.add({
        'tier': tariffs['tier4']!['name'],
        'consumption': remaining,
        'rate': rate4,
        'cost': cost4,
      });
    } else if (consumption <= 650) {
      // Tier 3 (200) + Tier 4 (150) + Tier 5 (remaining)
      currentTierKey = 'tier5';

      // First 200 kwh
      final rate3 = (tariffs['tier3']!['rate'] as num).toDouble();
      final cost3 = 200 * rate3;
      totalCost += cost3;
      breakdown.add({
        'tier': tariffs['tier3']!['name'],
        'consumption': 200.0,
        'rate': rate3,
        'cost': cost3,
      });

      // Next 150 kwh (201-350)
      final rate4 = (tariffs['tier4']!['rate'] as num).toDouble();
      final cost4 = 150 * rate4;
      totalCost += cost4;
      breakdown.add({
        'tier': tariffs['tier4']!['name'],
        'consumption': 150.0,
        'rate': rate4,
        'cost': cost4,
      });

      // Remaining
      final remaining = consumption - 350;
      final rate5 = (tariffs['tier5']!['rate'] as num).toDouble();
      final cost5 = remaining * rate5;
      totalCost += cost5;
      breakdown.add({
        'tier': tariffs['tier5']!['name'],
        'consumption': remaining,
        'rate': rate5,
        'cost': cost5,
      });
    } else if (consumption <= 1000) {
      // Tier 6 covers entire consumption (0-1000)
      currentTierKey = 'tier6';
      final rate = (tariffs['tier6']!['rate'] as num).toDouble();
      final cost = consumption * rate;
      totalCost = cost;
      breakdown.add({
        'tier': tariffs['tier6']!['name'],
        'consumption': consumption,
        'rate': rate,
        'cost': cost,
      });
    } else {
      // Tier 7 covers entire consumption (> 1000)
      currentTierKey = 'tier7';
      final rate = (tariffs['tier7']!['rate'] as num).toDouble();
      final cost = consumption * rate;
      totalCost = cost;
      breakdown.add({
        'tier': tariffs['tier7']!['name'],
        'consumption': consumption,
        'rate': rate,
        'cost': cost,
      });
    }

    // Add service fee
    final serviceFee = getServiceFee(consumption);
    totalCost += serviceFee;

    return {
      'subtotal': totalCost - serviceFee,
      'serviceFee': serviceFee,
      'tax':
          0.0, // Usually included or not applicable in this simple calculation
      'total': totalCost,
      'breakdown': breakdown,
      'currentTier': tariffs[currentTierKey],
    };
  }

  /// Calculate simple cost (flat rate based on tier)
  /// For Egypt, this is effectively the same as progressive logic
  /// because the rules handle when to be progressive and when to be flat.
  static Map<String, dynamic> calculateSimpleCost(double consumption) {
    return calculateProgressiveCost(consumption);
  }

  /// Get tier color for UI
  static int getTierColor(String tierName) {
    switch (tierName) {
      case 'الشريحة الأولى':
        return 0xFF4CAF50; // Green
      case 'الشريحة الثانية':
        return 0xFF8BC34A; // Light Green
      case 'الشريحة الثالثة':
        return 0xFFFFC107; // Amber
      case 'الشريحة الرابعة':
        return 0xFFFF9800; // Orange
      case 'الشريحة الخامسة':
        return 0xFFFF5722; // Deep Orange
      case 'الشريحة السادسة':
        return 0xFFF44336; // Red
      case 'الشريحة السابعة':
        return 0xFF9C27B0; // Purple
      default:
        return 0xFFD4AF37; // Gold
    }
  }

  /// Get savings tip based on tier
  static String getSavingsTip(String tierName) {
    switch (tierName) {
      case 'الشريحة الأولى':
        return 'استهلاكك ممتاز! حافظ على هذا المعدل';
      case 'الشريحة الثانية':
        return 'استهلاك جيد، حاول تقليله قليلاً للبقاء في الشريحة الأولى';
      case 'الشريحة الثالثة':
        return 'استهلاك متوسط، يمكنك توفير المزيد بإطفاء الأجهزة غير المستخدمة';
      case 'الشريحة الرابعة':
        return 'استهلاك مرتفع! راجع الأجهزة التي تستهلك طاقة كبيرة';
      case 'الشريحة الخامسة':
        return 'استهلاك مرتفع جداً! افحص التكييف والسخان الكهربائي';
      case 'الشريحة السادسة':
        return 'تحذير: استهلاك مفرط! قد تحتاج لمراجعة العداد';
      case 'الشريحة السابعة':
        return 'استهلاك استثنائي! تأكد من عدم وجود تسريب كهربائي';
      default:
        return 'راقب استهلاكك بانتظام';
    }
  }

  /// Predict next month's tier based on current consumption rate
  static Map<String, dynamic> predictNextMonthTier({
    required double currentConsumption,
    required int daysElapsed,
  }) {
    // Avoid division by zero
    if (daysElapsed <= 0) daysElapsed = 1;

    final dailyAverage = currentConsumption / daysElapsed;
    final projectedMonthlyConsumption = dailyAverage * 30;

    final predictedCostData = calculateProgressiveCost(
      projectedMonthlyConsumption,
    );

    return {
      'projectedConsumption': projectedMonthlyConsumption,
      'predictedTier': predictedCostData['currentTier'],
      'predictedCost': predictedCostData['total'],
      'dailyAverage': dailyAverage,
    };
  }
}
