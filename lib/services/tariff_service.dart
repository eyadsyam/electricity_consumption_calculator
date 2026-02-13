class TariffService {
  /// Calculates cost based on Egyptian Electricity Tariffs (2024/2025)
  /// Returns cost in EGP
  static double calculateCost(double kwh) {
    if (kwh <= 50) {
      return kwh * 0.68;
    } else if (kwh <= 100) {
      return (50 * 0.68) + ((kwh - 50) * 0.78);
    } else if (kwh <= 200) {
      return kwh * 0.95; // Entire consumption at 95pt if > 100 but <= 200
    } else if (kwh <= 350) {
      return (200 * 0.95) + ((kwh - 200) * 1.55);
    } else if (kwh <= 650) {
      return (200 * 0.95) + (150 * 1.55) + ((kwh - 350) * 1.65);
    } else if (kwh <= 1000) {
      return kwh * 2.10; // Entire consumption at 210pt if > 650 but <= 1000
    } else {
      return kwh * 2.23; // Entire consumption at 223pt if > 1000
    }
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
