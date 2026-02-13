import 'package:flutter/foundation.dart';
import 'package:finalproject/core/di/injection.dart';
import 'package:supabase/supabase.dart';

class ElectricalRateService {
  // Get all rates from Supabase
  Future<List<Map<String, dynamic>>> getAllRates() async {
    try {
      final result = await sl<SupabaseClient>()
          .from('Electricity Rates')
          .select('id, range_start, range_end, price_per_kwh')
          .order('range_start', ascending: true);

      debugPrint('✅ Loaded ${result.length} electricity rates');
      return List<Map<String, dynamic>>.from(result);
    } catch (error) {
      debugPrint('⚠️ Error loading rates: $error');
      return [];
    }
  }

  // Get single rate by ID
  Future<Map<String, dynamic>?> loadRateById(int id) async {
    try {
      final result = await sl<SupabaseClient>()
          .from('Electricity Rates')
          .select('range_start, range_end, price_per_kwh')
          .eq('id', id)
          .single();

      // debugPrint('📊 Electricity Rate $id Details:');
      // debugPrint('Range Start: ${result['range_start']}');
      // debugPrint('Range End: ${result['range_end']}');
      // debugPrint('Price per kWh: ${result['price_per_kwh']}');

      return result;
    } catch (error) {
      debugPrint('⚠️ Error loading rate: $error');
      return null;
    }
  }
}
