import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/category_entity.dart';
import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../domain/usecase/get_categories_usecase.dart';
import '../../domain/usecase/get_service_providers_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetServiceProvidersUseCase _getServiceProviders;
  final GetCategoriesUseCase _getCategories;

  HomeBloc(this._getServiceProviders, this._getCategories)
      : super(const HomeInitial()) {
    on<HomeProvidersRequested>(_onProvidersRequested);
  }

  Future<void> _onProvidersRequested(
    HomeProvidersRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final results = await Future.wait([
        _getServiceProviders(limit: 10),
        _getCategories(),
      ]);

      emit(HomeLoaded(
        providers: results[0] as List<ServiceProviderEntity>,
        categories: results[1] as List<CategoryEntity>,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
