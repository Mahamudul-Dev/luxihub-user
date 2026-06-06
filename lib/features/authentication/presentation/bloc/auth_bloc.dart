import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../../core/domain/entities/auth_user.dart';
import '../../../../core/services/fcm_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_phone_otp.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up_with_email.dart';
import '../../domain/usecases/verify_phone_otp.dart';
import '../../../../core/usecases/usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;
  final SendPhoneOtp _sendPhoneOtp;
  final VerifyPhoneOtp _verifyPhoneOtp;
  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignOut _signOut;
  StreamSubscription<supa.AuthState>? _supaSubscription;

  AuthBloc({
    required AuthRepository repository,
    required SendPhoneOtp sendPhoneOtp,
    required VerifyPhoneOtp verifyPhoneOtp,
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignOut signOut,
  })  : _repository = repository,
        _sendPhoneOtp = sendPhoneOtp,
        _verifyPhoneOtp = verifyPhoneOtp,
        _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signOut = signOut,
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<_SupabaseSessionChanged>(_onSupabaseSessionChanged);
    on<SendPhoneOtpRequested>(_onSendPhoneOtpRequested);
    on<VerifyPhoneOtpRequested>(_onVerifyPhoneOtpRequested);
    on<SignInWithEmailRequested>(_onSignInWithEmailRequested);
    on<SignUpWithEmailRequested>(_onSignUpWithEmailRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<ResendConfirmationRequested>(_onResendConfirmationRequested);

    // Supabase's onAuthStateChange is the authoritative source for session state.
    // It fires `initialSession` once the SDK has restored (or confirmed absence of)
    // a persisted session — more reliable than the synchronous currentUser getter.
    _supaSubscription = supa.Supabase.instance.client.auth.onAuthStateChange
        .listen((data) {
      final session = data.session;
      final evt = data.event;

      if (evt == supa.AuthChangeEvent.signedOut) {
        add(const _SupabaseSessionChanged(isSignedIn: false));
      } else if (session != null) {
        add(_SupabaseSessionChanged(
          isSignedIn: true,
          userId: session.user.id,
          email: session.user.email,
          phone: session.user.phone,
        ));
      } else if (evt == supa.AuthChangeEvent.initialSession) {
        // initialSession fired with null session = no stored session
        add(const _SupabaseSessionChanged(isSignedIn: false));
      }
    });
  }

  @override
  Future<void> close() {
    _supaSubscription?.cancel();
    return super.close();
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) {
    // Kept as a fast synchronous fallback. The stream subscription above is the
    // primary mechanism; this just gives an immediate best-effort state.
    final user = _repository.getCurrentUser();
    if (user != null) emit(AuthAuthenticated(user));
  }

  void _onSupabaseSessionChanged(
    _SupabaseSessionChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.isSignedIn) {
      emit(AuthAuthenticated(AppUser(
        id: event.userId!,
        email: event.email,
        phone: event.phone,
      )));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSendPhoneOtpRequested(
    SendPhoneOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _sendPhoneOtp(event.phone);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(AuthOtpSent(event.phone)),
    );
  }

  Future<void> _onVerifyPhoneOtpRequested(
    VerifyPhoneOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _verifyPhoneOtp(
      VerifyPhoneOtpParams(phone: event.phone, token: event.token),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignInWithEmailRequested(
    SignInWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signInWithEmail(
      SignInWithEmailParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignUpWithEmailRequested(
    SignUpWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _signUpWithEmail(
      SignUpWithEmailParams(
        email: event.email,
        password: event.password,
        name: event.name,
        phone: event.phone,
      ),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      await FcmService.instance.removeToken(currentState.user.id);
    }
    await _signOut(const NoParams());
    emit(const AuthUnauthenticated());
  }

  Future<void> _onResendConfirmationRequested(
    ResendConfirmationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _repository.resendConfirmationEmail(event.email);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthConfirmationEmailSent()),
    );
  }
}
