import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/job_request.dart';
import '../../../../core/enum/job_request_enum.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/usecases/cancel_job.dart';
import '../../domain/usecases/complete_job.dart';
import '../../domain/usecases/get_my_jobs.dart';
import '../../domain/usecases/post_job.dart';
import '../../domain/usecases/save_transaction.dart';
import '../../domain/usecases/update_job_status.dart';
import '../../domain/usecases/watch_job_status.dart';

part 'job_request_event.dart';
part 'job_request_state.dart';

class JobRequestBloc extends Bloc<JobRequestEvent, JobRequestState> {
  final AuthBloc _authBloc;
  final PostJob _postJob;
  final GetMyJobs _getMyJobs;
  final WatchJobStatus _watchJobStatus;
  final CancelJob _cancelJob;
  final CompleteJob _completeJob;
  final SaveTransaction _saveTransaction;
  final UpdateJobStatus _updateJobStatus;

  JobRequestBloc({
    required AuthBloc authBloc,
    required PostJob postJob,
    required GetMyJobs getMyJobs,
    required WatchJobStatus watchJobStatus,
    required CancelJob cancelJob,
    required CompleteJob completeJob,
    required SaveTransaction saveTransaction,
    required UpdateJobStatus updateJobStatus,
  })  : _authBloc = authBloc,
        _postJob = postJob,
        _getMyJobs = getMyJobs,
        _watchJobStatus = watchJobStatus,
        _cancelJob = cancelJob,
        _completeJob = completeJob,
        _saveTransaction = saveTransaction,
        _updateJobStatus = updateJobStatus,
        super(JobRequestInitial()) {
    on<JobPostRequested>(_onPostRequested);
    on<JobStatusWatchStarted>(_onWatchStarted);
    on<JobCancelRequested>(_onCancelRequested);
    on<JobCompleteRequested>(_onCompleteRequested);
    on<JobOfflinePaymentRequested>(_onOfflinePayment);
    on<JobOnlinePaymentConfirmed>(_onOnlinePaymentConfirmed);
    on<MyJobsRequested>(_onMyJobsRequested);
  }

  String? get _uid {
    final s = _authBloc.state;
    return s is AuthAuthenticated ? s.user.id : null;
  }

  Future<void> _onPostRequested(
    JobPostRequested event,
    Emitter<JobRequestState> emit,
  ) async {
    final uid = _uid;
    if (uid == null) {
      emit(const JobRequestError('Not authenticated'));
      return;
    }
    emit(JobRequestPosting());
    try {
      final job = await _postJob(PostJobParams(
        clientId: uid,
        providerId: event.providerId,
        category: event.category,
        description: event.description,
        clientLat: event.clientLat,
        clientLng: event.clientLng,
        offerPrice: event.offerPrice,
      ));
      emit(JobRequestPosted(job));
    } catch (e) {
      emit(JobRequestError(e.toString()));
    }
  }

  Future<void> _onWatchStarted(
    JobStatusWatchStarted event,
    Emitter<JobRequestState> emit,
  ) async {
    emit(JobRequestWatching(
      job: event.job,
      status: JobRequestStatusX.fromString(event.job.status),
    ));
    await emit.forEach<String>(
      _watchJobStatus(event.job.id),
      onData: (status) {
        if (status == 'completed') return JobRequestCompleted();
        return JobRequestWatching(
          job: event.job,
          status: JobRequestStatusX.fromString(status),
        );
      },
      onError: (e, _) => JobRequestError(e.toString()),
    );
  }

  Future<void> _onCancelRequested(
    JobCancelRequested event,
    Emitter<JobRequestState> emit,
  ) async {
    try {
      await _cancelJob(event.jobId);
      emit(JobRequestCancelled());
    } catch (e) {
      emit(JobRequestError(e.toString()));
    }
  }

  // Direct complete (legacy — not triggered by payment flow)
  Future<void> _onCompleteRequested(
    JobCompleteRequested event,
    Emitter<JobRequestState> emit,
  ) async {
    try {
      await _completeJob(event.jobId);
      emit(JobRequestCompleted());
    } catch (e) {
      emit(JobRequestError(e.toString()));
    }
  }

  // User chose offline/cash payment
  Future<void> _onOfflinePayment(
    JobOfflinePaymentRequested event,
    Emitter<JobRequestState> emit,
  ) async {
    emit(JobRequestLoading());
    try {
      await _saveTransaction(SaveTransactionParams(
        jobId: event.jobId,
        clientId: event.clientId,
        providerId: event.providerId,
        amount: event.amount,
        paymentMethod: 'cash',
        status: 'pending',
      ));
      await _updateJobStatus(event.jobId, 'awaiting_offline_confirmation');
      emit(JobRequestAwaitingOfflineConfirmation());

      // Keep watching — when handyman confirms, status becomes 'completed'
      await emit.forEach<String>(
        _watchJobStatus(event.jobId),
        onData: (status) => status == 'completed'
            ? JobRequestCompleted()
            : JobRequestAwaitingOfflineConfirmation(),
        onError: (e, _) => JobRequestError(e.toString()),
      );
    } catch (e) {
      emit(JobRequestError(e.toString()));
    }
  }

  // Stripe payment succeeded — save transaction + mark complete
  Future<void> _onOnlinePaymentConfirmed(
    JobOnlinePaymentConfirmed event,
    Emitter<JobRequestState> emit,
  ) async {
    emit(JobRequestLoading());
    try {
      await _saveTransaction(SaveTransactionParams(
        jobId: event.jobId,
        clientId: event.clientId,
        providerId: event.providerId,
        amount: event.amount,
        paymentMethod: 'stripe',
        status: 'completed',
        stripePaymentIntentId: event.paymentIntentId,
      ));
      await _completeJob(event.jobId);
      emit(JobRequestCompleted());
    } catch (e) {
      emit(JobRequestError(e.toString()));
    }
  }

  Future<void> _onMyJobsRequested(
    MyJobsRequested event,
    Emitter<JobRequestState> emit,
  ) async {
    emit(MyJobsLoading());
    try {
      final jobs = await _getMyJobs(event.clientId);
      emit(MyJobsLoaded(jobs));
    } catch (e) {
      emit(JobRequestError(e.toString()));
    }
  }
}
