import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/bill.dart';
import '../repositories/electricity_repository.dart';

/// Use case for calculating electricity bill
class CalculateBill implements UseCase<Bill, int> {
  final ElectricityRepository repository;

  CalculateBill(this.repository);

  @override
  Future<Either<Failure, Bill>> call(int consumption) async {
    // Validate consumption
    if (consumption < 0) {
      return const Left(
        ValidationFailure(message: 'Consumption cannot be negative'),
      );
    }

    if (consumption == 0) {
      // Return zero bill for zero consumption
      return Right(
        Bill(
          consumption: 0,
          totalAmount: 0,
          slices: [],
          calculatedAt: DateTime.now(),
        ),
      );
    }

    return await repository.calculateBill(consumption);
  }
}
