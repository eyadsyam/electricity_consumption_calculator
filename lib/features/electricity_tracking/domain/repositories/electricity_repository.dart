import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reading.dart';
import '../entities/bill.dart';
import '../entities/monthly_budget.dart';

/// Repository interface for electricity tracking operations
abstract class ElectricityRepository {
  /// Add a new reading
  Future<Either<Failure, Reading>> addReading({
    required int oldReading,
    required int newReading,
    required String month,
  });

  /// Get all readings for a specific month
  Future<Either<Failure, List<Reading>>> getReadingsForMonth(String month);

  /// Get all readings
  Future<Either<Failure, Map<String, List<Reading>>>> getAllReadings();

  /// Delete a reading
  Future<Either<Failure, void>> deleteReading({
    required String month,
    required int index,
  });

  /// Calculate bill for consumption
  Future<Either<Failure, Bill>> calculateBill(int consumption);

  /// Get last reading for a month
  Future<Either<Failure, int?>> getLastReading(String month);

  /// Set monthly budget
  Future<Either<Failure, void>> setMonthlyBudget({
    required String month,
    required double amount,
  });

  /// Get monthly budget
  Future<Either<Failure, MonthlyBudget?>> getMonthlyBudget(String month);

  /// Remove monthly budget
  Future<Either<Failure, void>> removeMonthlyBudget(String month);

  /// Get total spending for a month
  Future<Either<Failure, double>> getMonthlySpending(String month);

  /// Load electricity rates from remote source
  Future<Either<Failure, void>> loadElectricityRates();

  /// Clear all data (for testing/reset)
  Future<Either<Failure, void>> clearAllData();
}
