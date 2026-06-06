import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendPhoneOtp(String phone);
  Future<AuthResponse> verifyPhoneOtp({required String phone, required String token});
  Future<AuthResponse> signInWithEmail({required String email, required String password});
  Future<AuthResponse> signUpWithEmail({required String email, required String password, required String name, required String phone});
  Future<void> resendConfirmationEmail(String email);
  Future<void> signOut();
  User? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;
  AuthRemoteDataSourceImpl(this._client);

  Future<void> _ensureProfileExists(User user, {String? name, String? phone}) async {
    await _client.from('profiles').upsert(
      {
        'id': user.id,
        'name': name ?? user.email ?? user.phone ?? '',
        'email': user.email,
        'phone': phone ?? user.phone,
        'user_type': 'client',
      },
      onConflict: 'id',
      ignoreDuplicates: true,
    );
  }

  @override
  Future<void> sendPhoneOtp(String phone) async {
    try {
      await _client.auth.signInWithOtp(phone: phone);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (_) {
      throw const ServerException('Failed to send OTP.');
    }
  }

  @override
  Future<AuthResponse> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: token,
      );
      if (response.user == null) throw const ServerException('Verification failed.');
      await _ensureProfileExists(response.user!);
      return response;
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException('OTP verification failed.');
    }
  }

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) throw const ServerException('Login failed.');
      await _ensureProfileExists(response.user!);
      return response;
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException('Login failed.');
    }
  }

  @override
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone},
      );
      if (response.user == null) throw const ServerException('Sign up failed.');
      // Works when email auto-confirm is ON (dev/staging). When confirmation is
      // required the session is unconfirmed and this throws — the DB trigger
      // handles profile creation from the metadata in that case.
      try {
        await _ensureProfileExists(response.user!, name: name, phone: phone);
      } catch (_) {}
      return response;
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException('Sign up failed.');
    }
  }

  @override
  Future<void> resendConfirmationEmail(String email) async {
    try {
      await _client.auth.resend(type: OtpType.signup, email: email);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw const ServerException('Failed to resend confirmation email.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(e.message);
    }
  }

  @override
  User? getCurrentUser() => _client.auth.currentUser;
}
