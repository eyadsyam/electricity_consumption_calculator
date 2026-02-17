import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase/supabase.dart';
import 'package:finalproject/core/di/injection.dart';
import 'package:finalproject/features/devices/domain/entities/user_device.dart';
import 'package:finalproject/features/electricity_tracking/domain/entities/meter_reading.dart';

class SyncService {
  static const String _devicesBoxName = 'user_devices';
  static const String _readingsBoxName = 'meter_readings';
  static const String _lastSyncKey = 'last_sync_timestamp';

  final SupabaseClient _supabase = sl<SupabaseClient>();

  /// Sync all local data to Supabase when online
  Future<bool> syncToCloud() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        debugPrint('❌ No authenticated user for sync');
        return false;
      }

      debugPrint('🔄 Starting sync to Supabase...');

      // Sync devices
      await _syncDevicesToCloud(userId);

      // Sync meter readings
      await _syncReadingsToCloud(userId);

      // Update last sync timestamp
      final prefs = await Hive.openBox('app_settings');
      await prefs.put(_lastSyncKey, DateTime.now().toIso8601String());

      debugPrint('✅ Sync completed successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Sync error: $e');
      return false;
    }
  }

  /// Fetch data from Supabase and store locally
  Future<bool> syncFromCloud() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      debugPrint('⬇️ Fetching data from Supabase...');

      // Fetch devices
      await _fetchDevicesFromCloud(userId);

      // Fetch readings
      await _fetchReadingsFromCloud(userId);

      debugPrint('✅ Data fetched successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Fetch error: $e');
      return false;
    }
  }

  Future<void> _syncDevicesToCloud(String userId) async {
    final box = await Hive.openBox<UserDevice>(_devicesBoxName);
    final unsyncedDevices = box.values
        .where((device) => !device.isSynced)
        .toList();

    for (var device in unsyncedDevices) {
      try {
        final data = device.toJson();
        data['user_id'] = userId;

        if (device.supabaseId != null) {
          // Update existing
          await _supabase
              .from('user_devices')
              .update(data)
              .eq('id', device.supabaseId!);
        } else {
          // Insert new
          final response = await _supabase
              .from('user_devices')
              .insert(data)
              .select();
          if (response.isNotEmpty) {
            device.supabaseId = response.first['id'];
          }
        }

        device.isSynced = true;
        await device.save();
      } catch (e) {
        debugPrint('❌ Error syncing device ${device.deviceName}: $e');
      }
    }
  }

  Future<void> _syncReadingsToCloud(String userId) async {
    final box = await Hive.openBox<MeterReading>(_readingsBoxName);
    final unsyncedReadings = box.values
        .where((reading) => !reading.isSynced)
        .toList();

    for (var reading in unsyncedReadings) {
      try {
        final data = reading.toJson();
        data['user_id'] = userId;

        // Use upsert with ID
        await _supabase.from('meter_readings').upsert(data);

        reading.isSynced = true;
        await reading.save();
      } catch (e) {
        debugPrint('❌ Error syncing reading: $e');
      }
    }
  }

  Future<void> _fetchDevicesFromCloud(String userId) async {
    final response = await _supabase
        .from('user_devices')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final box = await Hive.openBox<UserDevice>(_devicesBoxName);

    for (var json in response) {
      final device = UserDevice.fromJson(json);
      // Check if device already exists locally
      final existingIndex = box.values.toList().indexWhere(
        (d) => d.supabaseId == device.id,
      );

      if (existingIndex != -1) {
        // Update existing
        await box.putAt(existingIndex, device);
      } else {
        // Add new
        await box.add(device);
      }
    }
  }

  Future<void> _fetchReadingsFromCloud(String userId) async {
    final response = await _supabase
        .from('meter_readings')
        .select()
        .eq('user_id', userId)
        .order('reading_date', ascending: false)
        .limit(100);

    final box = await Hive.openBox<MeterReading>(_readingsBoxName);

    for (var json in response) {
      final reading = MeterReading.fromJson(json);
      final existingIndex = box.values.toList().indexWhere(
        (r) => r.id == reading.id,
      );

      if (existingIndex != -1) {
        await box.putAt(existingIndex, reading);
      } else {
        await box.add(reading);
      }
    }
  }

  /// Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await Hive.openBox('app_settings');
      final timestamp = prefs.get(_lastSyncKey);
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
    } catch (e) {
      debugPrint('Error getting last sync time: $e');
    }
    return null;
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      await _supabase.from('electricity_rates').select().limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }
}
