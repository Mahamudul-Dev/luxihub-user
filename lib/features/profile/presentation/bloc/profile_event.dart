part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileFetchRequested extends ProfileEvent {
  final String uid;
  const ProfileFetchRequested(this.uid);

  @override
  List<Object?> get props => [uid];
}

final class ProfileUpdateRequested extends ProfileEvent {
  final Profile profile;
  const ProfileUpdateRequested(this.profile);

  @override
  List<Object?> get props => [profile];
}

final class ProfileAvatarUploadRequested extends ProfileEvent {
  final String uid;
  final File file;
  const ProfileAvatarUploadRequested({required this.uid, required this.file});

  @override
  List<Object?> get props => [uid, file.path];
}
