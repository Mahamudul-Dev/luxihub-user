part of 'job_request_bloc.dart';

sealed class JobRequestEvent extends Equatable {
  const JobRequestEvent();

  @override
  List<Object> get props => [];
}

/// Fired when the job request details page is opened — starts the status poll.
final class JobRequestStarted extends JobRequestEvent {
  const JobRequestStarted();
}
