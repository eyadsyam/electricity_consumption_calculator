import 'main.dart';

class ElectricalRateService {
  // Get all rates from Supabase
  Future<List<Map<String, dynamic>>> getAllRates() async {
    try {
      final result = await supabase
          .from('Electricity Rates')
          .select('id, range_start, range_end, price_per_kwh')
          .order('range_start', ascending: true);

      print('✅ Loaded ${result.length} electricity rates');
      return List<Map<String, dynamic>>.from(result);
    } catch (error) {
      print('⚠️ Error loading rates: $error');
      return [];
    }
  }

  // Get single rate by ID
  Future<Map<String, dynamic>?> loadRateById(int id) async {
    try {
      final result = await supabase
          .from('Electricity Rates')
          .select('range_start, range_end, price_per_kwh')
          .eq('id', id)
          .single();

      print('📊 Electricity Rate $id Details:');
      print('Range Start: ${result['range_start']}');
      print('Range End: ${result['range_end']}');
      print('Price per kWh: ${result['price_per_kwh']}');

      return result;
    } catch (error) {
      print('⚠️ Error loading rate: $error');
      return null;
    }
  }
}
