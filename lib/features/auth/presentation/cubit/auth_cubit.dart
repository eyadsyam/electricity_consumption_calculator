import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:supabase/supabase.dart' as supabase;
import 'package:finalproject/core/di/injection.dart';
import 'package:finalproject/features/auth/domain/entities/user.dart';
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
        final userName = box.get('user_name', defaultValue: 'User');
        emit(
          AuthAuthenticated(
            UserEntity(id: email, email: email, name: userName),
          ),
        );
      } else {
        emit(AuthError('Invalid email or password'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> signUp(String email, String password, [String? name]) async {
    emit(AuthLoading());
    try {
      final userName = name ?? 'User';

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

          debugPrint('✅ User saved to Supabase: ${response.user!.id}');
        }
      } catch (e) {
        debugPrint('⚠️ Supabase signup failed: $e');
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
      final userName = userData['name'] ?? 'User';
      final email = userData['email'] ?? '';

      emit(
        AuthAuthenticated(
          UserEntity(id: userData['id'], email: email, name: userName),
        ),
      );

      debugPrint('✅ Google Sign-In successful: $email');
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
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
      final userName = box.get('user_name', defaultValue: 'User');

      if (isAuth && email != null) {
        emit(
          AuthAuthenticated(
            UserEntity(id: email, email: email, name: userName),
          ),
        );
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
