import 'package:finalproject/services/bill_calculator_service.dart';

class TariffService {
  /// Calculates cost based on Egyptian Electricity Tariffs (2024/2025)
  /// Returns Pure Energy Cost in EGP
  /// For full bill with fees, use calculateFullBill
  static double calculateCost(double kwh) {
    final bill = BillCalculatorService.calculateBill(kwh);
    return bill['energy_cost'] as double;
  }

  /// Returns full bill details including fees, stamps, and official rounding
  static Map<String, dynamic> calculateFullBill(double kwh) {
    return BillCalculatorService.calculateBill(kwh);
  }

  static int getTier(double kwh) {
    if (kwh <= 50) return 1;
    if (kwh <= 100) return 2;
    if (kwh <= 200) return 3;
    if (kwh <= 350) return 4;
    if (kwh <= 650) return 5;
    if (kwh <= 1000) return 6;
    return 7;
  }
}
