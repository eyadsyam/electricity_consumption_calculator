class DeviceData {
  final String category;
  final double avgWatts;
  final String icon;

  const DeviceData({
    required this.category,
    required this.avgWatts,
    required this.icon,
  });
}

class DeviceDatabase {
  static const Map<String, DeviceData> commonDevices = {
    'تلفزيون': DeviceData(category: 'ترفيه منزلي', avgWatts: 150, icon: 'tv'),
    'ثلاجة': DeviceData(
      category: 'أجهزة المطبخ',
      avgWatts: 200,
      icon: 'kitchen',
    ),
    'تكييف (1.5 حصان)': DeviceData(
      category: 'تكييف وتبريد',
      avgWatts: 1200, // ~1.5 HP
      icon: 'ac_unit',
    ),
    'تكييف (2.25 حصان)': DeviceData(
      category: 'تكييف وتبريد',
      avgWatts: 1800, // ~2.25 HP
      icon: 'ac_unit',
    ),
    'ميكروويف': DeviceData(
      category: 'أجهزة المطبخ',
      avgWatts: 1200,
      icon: 'microwave',
    ),
    'لابتوب': DeviceData(category: 'كمبيوتر', avgWatts: 65, icon: 'laptop'),
    'مروحة سقف/ستاند': DeviceData(
      category: 'تكييف وتبريد',
      avgWatts: 75,
      icon: 'wind_power',
    ),
    'غسالة ملابس': DeviceData(
      category: 'أجهزة منزلية',
      avgWatts: 500,
      icon: 'local_laundry_service',
    ),
    'لمبة LED': DeviceData(category: 'إضاءة', avgWatts: 9, icon: 'lightbulb'),
    'مكواة ملابس': DeviceData(
      category: 'أجهزة منزلية',
      avgWatts: 1000,
      icon: 'iron',
    ),
    'سخان مياه كهربائي': DeviceData(
      category: 'أجهزة منزلية',
      avgWatts: 2000,
      icon: 'water_drop',
    ),
    'راوتر انترنت': DeviceData(
      category: 'الكترونيات',
      avgWatts: 12,
      icon: 'router',
    ),
    'غلاية مياه (كاتل)': DeviceData(
      category: 'أجهزة المطبخ',
      avgWatts: 1500,
      icon: 'kitchen',
    ),
    'موتور مياه (1 حصان)': DeviceData(
      category: 'أجهزة منزلية',
      avgWatts: 750,
      icon: 'water_drop',
    ),
  };

  static DeviceData getByCategory(String deviceName) {
    // Try to find exact match
    if (commonDevices.containsKey(deviceName)) {
      return commonDevices[deviceName]!;
    }

    // Fuzzy search
    return commonDevices.values.firstWhere(
      (d) => d.category.contains(deviceName),
      orElse: () => const DeviceData(
        category: 'جهاز عام',
        avgWatts: 100,
        icon: 'electrical_services',
      ),
    );
  }
}
