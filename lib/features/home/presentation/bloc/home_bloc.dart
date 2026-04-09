import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../domain/usecase/get_service_providers_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetServiceProvidersUseCase _getServiceProviders;

  HomeBloc(this._getServiceProviders) : super(const HomeInitial()) {
    on<HomeProvidersRequested>(_onProvidersRequested);
  }

  Future<void> _onProvidersRequested(
    HomeProvidersRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final providers = await _getServiceProviders(limit: 10);
      emit(HomeLoaded(providers));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
