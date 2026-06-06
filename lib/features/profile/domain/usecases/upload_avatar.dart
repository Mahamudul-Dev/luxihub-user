import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UploadAvatar implements UseCase<String, UploadAvatarParams> {
  final ProfileRepository _repository;
  UploadAvatar(this._repository);

  @override
  Future<Either<Failure, String>> call(UploadAvatarParams params) =>
      _repository.uploadAvatar(params.uid, params.file);
}

class UploadAvatarParams extends Equatable {
  final String uid;
  final File file;
  const UploadAvatarParams({required this.uid, required this.file});

  @override
  List<Object> get props => [uid, file.path];
}
