import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/category_entity.dart';
import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../../home/domain/usecase/get_categories_usecase.dart';
import '../../../home/domain/usecase/get_service_providers_usecase.dart';

part 'service_provider_event.dart';
part 'service_provider_state.dart';

class ServiceProviderBloc
    extends Bloc<ServiceProviderEvent, ServiceProviderState> {
  final GetServiceProvidersUseCase _getServiceProviders;
  final GetCategoriesUseCase _getCategories;
  final String initialQuery;
  final String? initialCategory;

  ServiceProviderBloc(
    this._getServiceProviders,
    this._getCategories, {
    this.initialQuery = '',
    this.initialCategory,
  }) : super(ServiceProviderInitial()) {
    on<ServiceProviderFetchRequested>(_onFetchRequested);
    on<ServiceProviderSearchChanged>(_onSearchChanged);
    on<ServiceProviderCategorySelected>(_onCategorySelected);
  }

  Future<void> _onFetchRequested(
    ServiceProviderFetchRequested event,
    Emitter<ServiceProviderState> emit,
  ) async {
    emit(ServiceProviderLoading());
    try {
      final results = await Future.wait([
        _getServiceProviders(limit: 100),
        _getCategories(),
      ]);
      final providers = results[0] as List<ServiceProviderEntity>;
      final categoryNames = (results[1] as List<CategoryEntity>)
          .map((c) => c.name)
          .toList();
      final filtered =
          _filter(providers, query: initialQuery, category: initialCategory);
      emit(ServiceProviderLoaded(
        allProviders: providers,
        filteredProviders: filtered,
        categories: categoryNames,
        selectedCategory: initialCategory,
        searchQuery: initialQuery,
      ));
    } catch (e) {
      emit(ServiceProviderError(e.toString()));
    }
  }

  void _onSearchChanged(
    ServiceProviderSearchChanged event,
    Emitter<ServiceProviderState> emit,
  ) {
    if (state is! ServiceProviderLoaded) return;
    final current = state as ServiceProviderLoaded;
    emit(current.copyWith(
      filteredProviders: _filter(current.allProviders,
          query: event.query, category: current.selectedCategory),
      searchQuery: event.query,
    ));
  }

  void _onCategorySelected(
    ServiceProviderCategorySelected event,
    Emitter<ServiceProviderState> emit,
  ) {
    if (state is! ServiceProviderLoaded) return;
    final current = state as ServiceProviderLoaded;
    emit(current.copyWith(
      filteredProviders: _filter(current.allProviders,
          query: current.searchQuery, category: event.category),
      selectedCategory: event.category,
    ));
  }

  List<ServiceProviderEntity> _filter(
    List<ServiceProviderEntity> all, {
    required String query,
    required String? category,
  }) {
    return all.where((p) {
      final q = query.toLowerCase();
      final matchesQuery = q.isEmpty ||
          p.fullName.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.skills.any((s) => s.toLowerCase().contains(q));
      final matchesCategory = category == null || p.category == category;
      return matchesQuery && matchesCategory;
    }).toList();
  }
}
