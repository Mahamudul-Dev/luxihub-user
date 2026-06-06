part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

final class SendPhoneOtpRequested extends AuthEvent {
  final String phone;
  const SendPhoneOtpRequested(this.phone);

  @override
  List<Object> get props => [phone];
}

final class VerifyPhoneOtpRequested extends AuthEvent {
  final String phone;
  final String token;
  const VerifyPhoneOtpRequested({required this.phone, required this.token});

  @override
  List<Object> get props => [phone, token];
}

final class SignInWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  const SignInWithEmailRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

final class SignUpWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  final String phone;
  const SignUpWithEmailRequested({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
  });

  @override
  List<Object> get props => [email, password, name, phone];
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class ResendConfirmationRequested extends AuthEvent {
  final String email;
  const ResendConfirmationRequested(this.email);

  @override
  List<Object> get props => [email];
}

// Internal — dispatched by the Supabase auth stream, never by the UI.
final class _SupabaseSessionChanged extends AuthEvent {
  final String? userId;
  final String? email;
  final String? phone;
  final bool isSignedIn;
  const _SupabaseSessionChanged({
    required this.isSignedIn,
    this.userId,
    this.email,
    this.phone,
  });
}
