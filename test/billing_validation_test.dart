import 'package:flutter_test/flutter_test.dart';
import 'package:finalproject/services/bill_calculator_service.dart';

void main() {
  group('BillCalculatorService', () {
    test('Calculate Bill for 369 kWh (Scenario 1)', () {
      final result = BillCalculatorService.calculateBill(
        369,
        installments: 129.79,
        deductions: 0.32, // Adjusted deduction from user example
      );

      // Energy Cost Validation
      expect(result['energy_cost'], closeTo(459.55, 0.1));

      // Customer Service Fee Validation
      expect(result['customer_service'], equals(15.0));

      // Final Payable Validation
      // User example: 615 EGP
      expect(result['final_payable'], equals(615));
    });

    test('Calculate Bill for 434 kWh (Scenario 2)', () {
      final result = BillCalculatorService.calculateBill(
        434,
        installments: 129.79,
        deductions: 0.67, // Adjusted deduction
      );

      // Energy Cost Validation
      expect(result['energy_cost'], closeTo(586.30, 0.1));

      // Customer Service Fee Validation
      expect(result['customer_service'], equals(15.0));

      // Final Payable Validation
      // User example: 741 EGP
      expect(result['final_payable'], equals(741));
    });
  });
}
