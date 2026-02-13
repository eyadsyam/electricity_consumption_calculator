import 'package:finalproject/features/devices/domain/models/device.dart';
// import 'package:http/http.dart' as http; // Uncomment when real API is confirmed

class DeviceRepository {
  final String apiKey = "edf801d065c965443dc99b1225522b5a";

  // Simulating an API call with the provided key
  Future<List<Device>> searchDevices(String query) async {
    // In a real scenario:
    // final response = await http.get(Uri.parse("https://api.device-db.com/search?q=$query&key=$apiKey"));
    // if (response.statusCode == 200) { ... }

    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // Network delay simulation

    // Mock Database powered by the "API"
    final List<Device> allDevices = [
      Device(
        id: '1',
        name: 'Air Conditioner (1.5 HP)',
        powerConsumptionWatts: 1100,
        category: 'Cooling',
        iconPath: 'ac_unit',
      ),
      Device(
        id: '2',
        name: 'Refrigerator (14ft)',
        powerConsumptionWatts: 150,
        category: 'Kitchen',
        iconPath: 'kitchen',
      ),
      Device(
        id: '3',
        name: 'LED TV 55"',
        powerConsumptionWatts: 90,
        category: 'Entertainment',
        iconPath: 'tv',
      ),
      Device(
        id: '4',
        name: 'Washing Machine',
        powerConsumptionWatts: 500,
        category: 'Laundry',
        iconPath: 'local_laundry_service',
      ),
      Device(
        id: '5',
        name: 'Microwave Oven',
        powerConsumptionWatts: 1200,
        category: 'Kitchen',
        iconPath: 'microwave',
      ),
      Device(
        id: '6',
        name: 'Electric Kettle',
        powerConsumptionWatts: 1500,
        category: 'Kitchen',
        iconPath: 'coffee_maker',
      ),
      Device(
        id: '7',
        name: 'PlayStation 5',
        powerConsumptionWatts: 200,
        category: 'Entertainment',
        iconPath: 'sports_esports',
      ),
      Device(
        id: '8',
        name: 'Gaming PC',
        powerConsumptionWatts: 450,
        category: 'Computing',
        iconPath: 'computer',
      ),
      Device(
        id: '9',
        name: 'Laptop',
        powerConsumptionWatts: 65,
        category: 'Computing',
        iconPath: 'laptop',
      ),
      Device(
        id: '10',
        name: 'Ceiling Fan',
        powerConsumptionWatts: 75,
        category: 'Cooling',
        iconPath: 'wind_power',
      ),
    ];

    if (query.isEmpty) return allDevices;

    return allDevices
        .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<double> calculateCost(
    double watts,
    double hours,
    double pricePerKwh,
  ) async {
    return (watts / 1000) * hours * pricePerKwh;
  }
}
