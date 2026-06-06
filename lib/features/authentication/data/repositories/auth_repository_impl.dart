import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _dataSource;
  AuthRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, void>> sendPhoneOtp(String phone) async {
    try {
      await _dataSource.sendPhoneOtp(phone);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AppUser>> verifyPhoneOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final response = await _dataSource.verifyPhoneOtp(phone: phone, token: token);
      return Right(AppUser(
        id: response.user!.id,
        phone: response.user!.phone,
        email: response.user!.email,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dataSource.signInWithEmail(email: email, password: password);
      return Right(AppUser(
        id: response.user!.id,
        email: response.user!.email,
        phone: response.user!.phone,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final response = await _dataSource.signUpWithEmail(email: email, password: password, name: name, phone: phone);
      return Right(AppUser(
        id: response.user!.id,
        email: response.user!.email,
        phone: response.user!.phone,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> resendConfirmationEmail(String email) async {
    try {
      await _dataSource.resendConfirmationEmail(email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  AppUser? getCurrentUser() {
    final user = _dataSource.getCurrentUser();
    if (user == null) return null;
    return AppUser(id: user.id, phone: user.phone, email: user.email);
  }
}
