import 'package:hive/hive.dart';

part 'tariff_entity.g.dart';

@HiveType(typeId: 3)
class TariffSlab extends HiveObject {
  @HiveField(0)
  final int startKwh;

  @HiveField(1)
  final int endKwh; // Use -1 or very large number for infinity

  @HiveField(2)
  final double pricePerKwh; // In EGP

  @HiveField(3)
  final int slabOrder; // To ensure correct processing order

  TariffSlab({
    required this.startKwh,
    required this.endKwh,
    required this.pricePerKwh,
    required this.slabOrder,
  });
}

@HiveType(typeId: 4)
class TariffFee extends HiveObject {
  @HiveField(0)
  final String name; // e.g., "Customer Service", "Cleanliness"

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final int minKwh; // Fee applies if consumption > minKwh

  @HiveField(3)
  final int maxKwh; // Fee applies if consumption <= maxKwh

  TariffFee({
    required this.name,
    required this.amount,
    required this.minKwh,
    required this.maxKwh,
  });
}
