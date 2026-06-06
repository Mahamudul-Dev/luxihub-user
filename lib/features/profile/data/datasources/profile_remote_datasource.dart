import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String uid);
  Future<void> updateProfile(ProfileModel model);
  Future<String> uploadAvatar(String uid, File file);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient _client;
  ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<ProfileModel> getProfile(String uid) async {
    try {
      final data = await _client
          .from('profiles')
          .select('*, skills(name)')
          .eq('id', uid)
          .maybeSingle();

      if (data == null) throw const ServerException('Profile not found.');
      return ProfileModel.fromJson(data);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateProfile(ProfileModel model) async {
    try {
      await _client
          .from('profiles')
          .update(model.toUpdateJson())
          .eq('id', model.id);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadAvatar(String uid, File file) async {
    try {
      final ext = file.path.split('.').last;
      final storagePath = '$uid/avatar.$ext';

      await _client.storage.from('avatars').upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl =
          _client.storage.from('avatars').getPublicUrl(storagePath);

      await _client
          .from('profiles')
          .update({'avatar_path': publicUrl})
          .eq('id', uid);

      return publicUrl;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
