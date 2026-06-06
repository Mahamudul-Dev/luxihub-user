part of 'home_bloc.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  final List<ServiceProviderEntity> providers;
  final List<CategoryEntity> categories;

  const HomeLoaded({required this.providers, required this.categories});

  @override
  List<Object> get props => [providers, categories];
}

final class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
