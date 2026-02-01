// class BillCalculator {
//   static double calculateBill(int units) {
//     double total = 0;
//
//     if (units <= 50) {
//       total = units * 0.48;
//     } else if (units <= 100) {
//       total = (50 * 0.48) + ((units - 50) * 0.58);
//     } else if (units <= 150) {
//       total = (50 * 0.48) + (50 * 0.58) + ((units - 100) * 0.77);
//     } else if (units <= 200) {
//       total = (50 * 0.48) + (50 * 0.58) + (50 * 0.77) + ((units - 150) * 0.90);
//     } else if (units <= 250) {
//       total =
//           (50 * 0.48) +
//           (50 * 0.58) +
//           (50 * 0.77) +
//           (50 * 0.90) +
//           ((units - 200) * 1.20);
//     } else {
//       total =
//           (50 * 0.48) +
//           (50 * 0.58) +
//           (50 * 0.77) +
//           (50 * 0.90) +
//           (50 * 1.20) +
//           ((units - 250) * 1.45);
//     }
//
//     return total;
//   }
// }

// // ..................

class BillCalculator {
  // Cache للأسعار
  static List<Map<String, dynamic>>? _cachedRates;

  // تحميل الأسعار من Supabase مرة واحدة
  static Future<void> loadRates() async {
    if (_cachedRates != null) return; // لو محملة خلاص، متحملش تاني

    // Commented out for APK build - using default rates instead
    // try {
    //   final rates = await supabase
    //       .from('Electricity Rates')
    //       .select('range_start, range_end, price_per_kwh')
    //       .order('range_start', ascending: true);
    //
    //   _cachedRates = List<Map<String, dynamic>>.from(rates);
    //   print('✅ Rates loaded successfully');
    // } catch (error) {
    //   print('⚠️ Error loading rates: $error');
    //   _cachedRates = [];
    // }

    // Use default rates for now
    _cachedRates = [];
  }

  static double calculateBill(int units) {
    // لو الأسعار مش محملة، استخدم الأسعار الافتراضية القديمة
    if (_cachedRates == null || _cachedRates!.isEmpty) {
      return _calculateBillWithDefaultRates(units);
    }

    double total = 0;
    int remainingUnits = units;

    for (var rate in _cachedRates!) {
      int rangeStart = rate['range_start'] ?? 0;
      int? rangeEnd = rate['range_end'];
      double pricePerKwh = (rate['price_per_kwh'] ?? 0.0).toDouble();

      int unitsInRange;
      if (rangeEnd == null) {
        // آخر شريحة (مفتوحة)
        unitsInRange = remainingUnits;
      } else {
        int rangeSize = rangeEnd - rangeStart;
        unitsInRange = remainingUnits > rangeSize ? rangeSize : remainingUnits;
      }

      total += unitsInRange * pricePerKwh;
      remainingUnits -= unitsInRange;

      if (remainingUnits <= 0) break;
    }

    return total;
  }

  // الأسعار القديمة كـ backup
  static double _calculateBillWithDefaultRates(int units) {
    double total = 0;

    if (units <= 50) {
      total = units * 0.48;
    } else if (units <= 100) {
      total = (50 * 0.48) + ((units - 50) * 0.58);
    } else if (units <= 150) {
      total = (50 * 0.48) + (50 * 0.58) + ((units - 100) * 0.77);
    } else if (units <= 200) {
      total = (50 * 0.48) + (50 * 0.58) + (50 * 0.77) + ((units - 150) * 0.90);
    } else if (units <= 250) {
      total =
          (50 * 0.48) +
          (50 * 0.58) +
          (50 * 0.77) +
          (50 * 0.90) +
          ((units - 200) * 1.20);
    } else {
      total =
          (50 * 0.48) +
          (50 * 0.58) +
          (50 * 0.77) +
          (50 * 0.90) +
          (50 * 1.20) +
          ((units - 250) * 1.45);
    }

    return total;
  }
}

// //.....................
// Future<double> calculateTotalBill(int consumption) async {
//   try {
//     // 1) هات كل الشرائح مرتّبة
//     final rates = await cloud
//         .from('Electricity Rates')
//         .select()
//         .order('range_start', ascending: true);
//
//     if (rates == null || rates.isEmpty) {
//       throw Exception("No rates found");
//     }
//
//     double total = 0;
//     int remaining = consumption;
//
//     for (var rate in rates) {
//       int start = rate['range_start'];
//       int end = rate['range_end'];
//       double price = (rate['price_per_kwh'] as num).toDouble();
//
//       if (remaining <= 0) break;
//
//       // كام وحدة جوّه الشريحة دي؟
//       int maxUnitsInThisRange = end - start + 1;
//
//       // وحدات اليوزر اللي تقع داخل الشريحة دي
//       int unitsInThisTier = remaining > maxUnitsInThisRange
//           ? maxUnitsInThisRange
//           : remaining;
//
//       // جمع سعرها
//       total += unitsInThisTier * price;
//
//       // قلّل المتبقي
//       remaining -= unitsInThisTier;
//     }
//
//     return total;
//   } catch (e) {
//     print("⚠️ Error calculating bill: $e");
//     return 0.0;
//   }
// }
