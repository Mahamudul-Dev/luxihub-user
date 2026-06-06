part of 'service_provider_bloc.dart';

sealed class ServiceProviderEvent extends Equatable {
  const ServiceProviderEvent();

  @override
  List<Object?> get props => [];
}

final class ServiceProviderFetchRequested extends ServiceProviderEvent {
  const ServiceProviderFetchRequested();
}

final class ServiceProviderSearchChanged extends ServiceProviderEvent {
  final String query;
  const ServiceProviderSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

final class ServiceProviderCategorySelected extends ServiceProviderEvent {
  final String? category;
  const ServiceProviderCategorySelected(this.category);

  @override
  List<Object?> get props => [category];
}
