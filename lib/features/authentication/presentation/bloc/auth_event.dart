part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

final class SignupSubmitted extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String password;
  final bool tocAccepted;

  const SignupSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
    required this.tocAccepted,
  });

  @override
  List<Object> get props => [firstName, lastName, email, phone, address, password, tocAccepted];
}

final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
