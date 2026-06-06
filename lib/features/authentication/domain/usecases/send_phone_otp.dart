import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SendPhoneOtp implements UseCase<void, String> {
  final AuthRepository _repository;
  SendPhoneOtp(this._repository);

  @override
  Future<Either<Failure, void>> call(String phone) =>
      _repository.sendPhoneOtp(phone);
}
