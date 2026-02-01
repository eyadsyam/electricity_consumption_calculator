import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/monthly_budget.dart';
import '../repositories/electricity_repository.dart';

/// Use case for setting monthly budget
class SetMonthlyBudget implements UseCase<void, SetMonthlyBudgetParams> {
  final ElectricityRepository repository;

  SetMonthlyBudget(this.repository);

  @override
  Future<Either<Failure, void>> call(SetMonthlyBudgetParams params) async {
    // Validate budget amount
    if (params.amount <= 0) {
      return const Left(
        ValidationFailure(message: 'Budget amount must be greater than zero'),
      );
    }

    return await repository.setMonthlyBudget(
      month: params.month,
      amount: params.amount,
    );
  }
}

/// Use case for getting monthly budget
class GetMonthlyBudget implements UseCase<MonthlyBudget?, String> {
  final ElectricityRepository repository;

  GetMonthlyBudget(this.repository);

  @override
  Future<Either<Failure, MonthlyBudget?>> call(String month) async {
    return await repository.getMonthlyBudget(month);
  }
}

/// Use case for removing monthly budget
class RemoveMonthlyBudget implements UseCase<void, String> {
  final ElectricityRepository repository;

  RemoveMonthlyBudget(this.repository);

  @override
  Future<Either<Failure, void>> call(String month) async {
    return await repository.removeMonthlyBudget(month);
  }
}

/// Parameters for SetMonthlyBudget use case
class SetMonthlyBudgetParams {
  final String month;
  final double amount;

  const SetMonthlyBudgetParams({required this.month, required this.amount});
}
