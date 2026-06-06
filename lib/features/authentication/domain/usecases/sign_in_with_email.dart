import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/domain/entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithEmail implements UseCase<AppUser, SignInWithEmailParams> {
  final AuthRepository _repository;
  SignInWithEmail(this._repository);

  @override
  Future<Either<Failure, AppUser>> call(SignInWithEmailParams params) =>
      _repository.signInWithEmail(email: params.email, password: params.password);
}

class SignInWithEmailParams extends Equatable {
  final String email;
  final String password;
  const SignInWithEmailParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
