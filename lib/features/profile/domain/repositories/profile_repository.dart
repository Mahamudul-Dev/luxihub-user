import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/profile.dart';
import '../../../../core/error/failures.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile(String uid);
  Future<Either<Failure, void>> updateProfile(Profile profile);
  Future<Either<Failure, String>> uploadAvatar(String uid, File file);
}
