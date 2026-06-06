part of 'service_provider_bloc.dart';

sealed class ServiceProviderState extends Equatable {
  const ServiceProviderState();

  @override
  List<Object?> get props => [];
}

final class ServiceProviderInitial extends ServiceProviderState {}

final class ServiceProviderLoading extends ServiceProviderState {}

final class ServiceProviderLoaded extends ServiceProviderState {
  final List<ServiceProviderEntity> allProviders;
  final List<ServiceProviderEntity> filteredProviders;
  final String? selectedCategory;
  final String searchQuery;

  const ServiceProviderLoaded({
    required this.allProviders,
    required this.filteredProviders,
    this.selectedCategory,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props =>
      [allProviders, filteredProviders, selectedCategory, searchQuery];

  static const _sentinel = Object();

  ServiceProviderLoaded copyWith({
    List<ServiceProviderEntity>? allProviders,
    List<ServiceProviderEntity>? filteredProviders,
    Object? selectedCategory = _sentinel,
    String? searchQuery,
  }) {
    return ServiceProviderLoaded(
      allProviders: allProviders ?? this.allProviders,
      filteredProviders: filteredProviders ?? this.filteredProviders,
      selectedCategory: selectedCategory == _sentinel
          ? this.selectedCategory
          : selectedCategory as String?,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final class ServiceProviderError extends ServiceProviderState {
  final String message;
  const ServiceProviderError(this.message);

  @override
  List<Object?> get props => [message];
}
