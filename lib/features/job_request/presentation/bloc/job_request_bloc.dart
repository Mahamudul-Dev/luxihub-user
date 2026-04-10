import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/enum/job_request_enum.dart';

part 'job_request_event.dart';
part 'job_request_state.dart';

class JobRequestBloc extends Bloc<JobRequestEvent, JobRequestState> {
  JobRequestBloc() : super(JobRequestInitial()) {
    on<JobRequestStarted>(_onStarted);
  }

  Future<void> _onStarted(
    JobRequestStarted event,
    Emitter<JobRequestState> emit,
  ) async {
    emit(const JobRequestStatusUpdated(JobRequestStatus.waiting));

    // Simulate provider accepting after 4 seconds.
    // TODO: replace with a real-time subscription (e.g. Supabase realtime).
    await Future.delayed(const Duration(seconds: 4));
    if (!isClosed) {
      emit(const JobRequestStatusUpdated(JobRequestStatus.accepted));
    }
  }
}
