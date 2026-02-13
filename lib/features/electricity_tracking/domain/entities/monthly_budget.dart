import 'package:equatable/equatable.dart';

/// Monthly budget entity
class MonthlyBudget extends Equatable {
  final String month;
  final double budgetAmount;
  final double currentSpending;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MonthlyBudget({
    required this.month,
    required this.budgetAmount,
    required this.currentSpending,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    month,
    budgetAmount,
    currentSpending,
    createdAt,
    updatedAt,
  ];

  /// Check if budget is exceeded
  bool get isExceeded => currentSpending > budgetAmount;

  /// Get remaining budget
  double get remainingBudget => budgetAmount - currentSpending;

  /// Get budget utilization percentage
  double get utilizationPercentage {
    if (budgetAmount == 0) return 0;
    return (currentSpending / budgetAmount) * 100;
  }

  /// Get status
  BudgetStatus get status {
    if (currentSpending >= budgetAmount) return BudgetStatus.exceeded;
    if (utilizationPercentage >= 80) return BudgetStatus.warning;
    return BudgetStatus.normal;
  }

  /// Copy with method
  MonthlyBudget copyWith({
    String? month,
    double? budgetAmount,
    double? currentSpending,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MonthlyBudget(
      month: month ?? this.month,
      budgetAmount: budgetAmount ?? this.budgetAmount,
      currentSpending: currentSpending ?? this.currentSpending,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'MonthlyBudget(month: $month, budget: $budgetAmount, spent: $currentSpending, status: $status)';
  }
}

/// Budget status enum
enum BudgetStatus { normal, warning, exceeded }
