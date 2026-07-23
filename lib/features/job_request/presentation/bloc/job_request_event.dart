part of 'job_request_bloc.dart';

sealed class JobRequestEvent extends Equatable {
  const JobRequestEvent();

  @override
  List<Object?> get props => [];
}

final class JobPostRequested extends JobRequestEvent {
  final String providerId;
  final String category;
  final String description;
  final double clientLat;
  final double clientLng;
  final double? offerPrice;
  final List<dynamic> attachments;

  const JobPostRequested({
    required this.providerId,
    required this.category,
    required this.description,
    this.clientLat = 0.0,
    this.clientLng = 0.0,
    this.offerPrice,
    this.attachments = const [],
  });

  @override
  List<Object?> get props =>
      [providerId, category, description, clientLat, clientLng, offerPrice, attachments];
}

final class JobStatusWatchStarted extends JobRequestEvent {
  final JobRequest job;
  const JobStatusWatchStarted(this.job);

  @override
  List<Object> get props => [job];
}

final class JobCancelRequested extends JobRequestEvent {
  final String jobId;
  const JobCancelRequested(this.jobId);

  @override
  List<Object> get props => [jobId];
}

final class JobCompleteRequested extends JobRequestEvent {
  final String jobId;
  const JobCompleteRequested(this.jobId);

  @override
  List<Object> get props => [jobId];
}

final class JobOfflinePaymentRequested extends JobRequestEvent {
  final String jobId;
  final String clientId;
  final String providerId;
  final double amount;

  const JobOfflinePaymentRequested({
    required this.jobId,
    required this.clientId,
    required this.providerId,
    required this.amount,
  });

  @override
  List<Object> get props => [jobId, clientId, providerId, amount];
}

final class JobOnlinePaymentConfirmed extends JobRequestEvent {
  final String jobId;
  final String clientId;
  final String providerId;
  final double amount;
  final String paymentIntentId;

  const JobOnlinePaymentConfirmed({
    required this.jobId,
    required this.clientId,
    required this.providerId,
    required this.amount,
    required this.paymentIntentId,
  });

  @override
  List<Object> get props =>
      [jobId, clientId, providerId, amount, paymentIntentId];
}

final class MyJobsRequested extends JobRequestEvent {
  final String clientId;
  const MyJobsRequested(this.clientId);

  @override
  List<Object> get props => [clientId];
}
