import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

part 'rating_event.dart';
part 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  RatingBloc() : super(const RatingState()) {
    on<RatingPhotoAdded>(_onPhotoAdded);
    on<RatingPhotoRemoved>(_onPhotoRemoved);
    on<RatingScoreChanged>(_onScoreChanged);
    on<RatingCommentChanged>(_onCommentChanged);
    on<RatingSubmitted>(_onSubmitted);
  }

  final _picker = ImagePicker();

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
    emit(state.copyWith(status: RatingStatus.submitting));
    // TODO: replace with real API call
    await Future.delayed(const Duration(seconds: 2));
    emit(state.copyWith(status: RatingStatus.submitted));
  }
}
