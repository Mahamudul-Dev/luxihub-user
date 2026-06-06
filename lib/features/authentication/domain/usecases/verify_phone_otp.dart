import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/domain/entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class VerifyPhoneOtp implements UseCase<AppUser, VerifyPhoneOtpParams> {
  final AuthRepository _repository;
  VerifyPhoneOtp(this._repository);

  @override
  Future<Either<Failure, AppUser>> call(VerifyPhoneOtpParams params) =>
      _repository.verifyPhoneOtp(phone: params.phone, token: params.token);
}

class VerifyPhoneOtpParams extends Equatable {
  final String phone;
  final String token;
  const VerifyPhoneOtpParams({required this.phone, required this.token});

  @override
  List<Object> get props => [phone, token];
}
