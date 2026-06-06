import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/profile.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _dataSource;
  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, Profile>> getProfile(String uid) async {
    try {
      final model = await _dataSource.getProfile(uid);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile(Profile profile) async {
    try {
      final model = ProfileModel(
        id: profile.id,
        name: profile.name,
        phone: profile.phone,
        email: profile.email,
        dob: profile.dob,
        contractType: profile.contractType,
        hourlyRate: profile.hourlyRate,
        serviceArea: profile.serviceArea,
        serviceLat: profile.serviceLat,
        serviceLng: profile.serviceLng,
        serviceRadiusKm: profile.serviceRadiusKm,
        avatarPath: profile.avatarPath,
        isOnline: profile.isOnline,
        isKycVerified: profile.isKycVerified,
        skills: profile.skills,
      );
      await _dataSource.updateProfile(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(String uid, File file) async {
    try {
      final url = await _dataSource.uploadAvatar(uid, file);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
