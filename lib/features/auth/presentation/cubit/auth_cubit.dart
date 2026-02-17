import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:supabase/supabase.dart' as supabase;
import 'package:finalproject/core/di/injection.dart';
import 'package:finalproject/features/auth/domain/entities/user.dart';
import 'package:finalproject/services/central_sync_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    try {
      final box = await Hive.openBox('auth');
      final savedEmail = box.get('email');
      final savedPassword = box.get('password');

      if (savedEmail == email && savedPassword == password) {
        // Use name as saved, do not convert
        var userName = box.get('user_name', defaultValue: 'المستخدم');

        emit(
          AuthAuthenticated(
            UserEntity(
              id: email,
              email: email,
              name: userName,
              photo: box.get('photo_url'),
            ),
          ),
        );
      } else {
        emit(AuthError('البريد الإلكتروني أو كلمة المرور غير صحيحة'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String email, String password, [String? name]) async {
    emit(AuthLoading());
    try {
      final userName = name ?? 'المستخدم';

      // Save to Hive (local)
      final box = await Hive.openBox('auth');
      await box.put('email', email);
      await box.put('password', password);
      await box.put('user_name', userName);
      await box.put('is_authenticated', true);

      // Save to Supabase (cloud)
      try {
        final supabaseClient = sl<supabase.SupabaseClient>();

        // Sign up with Supabase Auth
        final response = await supabaseClient.auth.signUp(
          email: email,
          password: password,
        );

        if (response.user != null) {
          // Insert user data into public.users table
          await supabaseClient.from('users').insert({
            'id': response.user!.id,
            'email': email,
            'full_name': userName,
            'created_at': DateTime.now().toIso8601String(),
          });

          debugPrint('User saved to Supabase: ${response.user!.id}');
        }
      } catch (e) {
        debugPrint('Supabase signup failed: $e');
        // Continue anyway - user is saved locally
      }

      emit(
        AuthAuthenticated(UserEntity(id: email, email: email, name: userName)),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle(Map<String, dynamic> userData) async {
    emit(AuthLoading());
    try {
      // User data is already saved to Hive by GoogleAuthService
      final userName = userData['name'] ?? 'المستخدم';
      final email = userData['email'] ?? '';

      // Explicitly save to Hive to ensure HomeScreen updates
      final box = await Hive.openBox('auth');
      await box.put('user_name', userName);
      await box.put('email', email);
      await box.put('is_authenticated', true);

      final photoUrl = userData['photo'];
      if (photoUrl != null) {
        await box.put('photo_url', photoUrl);
      }

      // Save UUID for Sync
      final supabaseClient = sl<supabase.SupabaseClient>();
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        await box.put('user_id', userId);
      }

      emit(
        AuthAuthenticated(
          UserEntity(
            id: userData['id'],
            email: email,
            name: userName,
            photo: photoUrl,
          ),
        ),
      );

      // Trigger sync safely without crashing Auth flow
      CentralSyncService().syncAll().catchError((e) {
        debugPrint('Sync Warning: $e');
      });

      debugPrint('Google Sign-In successful: $email');
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signOut() async {
    final box = await Hive.openBox('auth');
    await box.put('is_authenticated', false);
    emit(AuthUnauthenticated());
  }

  Future<void> checkAuth() async {
    try {
      final box = await Hive.openBox('auth');
      final isAuth = box.get('is_authenticated', defaultValue: false);
      final email = box.get('email');
      final userName = box.get('user_name', defaultValue: 'المستخدم');

      if (isAuth && email != null) {
        emit(
          AuthAuthenticated(
            UserEntity(
              id: email,
              email: email,
              name: userName,
              photo: box.get('photo_url'),
            ),
          ),
        );
        CentralSyncService().syncAll();
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
