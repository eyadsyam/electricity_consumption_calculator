import 'package:get_it/get_it.dart';
import 'package:supabase/supabase.dart';
import 'package:finalproject/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:finalproject/features/notifications/presentation/cubit/notification_cubit.dart';
import 'package:finalproject/features/devices/presentation/cubit/device_cubit.dart';
import 'package:finalproject/services/notification_service.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // External - Supabase Client
  // ⚠️ IMPORTANT: Replace these with YOUR Supabase credentials
  // Get them from: https://supabase.com/dashboard → Your Project → Settings → API
  final supabase = SupabaseClient(
    'https://bmchbrtqsqmrlzthjdod.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJtY2hicnRxc3Ftcmx6dGhqZG9kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzAyMzQyNjIsImV4cCI6MjA4NTgxMDI2Mn0.RuDnSoGFkf2oK1brpcF50xCaKORbg7xdwd1BLmx1FlA',
  );
  sl.registerLazySingleton(() => supabase);

  // Services
  sl.registerLazySingleton(() => NotificationService());

  // Cubits
  sl.registerFactory(() => AuthCubit());
  sl.registerFactory(() => NotificationCubit());
  sl.registerFactory(() => DeviceCubit());
}
