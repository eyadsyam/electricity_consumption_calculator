import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase/supabase.dart';
import 'package:finalproject/features/electricity_tracking/domain/entities/meter_reading.dart';
import 'package:finalproject/features/devices/domain/entities/user_device.dart';
import 'package:finalproject/core/di/injection.dart';

/// Supabase Sync Service
/// Syncs local Hive data with Supabase cloud database
/// Implements Hybrid (Offline-First + Cloud Backup) architecture
class SupabaseSyncService {
  final SupabaseClient _supabase = sl<SupabaseClient>();

  bool _isSyncing = false;

  /// Check if user is authenticated
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// Get current user ID
  String? get userId => _supabase.auth.currentUser?.id;

  /// Sync all meter readings to Supabase
  Future<void> syncMeterReadings() async {
    if (!isAuthenticated || _isSyncing) return;

    _isSyncing = true;

    try {
      final box = await Hive.openBox<MeterReading>('meter_readings');
      final unsyncedReadings = box.values.where((r) => !r.isSynced).toList();

      debugPrint('🔄 Syncing ${unsyncedReadings.length} meter readings...');

      for (var reading in unsyncedReadings) {
        try {
          // Insert to Supabase
          await _supabase.from('meter_readings').insert({
            'id': reading.id,
            'user_id': userId,
            'reading_value': reading.readingValue,
            'reading_date': reading.readingDate.toIso8601String().split('T')[0],
            'consumption_kwh': reading.consumptionKwh,
            'estimated_cost': reading.estimatedCost,
            'notes': reading.notes,
            'created_at': reading.createdAt.toIso8601String(),
          });

          // Mark as synced in Hive
          reading.isSynced = true;
          await reading.save();

          debugPrint('✅ Synced reading: ${reading.id}');
        } catch (e) {
          debugPrint('❌ Failed to sync reading ${reading.id}: $e');
          // Continue with next reading
        }
      }

      debugPrint('✅ Sync completed!');
    } catch (e) {
      debugPrint('❌ Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync all user devices to Supabase
  Future<void> syncUserDevices() async {
    if (!isAuthenticated || _isSyncing) return;

    _isSyncing = true;

    try {
      final box = await Hive.openBox<UserDevice>('user_devices');
      final unsyncedDevices = box.values.where((d) => !d.isSynced).toList();

      debugPrint('🔄 Syncing ${unsyncedDevices.length} devices...');

      for (var device in unsyncedDevices) {
        try {
          // Insert to Supabase
          await _supabase.from('user_devices').insert({
            'id': device.id,
            'user_id': userId,
            'device_name': device.deviceName,
            'device_category': device.category,
            'power_watts': device.powerWatts,
            'usage_hours_per_day': device.usageHoursPerDay,
            'icon_name': device.iconName,
            'is_active': device.isActive,
            'created_at': device.createdAt.toIso8601String(),
          });

          // Mark as synced in Hive
          device.isSynced = true;
          device.supabaseId = device.id;
          await device.save();

          debugPrint('✅ Synced device: ${device.deviceName}');
        } catch (e) {
          debugPrint('❌ Failed to sync device ${device.deviceName}: $e');
        }
      }

      debugPrint('✅ Device sync completed!');
    } catch (e) {
      debugPrint('❌ Device sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync everything (readings + devices)
  Future<void> syncAll() async {
    if (!isAuthenticated) {
      debugPrint('⚠️ Not authenticated. Skipping sync.');
      return;
    }

    debugPrint('🔄 Starting full sync...');
    await syncMeterReadings();
    await syncUserDevices();
    debugPrint('✅ Full sync completed!');
  }

  /// Pull latest data from Supabase
  Future<void> pullFromSupabase() async {
    if (!isAuthenticated) return;

    try {
      debugPrint('⬇️ Pulling data from Supabase...');

      // Pull meter readings
      final readingsData = await _supabase
          .from('meter_readings')
          .select()
          .eq('user_id', userId!);

      final readingsBox = await Hive.openBox<MeterReading>('meter_readings');

      for (var data in readingsData) {
        final reading = MeterReading.fromJson(data);

        // Check if already exists
        final existingIndex = readingsBox.values.toList().indexWhere(
          (r) => r.id == reading.id,
        );

        if (existingIndex == -1) {
          // New reading, add it
          await readingsBox.add(reading);
          debugPrint('✅ Pulled new reading: ${reading.id}');
        }
      }

      // Pull devices
      final devicesData = await _supabase
          .from('user_devices')
          .select()
          .eq('user_id', userId!);

      final devicesBox = await Hive.openBox<UserDevice>('user_devices');

      for (var data in devicesData) {
        final device = UserDevice.fromJson(data);

        // Check if already exists
        final existingIndex = devicesBox.values.toList().indexWhere(
          (d) => d.id == device.id,
        );

        if (existingIndex == -1) {
          // New device, add it
          await devicesBox.add(device);
          debugPrint('✅ Pulled new device: ${device.deviceName}');
        }
      }

      debugPrint('✅ Pull completed!');
    } catch (e) {
      debugPrint('❌ Pull error: $e');
    }
  }

  /// Auto-sync on app start
  Future<void> autoSync() async {
    if (!isAuthenticated) return;

    // Pull first (get latest from cloud)
    await pullFromSupabase();

    // Then push (sync local changes)
    await syncAll();
  }

  /// Delete reading from Supabase
  Future<void> deleteReadingFromSupabase(String readingId) async {
    if (!isAuthenticated) return;

    try {
      await _supabase.from('meter_readings').delete().eq('id', readingId);

      debugPrint('✅ Deleted reading from Supabase: $readingId');
    } catch (e) {
      debugPrint('❌ Failed to delete reading: $e');
    }
  }

  /// Delete device from Supabase
  Future<void> deleteDeviceFromSupabase(String deviceId) async {
    if (!isAuthenticated) return;

    try {
      await _supabase.from('user_devices').delete().eq('id', deviceId);

      debugPrint('✅ Deleted device from Supabase: $deviceId');
    } catch (e) {
      debugPrint('❌ Failed to delete device: $e');
    }
  }
}
