import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase/supabase.dart' as supabase;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:finalproject/features/devices/domain/entities/meter_reading.dart';
import 'package:finalproject/features/devices/domain/entities/user_device.dart';
import 'package:finalproject/core/di/injection.dart';
import 'dart:async';

/// Online-First Data Sync Service
/// Priority: Online → Offline Fallback → Auto-Sync
class OnlineFirstSyncService {
  final supabase.SupabaseClient _supabase = sl<supabase.SupabaseClient>();
  final Connectivity _connectivity = Connectivity();

  bool _isSyncing = false;
  static const Duration _timeout = Duration(seconds: 10);
  static const int _maxRetries = 3;

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('⚠️ Connectivity check failed: $e');
      return false;
    }
  }

  /// Get current user ID
  Future<String?> get userId async {
    try {
      final box = await Hive.openBox('auth');
      return box.get('user_id');
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> get isAuthenticated async {
    try {
      final box = await Hive.openBox('auth');
      return box.get('is_authenticated', defaultValue: false);
    } catch (e) {
      return false;
    }
  }

  // ==================== HELPER: RETRY LOGIC ====================

  Future<T> _withRetry<T>(Future<T> Function() action) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        attempts++;
        return await action().timeout(_timeout);
      } catch (e) {
        if (attempts >= _maxRetries) rethrow;
        final delay = Duration(seconds: attempts * 2); // Exponential backoff
        debugPrint(
          '⚠️ Operation failed, retrying in ${delay.inSeconds}s... ($e)',
        );
        await Future.delayed(delay);
      }
    }
    throw Exception('Max retries reached');
  }

  // ==================== METER READINGS ====================

  /// Save meter reading (Online-First)
  Future<bool> saveMeterReading(MeterReading reading) async {
    if (!await isAuthenticated) {
      debugPrint('⚠️ Not authenticated. Saving to Hive only.');
      return await _saveReadingToHive(reading, synced: false);
    }

    final online = await isOnline();

    if (online) {
      try {
        debugPrint('🌐 Online mode: Saving to Supabase...');

        await _withRetry(() async {
          await _saveReadingToSupabase(reading);
        });

        debugPrint('✅ Saved to Supabase');
        await _saveReadingToHive(reading, synced: true);
        return true;
      } catch (e) {
        debugPrint('⚠️ Supabase save failed after retries: $e');
        debugPrint('📵 Falling back to offline mode...');
        return await _saveReadingToHive(reading, synced: false);
      }
    } else {
      debugPrint('📵 Offline mode: Saving to Hive only...');
      return await _saveReadingToHive(reading, synced: false);
    }
  }

  /// Save reading to Supabase
  Future<void> _saveReadingToSupabase(MeterReading reading) async {
    final uid = await userId;
    if (uid == null) throw Exception('No user ID');

    await _supabase.from('meter_readings').insert({
      'id': reading.id,
      'user_id': uid,
      'reading_value': reading.readingValue,
      'reading_date': reading.readingDate.toIso8601String(),
      'consumption_kwh': reading.consumptionKwh,
      'estimated_cost': reading.estimatedCost,
      'created_at': reading.createdAt.toIso8601String(),
    });
  }

  /// Save reading to Hive
  Future<bool> _saveReadingToHive(
    MeterReading reading, {
    required bool synced,
  }) async {
    try {
      final box = await Hive.openBox<MeterReading>('meter_readings');
      reading.isSynced = synced;
      await box.add(reading);
      debugPrint('✅ Saved to Hive (synced: $synced)');
      return true;
    } catch (e) {
      debugPrint('❌ Hive save failed: $e');
      return false;
    }
  }

  /// Delete meter reading (Online-First)
  Future<bool> deleteMeterReading(String readingId) async {
    final online = await isOnline();

    if (online && await isAuthenticated) {
      try {
        await _withRetry(() async {
          await _supabase.from('meter_readings').delete().eq('id', readingId);
        });
        debugPrint('✅ Deleted from Supabase');
      } catch (e) {
        debugPrint('⚠️ Supabase delete failed: $e');
      }
    }

    try {
      final box = await Hive.openBox<MeterReading>('meter_readings');
      final index = box.values.toList().indexWhere((r) => r.id == readingId);
      if (index != -1) {
        await box.deleteAt(index);
        debugPrint('✅ Deleted from Hive');
        return true;
      }
    } catch (e) {
      debugPrint('❌ Hive delete failed: $e');
    }

    return false;
  }

  // ==================== USER DEVICES ====================

  /// Save user device (Online-First)
  Future<bool> saveUserDevice(UserDevice device) async {
    if (!await isAuthenticated) {
      debugPrint('⚠️ Not authenticated. Saving to Hive only.');
      return await _saveDeviceToHive(device, synced: false);
    }

    final online = await isOnline();

    if (online) {
      try {
        debugPrint('🌐 Online mode: Saving device to Supabase...');

        await _withRetry(() async {
          await _saveDeviceToSupabase(device);
        });

        debugPrint('✅ Device saved to Supabase');
        await _saveDeviceToHive(device, synced: true);
        return true;
      } catch (e) {
        debugPrint('⚠️ Supabase save failed: $e');
        return await _saveDeviceToHive(device, synced: false);
      }
    } else {
      debugPrint('📵 Offline mode: Saving device to Hive only...');
      return await _saveDeviceToHive(device, synced: false);
    }
  }

  Future<void> _saveDeviceToSupabase(UserDevice device) async {
    final uid = await userId;
    if (uid == null) throw Exception('No user ID');

    await _supabase.from('user_devices').insert({
      'id': device.id,
      'user_id': uid,
      'device_name': device.deviceName,
      'device_category': device.category,
      'power_watts': device.powerWatts,
      'usage_hours_per_day': device.usageHoursPerDay,
      'created_at': device.createdAt.toIso8601String(),
    });
  }

  Future<bool> _saveDeviceToHive(
    UserDevice device, {
    required bool synced,
  }) async {
    try {
      final box = await Hive.openBox<UserDevice>('user_devices');
      device.isSynced = synced;
      await box.add(device);
      debugPrint('✅ Device saved to Hive (synced: $synced)');
      return true;
    } catch (e) {
      debugPrint('❌ Hive save failed: $e');
      return false;
    }
  }

  // ==================== AUTO-SYNC ====================

  Future<void> autoSync() async {
    if (_isSyncing) return;
    if (!await isAuthenticated || !await isOnline()) return;

    _isSyncing = true;
    debugPrint('🔄 Starting auto-sync...');

    try {
      await _syncMeterReadings();
      await _syncUserDevices();
      debugPrint('✅ Auto-sync completed');
    } catch (e) {
      debugPrint('❌ Auto-sync failed: $e');
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncMeterReadings() async {
    try {
      final box = await Hive.openBox<MeterReading>('meter_readings');
      final unsynced = box.values.where((r) => !r.isSynced).toList();

      if (unsynced.isEmpty) return;

      debugPrint('🔄 Syncing ${unsynced.length} readings...');

      for (var reading in unsynced) {
        try {
          await _withRetry(() async {
            await _saveReadingToSupabase(reading);
          });
          reading.isSynced = true;
          await reading.save();
          debugPrint('✅ Synced reading: ${reading.id}');
        } catch (e) {
          debugPrint('⚠️ Failed to sync reading ${reading.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Sync readings failed: $e');
    }
  }

  Future<void> _syncUserDevices() async {
    try {
      final box = await Hive.openBox<UserDevice>('user_devices');
      final unsynced = box.values.where((d) => !d.isSynced).toList();

      if (unsynced.isEmpty) return;

      debugPrint('🔄 Syncing ${unsynced.length} devices...');

      for (var device in unsynced) {
        try {
          await _withRetry(() async {
            await _saveDeviceToSupabase(device);
          });
          device.isSynced = true;
          await device.save();
          debugPrint('✅ Synced device: ${device.id}');
        } catch (e) {
          debugPrint('⚠️ Failed to sync device ${device.id}: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Sync devices failed: $e');
    }
  }

  /// Pull data from Supabase (for multi-device sync)
  Future<void> pullFromSupabase() async {
    if (!await isAuthenticated || !await isOnline()) return;

    try {
      debugPrint('⬇️ Pulling data from Supabase...');
      final uid = await userId;
      if (uid == null) return;

      final readings = await _withRetry(() async {
        return await _supabase
            .from('meter_readings')
            .select()
            .eq('user_id', uid)
            .order('reading_date', ascending: false);
      });

      final readingsBox = await Hive.openBox<MeterReading>('meter_readings');
      await readingsBox.clear();

      for (var data in readings) {
        final reading = MeterReading(
          id: data['id'],
          readingValue: data['reading_value'].toDouble(),
          readingDate: DateTime.parse(data['reading_date']),
          consumptionKwh: data['consumption_kwh']?.toDouble(),
          estimatedCost: data['estimated_cost']?.toDouble(),
          createdAt: DateTime.parse(data['created_at']),
        );
        reading.isSynced = true;
        await readingsBox.add(reading);
      }

      debugPrint('✅ Pulled ${readings.length} readings');
    } catch (e) {
      debugPrint('❌ Pull failed: $e');
    }
  }
}
