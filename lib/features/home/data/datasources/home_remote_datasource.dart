import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/domain/entities/category_entity.dart';
import '../../../../core/domain/entities/service_provider_entity.dart';
import '../../../../core/error/exceptions.dart';
import '../models/category_model.dart';
import '../models/service_provider_model.dart';

abstract interface class HomeRemoteDataSource {
  Future<List<ServiceProviderEntity>> getServiceProviders({int limit = 10});
  Future<List<CategoryEntity>> getCategories();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SupabaseClient _client;
  const HomeRemoteDataSourceImpl(this._client);

  @override
  Future<List<ServiceProviderEntity>> getServiceProviders({int limit = 10}) async {
    try {
      final response = await _client
          .from('profiles')
          .select('*, skills(name), reviews!reviews_provider_id_fkey(score)')
          .eq('user_type', 'provider')
          .order('is_online', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => ServiceProviderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select('id, name, image_url, service_count')
          .eq('is_active', true)
          .order('sort_order');

      return (response as List)
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
