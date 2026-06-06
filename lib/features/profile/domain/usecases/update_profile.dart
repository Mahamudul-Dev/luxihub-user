import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/profile.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UpdateProfile implements UseCase<void, Profile> {
  final ProfileRepository _repository;
  UpdateProfile(this._repository);

  @override
  Future<Either<Failure, void>> call(Profile profile) =>
      _repository.updateProfile(profile);
}
