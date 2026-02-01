import 'package:equatable/equatable.dart';

/// Reading entity - represents an electricity meter reading
class Reading extends Equatable {
  final int oldReading;
  final int newReading;
  final int consumption;
  final double bill;
  final String date;
  final String month;

  const Reading({
    required this.oldReading,
    required this.newReading,
    required this.consumption,
    required this.bill,
    required this.date,
    required this.month,
  });

  @override
  List<Object?> get props => [
    oldReading,
    newReading,
    consumption,
    bill,
    date,
    month,
  ];

  /// Calculate consumption from readings
  int get calculatedConsumption => newReading - oldReading;

  /// Check if reading is valid
  bool get isValid => newReading > oldReading && consumption >= 0;

  /// Copy with method for immutability
  Reading copyWith({
    int? oldReading,
    int? newReading,
    int? consumption,
    double? bill,
    String? date,
    String? month,
  }) {
    return Reading(
      oldReading: oldReading ?? this.oldReading,
      newReading: newReading ?? this.newReading,
      consumption: consumption ?? this.consumption,
      bill: bill ?? this.bill,
      date: date ?? this.date,
      month: month ?? this.month,
    );
  }

  @override
  String toString() {
    return 'Reading(old: $oldReading, new: $newReading, consumption: $consumption, bill: $bill, date: $date, month: $month)';
  }
}
