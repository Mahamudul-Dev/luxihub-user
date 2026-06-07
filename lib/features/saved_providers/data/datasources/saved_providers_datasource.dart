import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../../../core/error/exceptions.dart';
import '../../../home/data/models/service_provider_model.dart';

abstract interface class SavedProvidersDatasource {
  Future<Set<String>> getSavedProviderIds(String userId);
  Future<List<ServiceProviderEntity>> getSavedProviders(String userId);
  Future<void> saveProvider(String userId, String providerId);
  Future<void> unsaveProvider(String userId, String providerId);
}

class SavedProvidersDatasourceImpl implements SavedProvidersDatasource {
  final SupabaseClient _client;
  const SavedProvidersDatasourceImpl(this._client);

  @override
  Future<Set<String>> getSavedProviderIds(String userId) async {
    try {
      final rows = await _client
          .from('saved_providers')
          .select('provider_id')
          .eq('user_id', userId);
      return (rows as List)
          .map((r) => r['provider_id'] as String)
          .toSet();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ServiceProviderEntity>> getSavedProviders(String userId) async {
    try {
      final rows = await _client
          .from('saved_providers')
          .select(
            'provider:provider_id(*, skills(name), reviews!reviews_provider_id_fkey(score))',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((r) => ServiceProviderModel.fromJson(
                r['provider'] as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> saveProvider(String userId, String providerId) async {
    try {
      await _client.from('saved_providers').upsert({
        'user_id': userId,
        'provider_id': providerId,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> unsaveProvider(String userId, String providerId) async {
    try {
      await _client
          .from('saved_providers')
          .delete()
          .eq('user_id', userId)
          .eq('provider_id', providerId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
