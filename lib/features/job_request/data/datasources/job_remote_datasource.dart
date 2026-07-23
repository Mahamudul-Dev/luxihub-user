import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/domain/entities/job_request.dart';
import '../../../../core/error/exceptions.dart';
import '../models/job_request_model.dart';

abstract interface class JobRemoteDataSource {
  Future<JobRequest> postJob({
    required String clientId,
    required String providerId,
    required String category,
    required String description,
    required double clientLat,
    required double clientLng,
    double? offerPrice,
    List<dynamic> attachments = const [],
  });

  Future<List<JobRequest>> getMyJobs(String clientId);

  Stream<String> watchJobStatus(String jobId);

  Future<void> updateJobStatus(String jobId, String status);

  Future<void> deleteJob(String jobId);

  Future<void> saveTransaction({
    required String jobId,
    required String clientId,
    required String providerId,
    required double amount,
    required String paymentMethod,
    required String status,
    String? stripePaymentIntentId,
  });
}

class JobRemoteDataSourceImpl implements JobRemoteDataSource {
  final SupabaseClient _client;
  const JobRemoteDataSourceImpl(this._client);

  @override
  Future<JobRequest> postJob({
    required String clientId,
    required String providerId,
    required String category,
    required String description,
    required double clientLat,
    required double clientLng,
    double? offerPrice,
    List<dynamic> attachments = const [],
  }) async {
    try {
      // Create job request
      final row = await _client
          .from('job_requests')
          .insert({
            'client_id': clientId,
            'provider_id': providerId,
            'category': category,
            'description': description,
            'client_lat': clientLat,
            'client_lng': clientLng,
            'status': 'pending',
            'amount': offerPrice,
          })
          .select('*, provider:provider_id(name, avatar_path, hourly_rate, stripe_account_id, reviews!reviews_provider_id_fkey(score))')
          .single();

      final jobId = row['id'] as String;

      // Upload attachments if any
      if (attachments.isNotEmpty) {
        for (int i = 0; i < attachments.length; i++) {
          final file = attachments[i] as File;
          final fileName = '${jobId}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
          final storagePath = 'job-attachments/$fileName';

          // Upload to Supabase storage
          await _client.storage
              .from('job-attachments')
              .upload(storagePath, file);

          // Insert attachment record
          await _client.from('job_attachments').insert({
            'job_request_id': jobId,
            'storage_path': storagePath,
          });
        }
      }

      return JobRequestModel.fromJson(row);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<JobRequest>> getMyJobs(String clientId) async {
    try {
      final response = await _client
          .from('job_requests')
          .select(
            '*, provider:provider_id(name, avatar_path, hourly_rate, stripe_account_id, reviews!reviews_provider_id_fkey(score))',
          )
          .eq('client_id', clientId)
          .order('posted_at', ascending: false);

      return (response as List)
          .map((j) => JobRequestModel.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<String> watchJobStatus(String jobId) {
    return _client
        .from('job_requests')
        .stream(primaryKey: ['id'])
        .eq('id', jobId)
        .map((rows) =>
            rows.isEmpty ? 'pending' : rows.first['status'] as String);
  }

  @override
  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      final updated = await _client
          .from('job_requests')
          .update({'status': status})
          .eq('id', jobId)
          .select('id')
          .maybeSingle();

      if (updated == null) {
        throw const ServerException(
          'Could not update job status — check RLS policies on job_requests.',
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteJob(String jobId) async {
    try {
      await _client.from('job_requests').delete().eq('id', jobId);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> saveTransaction({
    required String jobId,
    required String clientId,
    required String providerId,
    required double amount,
    required String paymentMethod,
    required String status,
    String? stripePaymentIntentId,
  }) async {
    try {
      await _client.from('transactions').insert({
        'job_request_id': jobId,
        'client_id': clientId,
        'provider_id': providerId,
        'amount': amount,
        'currency': 'gbp',
        'payment_method': paymentMethod,
        'status': status,
        'stripe_payment_intent_id': stripePaymentIntentId,
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
