import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/domain/entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignUpWithEmail implements UseCase<AppUser, SignUpWithEmailParams> {
  final AuthRepository _repository;
  SignUpWithEmail(this._repository);

  @override
  Future<Either<Failure, AppUser>> call(SignUpWithEmailParams params) =>
      _repository.signUpWithEmail(
        email: params.email,
        password: params.password,
        name: params.name,
        phone: params.phone,
      );
}

class SignUpWithEmailParams extends Equatable {
  final String email;
  final String password;
  final String name;
  final String phone;
  const SignUpWithEmailParams({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
  });

  @override
  List<Object> get props => [email, password, name, phone];
}
