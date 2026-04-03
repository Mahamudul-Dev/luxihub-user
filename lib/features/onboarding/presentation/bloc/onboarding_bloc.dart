import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  static const int _totalPages = 3;

  OnboardingBloc()
      : super(const OnboardingProgress(currentPage: 0, totalPages: _totalPages)) {
    on<OnboardingPageChanged>(_onPageChanged);
    on<OnboardingNextPressed>(_onNextPressed);
    on<OnboardingSkipped>(_onSkipped);
  }

  void _onPageChanged(
    OnboardingPageChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingProgress(currentPage: event.page, totalPages: _totalPages));
  }

  void _onNextPressed(
    OnboardingNextPressed event,
    Emitter<OnboardingState> emit,
  ) {
    if (state is! OnboardingProgress) return;
    final current = state as OnboardingProgress;
    if (current.isLastPage) {
      emit(OnboardingCompleted());
    } else {
      emit(OnboardingProgress(
        currentPage: current.currentPage + 1,
        totalPages: _totalPages,
      ));
    }
  }

  void _onSkipped(
    OnboardingSkipped event,
    Emitter<OnboardingState> emit,
  ) {
    emit(OnboardingCompleted());
  }
}
