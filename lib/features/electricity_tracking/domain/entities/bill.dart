import 'package:equatable/equatable.dart';

/// Bill entity - represents an electricity bill calculation
class Bill extends Equatable {
  final int consumption;
  final double totalAmount;
  final List<BillSlice> slices;
  final DateTime calculatedAt;

  const Bill({
    required this.consumption,
    required this.totalAmount,
    required this.slices,
    required this.calculatedAt,
  });

  @override
  List<Object?> get props => [consumption, totalAmount, slices, calculatedAt];

  /// Get average price per kWh
  double get averagePricePerKwh {
    if (consumption == 0) return 0;
    return totalAmount / consumption;
  }

  /// Copy with method
  Bill copyWith({
    int? consumption,
    double? totalAmount,
    List<BillSlice>? slices,
    DateTime? calculatedAt,
  }) {
    return Bill(
      consumption: consumption ?? this.consumption,
      totalAmount: totalAmount ?? this.totalAmount,
      slices: slices ?? this.slices,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  @override
  String toString() {
    return 'Bill(consumption: $consumption kWh, total: EGP $totalAmount, slices: ${slices.length})';
  }
}

/// Represents a single pricing slice in the bill calculation
class BillSlice extends Equatable {
  final int rangeStart;
  final int? rangeEnd;
  final double pricePerKwh;
  final int unitsInSlice;
  final double sliceAmount;

  const BillSlice({
    required this.rangeStart,
    this.rangeEnd,
    required this.pricePerKwh,
    required this.unitsInSlice,
    required this.sliceAmount,
  });

  @override
  List<Object?> get props => [
    rangeStart,
    rangeEnd,
    pricePerKwh,
    unitsInSlice,
    sliceAmount,
  ];

  String get rangeDescription {
    if (rangeEnd == null) {
      return '$rangeStart+ kWh';
    }
    return '$rangeStart-$rangeEnd kWh';
  }

  @override
  String toString() {
    return 'BillSlice($rangeDescription @ EGP $pricePerKwh/kWh = EGP $sliceAmount)';
  }
}
