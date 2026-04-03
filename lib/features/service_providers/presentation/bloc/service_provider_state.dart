part of 'service_provider_bloc.dart';

sealed class ServiceProviderState extends Equatable {
  const ServiceProviderState();
  
  @override
  List<Object> get props => [];
}

final class ServiceProviderInitial extends ServiceProviderState {}
