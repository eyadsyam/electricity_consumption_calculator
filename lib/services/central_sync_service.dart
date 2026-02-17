import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:finalproject/features/devices/domain/entities/user_device.dart';
import 'package:finalproject/features/electricity_tracking/domain/entities/meter_reading.dart';
import 'package:finalproject/features/electricity_tracking/domain/entities/budget_config.dart';

class CentralSyncService {
  static final CentralSyncService _instance = CentralSyncService._internal();
  factory CentralSyncService() => _instance;
  CentralSyncService._internal();

  final _supabase = Supabase.instance.client;

  Future<void> syncAll() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('Sync skipped: No user logged in');
        return;
      }

      debugPrint('🔄 Starting Full Sync for User: ${user.id}');

      await _syncDevices(user.id);
      await _syncReadings(user.id);
      await _syncBudget(user.id);

      debugPrint('✅ Full Sync Completed Successfully');
    } catch (e) {
      debugPrint('❌ Sync Failed: $e');
    }
  }

  // --- Devices Sync ---
  Future<void> _syncDevices(String userId) async {
    final box = Hive.box<UserDevice>('user_devices');

    // 1. PULL from Server
    try {
      final response = await _supabase
          .from('user_devices')
          .select()
          .eq('user_id', userId);

      final List<dynamic> data = response as List<dynamic>;

      for (var record in data) {
        // Map Server Record to Local Entity
        final serverDevice = UserDevice.fromJson(record);

        // Save to Hive (Overwrite or Add)
        // Ensure we mark it as synced
        await box.put(serverDevice.id, serverDevice);
      }
    } catch (e) {
      debugPrint('Error pulling devices: $e');
    }

    // 2. PUSH to Server
    final unsynced = box.values.where(
      (d) => !d.isSynced && (d.userId == userId || d.userId == null),
    );

    for (var device in unsynced) {
      // Assign userId if missing (created offline)
      if (device.userId == null) {
        device.userId = userId;
        await device.save();
      }

      final json = device.toJson();
      // Remove local-only fields if any (fromJson handles ignoring them, but toJson sends them)
      // JSON keys should match SQL columns exactly.

      try {
        await _supabase.from('user_devices').upsert(json);

        // Mark as synced
        device.isSynced = true;
        await device.save();
      } catch (e) {
        debugPrint('Error pushing device ${device.id}: $e');
      }
    }
  }

  // --- Readings Sync ---
  Future<void> _syncReadings(String userId) async {
    final box = Hive.box<MeterReading>('meter_readings');

    // 1. PULL
    try {
      final response = await _supabase
          .from('meter_readings')
          .select()
          .eq('user_id', userId);

      final List<dynamic> data = response as List<dynamic>;

      for (var record in data) {
        final serverReading = MeterReading.fromJson(record);
        await box.put(serverReading.id, serverReading);
      }
    } catch (e) {
      debugPrint('Error pulling readings: $e');
    }

    // 2. PUSH
    final unsynced = box.values.where(
      (r) => !r.isSynced && (r.userId == userId || r.userId.isEmpty),
    );

    for (var reading in unsynced) {
      if (reading.userId.isEmpty) {
        // Create new copy with userId because fields are final
        final updatedReading = reading.copyWith(userId: userId);
        await box.put(reading.id, updatedReading);
        // Use the updated one for pushing
        // Actually, we need to re-fetch or use updated object logic
      }

      // Since reading fields are final, we can't just set userId.
      // But creating offline usually implies we know the user?
      // If user logs out and works offline, we might not have userId.
      // Assuming userId is passed during creation or updated here properly.

      // Let's assume the entity has the ID or we updated it.
      // Re-read from box to be safe if we just updated it.
      final currentReading = box.get(reading.id)!;

      if (currentReading.userId.isEmpty) {
        // Update missing userId
        final updated = currentReading.copyWith(userId: userId);
        await box.put(currentReading.id, updated);
      }

      final cleanRead = box.get(reading.id)!;

      try {
        await _supabase.from('meter_readings').upsert(cleanRead.toJson());

        final synced = cleanRead.copyWith(isSynced: true);
        await box.put(cleanRead.id, synced);
      } catch (e) {
        debugPrint('Error pushing reading ${reading.id}: $e');
      }
    }
  }

  // --- Budget Sync ---
  Future<void> _syncBudget(String userId) async {
    final box = Hive.box<BudgetConfig>('budget_configs');

    // 1. PULL
    try {
      final response = await _supabase
          .from('budget_configs')
          .select()
          .eq('user_id', userId);

      final List<dynamic> data = response as List<dynamic>;

      for (var record in data) {
        final serverBudget = BudgetConfig.fromJson(record);
        await box.put(serverBudget.id, serverBudget);
      }
    } catch (e) {
      debugPrint('Error pulling budget: $e');
    }

    // 2. PUSH
    final unsynced = box.values.where(
      (b) => !b.isSynced && (b.userId == userId || b.userId == null),
    );

    for (var budget in unsynced) {
      if (budget.userId == null) {
        budget.userId = userId;
        await budget.save();
      }

      try {
        await _supabase.from('budget_configs').upsert(budget.toJson());

        budget.isSynced = true;
        await budget.save();
      } catch (e) {
        debugPrint('Error pushing budget ${budget.id}: $e');
      }
    }
  }
}
