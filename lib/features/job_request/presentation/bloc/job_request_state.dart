part of 'job_request_bloc.dart';

sealed class JobRequestState extends Equatable {
  const JobRequestState();

  @override
  List<Object?> get props => [];
}

final class JobRequestInitial extends JobRequestState {}

final class JobRequestPosting extends JobRequestState {}

final class JobRequestPosted extends JobRequestState {
  final JobRequest job;
  const JobRequestPosted(this.job);

  @override
  List<Object> get props => [job];
}

final class JobRequestWatching extends JobRequestState {
  final JobRequest job;
  final JobRequestStatus status;

  const JobRequestWatching({required this.job, required this.status});

  @override
  List<Object> get props => [job, status];
}

final class JobRequestLoading extends JobRequestState {}

final class JobRequestCancelled extends JobRequestState {}

final class JobRequestCompleted extends JobRequestState {}

final class JobRequestAwaitingPayment extends JobRequestState {}

final class JobRequestAwaitingOfflineConfirmation extends JobRequestState {}

final class JobRequestError extends JobRequestState {
  final String message;
  const JobRequestError(this.message);

  @override
  List<Object> get props => [message];
}

// ── My Jobs ──────────────────────────────────────────────────────────────────

final class MyJobsLoading extends JobRequestState {}

final class MyJobsLoaded extends JobRequestState {
  final List<JobRequest> jobs;
  const MyJobsLoaded(this.jobs);

  @override
  List<Object> get props => [jobs];
}
