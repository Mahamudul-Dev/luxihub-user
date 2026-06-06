import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/profile.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class GetProfile implements UseCase<Profile, String> {
  final ProfileRepository _repository;
  GetProfile(this._repository);

  @override
  Future<Either<Failure, Profile>> call(String uid) =>
      _repository.getProfile(uid);
}
