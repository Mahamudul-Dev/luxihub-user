import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import '../../domain/usecases/upload_avatar.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfile _getProfile;
  final UpdateProfile _updateProfile;
  final UploadAvatar _uploadAvatar;

  ProfileBloc({
    required GetProfile getProfile,
    required UpdateProfile updateProfile,
    required UploadAvatar uploadAvatar,
  })  : _getProfile = getProfile,
        _updateProfile = updateProfile,
        _uploadAvatar = uploadAvatar,
        super(const ProfileInitial()) {
    on<ProfileFetchRequested>(_onFetchRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileAvatarUploadRequested>(_onAvatarUploadRequested);
  }

  Future<void> _onFetchRequested(
    ProfileFetchRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    final result = await _getProfile(event.uid);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state is ProfileLoaded ? (state as ProfileLoaded).profile : null;
    emit(const ProfileUpdating());
    final result = await _updateProfile(event.profile);
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) {
        emit(ProfileUpdateSuccess());
        if (current != null) emit(ProfileLoaded(event.profile));
      },
    );
  }

  Future<void> _onAvatarUploadRequested(
    ProfileAvatarUploadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state is ProfileLoaded ? (state as ProfileLoaded).profile : null;
    emit(const ProfileUploadingAvatar());
    final result = await _uploadAvatar(
      UploadAvatarParams(uid: event.uid, file: event.file),
    );
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (url) {
        if (current != null) {
          final updated = Profile(
            id: current.id,
            name: current.name,
            phone: current.phone,
            email: current.email,
            dob: current.dob,
            contractType: current.contractType,
            hourlyRate: current.hourlyRate,
            serviceArea: current.serviceArea,
            serviceLat: current.serviceLat,
            serviceLng: current.serviceLng,
            serviceRadiusKm: current.serviceRadiusKm,
            avatarPath: url,
            isOnline: current.isOnline,
            isKycVerified: current.isKycVerified,
            skills: current.skills,
          );
          emit(ProfileLoaded(updated));
        }
      },
    );
  }
}
