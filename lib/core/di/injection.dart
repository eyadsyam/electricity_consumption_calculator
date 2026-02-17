import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:finalproject/features/auth/presentation/cubit/auth_cubit.dart';

import 'package:finalproject/features/devices/presentation/cubit/device_cubit.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // External - Supabase Client
  // ⚠️ IMPORTANT: Replace these with YOUR Supabase credentials
  // Get them from: https://supabase.com/dashboard → Your Project → Settings → API
  // External - Supabase Client
  final supabase = Supabase.instance.client;
  sl.registerLazySingleton(() => supabase);

  // Services

  // Cubits
  sl.registerFactory(() => AuthCubit());

  sl.registerFactory(() => DeviceCubit());
}
