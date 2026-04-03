part of 'onboarding_bloc.dart';

sealed class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object> get props => [];
}

final class OnboardingProgress extends OnboardingState {
  final int currentPage;
  final int totalPages;

  const OnboardingProgress({
    required this.currentPage,
    required this.totalPages,
  });

  bool get isLastPage => currentPage == totalPages - 1;

  @override
  List<Object> get props => [currentPage, totalPages];
}

final class OnboardingCompleted extends OnboardingState {}
