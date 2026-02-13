class Device {
  final String id;
  final String name;
  final double powerConsumptionWatts;
  final String category;
  final String iconPath; // e.g. "assets/icons/fridge.svg" or generic icon name

  Device({
    required this.id,
    required this.name,
    required this.powerConsumptionWatts,
    required this.category,
    required this.iconPath,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Device',
      powerConsumptionWatts: (json['val'] ?? 0).toDouble(), // API specific
      category: json['category'] ?? 'General',
      iconPath: json['icon'] ?? 'default',
    );
  }
}
