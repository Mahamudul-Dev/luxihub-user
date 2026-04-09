part of 'home_bloc.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

final class HomeProvidersRequested extends HomeEvent {
  const HomeProvidersRequested();
}
