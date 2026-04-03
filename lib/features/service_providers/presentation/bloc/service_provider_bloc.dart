import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'service_provider_event.dart';
part 'service_provider_state.dart';

class ServiceProviderBloc extends Bloc<ServiceProviderEvent, ServiceProviderState> {
  ServiceProviderBloc() : super(ServiceProviderInitial()) {
    on<ServiceProviderEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
