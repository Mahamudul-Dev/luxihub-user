import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/exceptions.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/usecases/submit_review.dart';

part 'rating_event.dart';
part 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final AuthBloc _authBloc;
  final SubmitReview _submitReview;
  final _picker = ImagePicker();

  RatingBloc({
    required AuthBloc authBloc,
    required SubmitReview submitReview,
  })  : _authBloc = authBloc,
        _submitReview = submitReview,
        super(const RatingState()) {
    on<RatingPhotoAdded>(_onPhotoAdded);
    on<RatingPhotoRemoved>(_onPhotoRemoved);
    on<RatingScoreChanged>(_onScoreChanged);
    on<RatingCommentChanged>(_onCommentChanged);
    on<RatingSubmitted>(_onSubmitted);
  }

  Future<void> pickPhotos() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) add(RatingPhotoAdded(picked));
  }

  void _onPhotoAdded(RatingPhotoAdded event, Emitter<RatingState> emit) {
    emit(state.copyWith(photos: [...state.photos, ...event.photos]));
  }

  void _onPhotoRemoved(RatingPhotoRemoved event, Emitter<RatingState> emit) {
    final updated = List<XFile>.from(state.photos)..removeAt(event.index);
    emit(state.copyWith(photos: updated));
  }

  void _onScoreChanged(RatingScoreChanged event, Emitter<RatingState> emit) {
    emit(state.copyWith(score: event.score));
  }

  void _onCommentChanged(
      RatingCommentChanged event, Emitter<RatingState> emit) {
    emit(state.copyWith(comment: event.comment));
  }

  Future<void> _onSubmitted(
      RatingSubmitted event, Emitter<RatingState> emit) async {
    final authState = _authBloc.state;
    if (authState is! AuthAuthenticated) return;

    emit(state.copyWith(status: RatingStatus.submitting));
    try {
      await _submitReview(SubmitReviewParams(
        jobId: event.jobId,
        clientId: authState.user.id,
        providerId: event.providerId,
        score: state.score > 0 ? state.score : 3.0,
        comment: state.comment.isNotEmpty ? state.comment : null,
        photoPaths: state.photos.map((f) => f.path).toList(),
      ));
      emit(state.copyWith(status: RatingStatus.submitted));
    } on ServerException catch (e) {
      emit(state.copyWith(
        status: RatingStatus.idle,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RatingStatus.idle,
        errorMessage: e.toString(),
      ));
    }
  }
}
