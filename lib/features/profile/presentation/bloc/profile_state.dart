part of 'profile_bloc.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileLoaded extends ProfileState {
  final Profile profile;
  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

final class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

final class ProfileUpdateSuccess extends ProfileState {}

final class ProfileUploadingAvatar extends ProfileState {
  const ProfileUploadingAvatar();
}

final class ProfileError extends ProfileState {
  final String message;
  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
