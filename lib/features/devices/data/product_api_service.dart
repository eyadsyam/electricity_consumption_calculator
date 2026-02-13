import 'package:finalproject/core/network/api_client.dart';

class ProductApiService {
  final ApiClient _client = ApiClient();

  /// Fetches product info from OpenFoodFacts (supports barcodes)
  Future<Map<String, dynamic>?> fetchProductByBarcode(String barcode) async {
    try {
      final response = await _client.get(
        'https://world.openfoodfacts.org/api/v0/product/$barcode.json',
      );

      if (response.statusCode == 200 && response.data['status'] == 1) {
        final product = response.data['product'];
        return {
          'name': product['product_name'] ?? 'Unknown Device',
          'brand': product['brands'] ?? 'Unknown Brand',
          'category': _mapToCategory(product['categories'] ?? ''),
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _mapToCategory(String tags) {
    final t = tags.toLowerCase();
    if (t.contains('tv') || t.contains('television')) {
      return 'TELEVISION';
    }
    if (t.contains('fridge') || t.contains('refrigerator')) {
      return 'REFRIGERATOR';
    }
    if (t.contains('computer') || t.contains('laptop')) {
      return 'LAPTOP';
    }
    if (t.contains('ac') || t.contains('air condition')) {
      return 'AC';
    }
    if (t.contains('wave')) {
      return 'MICROWAVE';
    }
    return 'GENERAL';
  }
}
