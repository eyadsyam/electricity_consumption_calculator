import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase/supabase.dart' as supabase;
import 'package:hive/hive.dart';
import 'package:finalproject/core/di/injection.dart';

/// Enhanced Google Authentication Service
/// - Forces account selection on every sign-in
/// - Saves complete user data (name, photo, email)
/// - Implements Offline-First with Supabase backup
class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '881449884773-vh9oilil4693l3nof8hphvg25aqt3t40.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  final supabase.SupabaseClient _supabase = sl<supabase.SupabaseClient>();

  /// Sign in with Google
  /// Forces account selection every time
  /// Returns complete user data including name and photo
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      debugPrint('🔐 Starting Google Sign-In...');

      // IMPORTANT: Sign out first to force account picker
      await _googleSignIn.signOut();
      debugPrint('✅ Signed out to force account selection');

      // 1. Trigger Google Sign-In flow (will show account picker)
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('⚠️ User cancelled Google Sign-In');
        return null;
      }

      debugPrint('✅ Google user: ${googleUser.email}');
      debugPrint('✅ Display name: ${googleUser.displayName}');
      debugPrint('✅ Photo URL: ${googleUser.photoUrl}');

      // 2. Get authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.idToken == null) {
        debugPrint('❌ No ID token received');
        return null;
      }

      debugPrint('✅ Got Google auth tokens');

      // Prepare complete user data
      final userData = {
        'id': googleUser.id,
        'email': googleUser.email,
        'name': googleUser.displayName ?? googleUser.email.split('@')[0],
        'photo': googleUser.photoUrl,
      };

      // 3. Try Supabase auth (Online-First)
      try {
        final response = await _supabase.auth.signInWithIdToken(
          provider: supabase.OAuthProvider.google,
          idToken: googleAuth.idToken!,
          accessToken: googleAuth.accessToken,
        );

        if (response.user != null) {
          debugPrint('✅ Supabase auth successful: ${response.user!.id}');

          // Update user data with Supabase ID
          userData['id'] = response.user!.id;

          // 4. Save user data to public.users table
          await _saveUserToDatabase(response.user!, userData);

          // 5. Save to Hive (offline backup) with complete data
          await _saveToHive(userData);

          return userData;
        }
      } catch (e) {
        debugPrint('⚠️ Supabase auth failed: $e');
        // Continue with offline mode
      }

      // Offline fallback: Save to Hive only with complete data
      await _saveToHiveOffline(userData);
      return userData;
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      if (e.toString().contains('7') ||
          e.toString().contains('network_error')) {
        debugPrint(
          '🌐 NETWORK ERROR: Please check your internet connection or SHA-1 configuration.',
        );
      }
      return null;
    }
  }

  /// Save user to Supabase database with complete data
  Future<void> _saveUserToDatabase(
    supabase.User user,
    Map<String, dynamic> userData,
  ) async {
    try {
      await _supabase.from('users').upsert({
        'id': user.id,
        'email': userData['email'],
        'full_name': userData['name'],
        'avatar_url': userData['photo'],
        'updated_at': DateTime.now().toIso8601String(),
      });
      debugPrint('✅ User saved to database with complete data');
    } catch (e) {
      debugPrint('⚠️ Failed to save user to database: $e');
    }
  }

  /// Save complete user data to Hive (offline backup)
  Future<void> _saveToHive(Map<String, dynamic> userData) async {
    try {
      final box = await Hive.openBox('auth');
      await box.put('user_id', userData['id']);
      await box.put('email', userData['email']);
      await box.put(
        'user_name',
        userData['name'],
      ); // Changed from 'name' to 'user_name'
      await box.put('photo', userData['photo']);
      await box.put('is_authenticated', true);
      await box.put('auth_provider', 'google');
      debugPrint('✅ Complete user data saved to Hive');
      debugPrint('   - Name: ${userData['name']}');
      debugPrint('   - Photo: ${userData['photo']}');
    } catch (e) {
      debugPrint('⚠️ Failed to save to Hive: $e');
    }
  }

  /// Save user to Hive (offline only) with complete data
  Future<void> _saveToHiveOffline(Map<String, dynamic> userData) async {
    try {
      final box = await Hive.openBox('auth');
      await box.put('user_id', userData['id']);
      await box.put('email', userData['email']);
      await box.put(
        'user_name',
        userData['name'],
      ); // Changed from 'name' to 'user_name'
      await box.put('photo', userData['photo']);
      await box.put('is_authenticated', true);
      await box.put('auth_provider', 'google');
      await box.put('offline_mode', true);
      debugPrint('✅ Complete user data saved to Hive (offline mode)');
      debugPrint('   - Name: ${userData['name']}');
      debugPrint('   - Photo: ${userData['photo']}');
    } catch (e) {
      debugPrint('⚠️ Failed to save to Hive: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      // 1. Sign out from Google
      await _googleSignIn.signOut();

      // 2. Sign out from Supabase
      await _supabase.auth.signOut();

      // 3. Clear Hive
      final box = await Hive.openBox('auth');
      await box.clear();

      debugPrint('✅ Signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
    }
  }

  /// Check if user is signed in
  Future<bool> isSignedIn() async {
    try {
      final box = await Hive.openBox('auth');
      return box.get('is_authenticated', defaultValue: false);
    } catch (e) {
      return false;
    }
  }

  /// Get current user from Hive with complete data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final box = await Hive.openBox('auth');
      if (box.get('is_authenticated', defaultValue: false)) {
        return {
          'id': box.get('user_id'),
          'email': box.get('email'),
          'name': box.get('user_name', defaultValue: 'User'),
          'photo': box.get('photo'),
        };
      }
    } catch (e) {
      debugPrint('❌ Error getting current user: $e');
    }
    return null;
  }
}
