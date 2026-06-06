import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/provider_review.dart';

abstract interface class ReviewRemoteDataSource {
  Future<void> submitReview({
    required String jobId,
    required String clientId,
    required String providerId,
    required double score,
    String? comment,
    List<String> photoPaths,
  });

  Future<({double score, String? comment})?> getJobReview(String jobId);

  Future<List<ProviderReview>> getProviderReviews(
    String providerId, {
    int? limit,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final SupabaseClient _client;
  const ReviewRemoteDataSourceImpl(this._client);

  @override
  Future<void> submitReview({
    required String jobId,
    required String clientId,
    required String providerId,
    required double score,
    String? comment,
    List<String> photoPaths = const [],
  }) async {
    try {
      final row = await _client
          .from('reviews')
          .insert({
            'job_request_id': jobId,
            'client_id': clientId,
            'provider_id': providerId,
            'score': score,
            if (comment != null && comment.isNotEmpty) 'comment': comment,
          })
          .select('id')
          .single();

      final reviewId = row['id'] as String;

      // Upload photos — failures are logged but don't block review submission.
      for (final path in photoPaths) {
        try {
          final file = File(path);
          final bytes = await file.readAsBytes();
          final ext = path.split('.').last.toLowerCase();
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
          final storagePath = '$reviewId/$fileName';

          debugPrint('[ReviewPhotos] Uploading $storagePath (${bytes.length} bytes)');

          await _client.storage.from('review-photos').uploadBinary(
                storagePath,
                bytes,
                fileOptions: FileOptions(
                  upsert: true,
                  contentType: 'image/$ext',
                ),
              );

          await _client.from('review_photos').insert({
            'review_id': reviewId,
            'storage_path': storagePath,
          });

          debugPrint('[ReviewPhotos] Saved $storagePath to review_photos table');
        } catch (e) {
          debugPrint('[ReviewPhotos] ERROR uploading photo $path: $e');
        }
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<({double score, String? comment})?> getJobReview(String jobId) async {
    try {
      final rows = await _client
          .from('reviews')
          .select('score, comment')
          .eq('job_request_id', jobId)
          .order('created_at', ascending: false)
          .limit(1);
      if (rows.isEmpty) return null;
      final row = rows.first;
      // score may come back as num or String depending on column type.
      final rawScore = row['score'];
      final score = rawScore is num
          ? rawScore.toDouble()
          : double.tryParse(rawScore.toString()) ?? 0.0;
      return (
        score: score,
        comment: row['comment'] as String?,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<ProviderReview>> getProviderReviews(
    String providerId, {
    int? limit,
  }) async {
    try {
      // Join client:client_id(name, avatar_path) requires reviews.client_id FK
      // to point at public.profiles (not auth.users). Run the FK migration in
      // Supabase first; the join is gracefully ignored if the row is null.
      final builder = _client
          .from('reviews')
          .select(
            'id, score, comment, created_at, '
            'client:client_id(name, avatar_path), '
            'review_photos(storage_path)',
          )
          .eq('provider_id', providerId)
          .order('created_at', ascending: false);

      final rows =
          (limit != null ? await builder.limit(limit) : await builder)
              as List<dynamic>;

      return rows.map((r) {
        final row = r as Map<String, dynamic>;
        final rawScore = row['score'];
        final score = rawScore is num
            ? rawScore.toDouble()
            : double.tryParse(rawScore.toString()) ?? 0.0;
        final client = row['client'] as Map<String, dynamic>?;

        final photosJson = row['review_photos'] as List? ?? [];
        final photoUrls = photosJson.map((p) {
          final storagePath = (p as Map)['storage_path'] as String;
          return _client.storage
              .from('review-photos')
              .getPublicUrl(storagePath);
        }).toList();

        return ProviderReview(
          score: score,
          comment: row['comment'] as String?,
          clientName: client?['name'] as String?,
          clientAvatarPath: client?['avatar_path'] as String?,
          createdAt: DateTime.parse(row['created_at'] as String),
          photoUrls: photoUrls,
        );
      }).toList();
    } catch (e) {
      debugPrint('getProviderReviews error: $e');
      throw ServerException(e.toString());
    }
  }
}
