import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendPhoneOtp(String phone);
  Future<Either<Failure, AppUser>> verifyPhoneOtp({required String phone, required String token});
  Future<Either<Failure, AppUser>> signInWithEmail({required String email, required String password});
  Future<Either<Failure, AppUser>> signUpWithEmail({required String email, required String password, required String name, required String phone});
  Future<Either<Failure, void>> resendConfirmationEmail(String email);
  Future<Either<Failure, void>> signOut();
  AppUser? getCurrentUser();
}
