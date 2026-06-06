part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading();
}

final class AuthOtpSent extends AuthState {
  final String phone;
  const AuthOtpSent(this.phone);

  @override
  List<Object?> get props => [phone];
}

final class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

final class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

final class AuthConfirmationEmailSent extends AuthState {
  const AuthConfirmationEmailSent();
}
