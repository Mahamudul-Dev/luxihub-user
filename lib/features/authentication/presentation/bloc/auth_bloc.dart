import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/data/models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Simulates a network call — replace with real repo call later.
  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // fake latency

    // TODO: replace with real auth call
    if (event.email.isEmpty || event.password.isEmpty) {
      emit(const AuthFailure('Email and password are required.'));
      return;
    }

    // Fake successful login — only email is known from credentials
    final user = UserModel(
      id: 'test-uid-001',
      firstName: '',
      lastName: '',
      email: event.email,
      phone: '',
      address: '',
      profileImageUrl: '',
      bio: '',
      city: '',
      country: '',
      tocAccepted: true,
    );

    emit(AuthAuthenticated(user));
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await Future.delayed(const Duration(seconds: 1)); // fake latency

    // TODO: replace with real auth call
    if (!event.tocAccepted) {
      emit(const AuthFailure('You must accept the terms and conditions.'));
      return;
    }

    final user = UserModel(
      id: 'test-uid-${DateTime.now().millisecondsSinceEpoch}',
      firstName: event.firstName,
      lastName: event.lastName,
      email: event.email,
      phone: event.phone,
      address: event.address,
      profileImageUrl: '',
      bio: '',
      city: '',
      country: '',
      tocAccepted: event.tocAccepted,
    );

    emit(AuthAuthenticated(user));
  }

  void _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) {
    emit(const AuthInitial());
  }
}
