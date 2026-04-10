part of 'job_request_bloc.dart';

sealed class JobRequestState extends Equatable {
  const JobRequestState();

  @override
  List<Object> get props => [];
}

final class JobRequestInitial extends JobRequestState {}

final class JobRequestStatusUpdated extends JobRequestState {
  const JobRequestStatusUpdated(this.status);

  final JobRequestStatus status;

  @override
  List<Object> get props => [status];
}
