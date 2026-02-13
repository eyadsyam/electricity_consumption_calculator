import 'device_database.dart';

class DeviceMapper {
  /// Maps a product name (from API) to a known category and retrieves its avg power
  static DeviceData mapProductToDevice(String productName) {
    final name = productName.toLowerCase();

    if (name.contains('tv') || name.contains('television')) {
      return DeviceDatabase.commonDevices['TELEVISION']!;
    }
    if (name.contains('fridge') || name.contains('refrigerator')) {
      return DeviceDatabase.commonDevices['REFRIGERATOR']!;
    }
    if (name.contains('ac') || name.contains('conditioner')) {
      return DeviceDatabase.commonDevices['AC']!;
    }
    if (name.contains('microwave')) {
      return DeviceDatabase.commonDevices['MICROWAVE']!;
    }
    if (name.contains('wash') || name.contains('laundry')) {
      return DeviceDatabase.commonDevices['WASHING_MACHINE']!;
    }
    if (name.contains('laptop') ||
        name.contains('notebook') ||
        name.contains('macbook')) {
      return DeviceDatabase.commonDevices['LAPTOP']!;
    }
    if (name.contains('bulb') ||
        name.contains('lamp') ||
        name.contains('led')) {
      return DeviceDatabase.commonDevices['LED_BULB']!;
    }

    // Default for unknown devices
    return const DeviceData(
      category: 'General Electronic',
      avgWatts: 50.0,
      icon: 'electrical_services',
    );
  }
}
