import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/job_request.dart';
import '../repositories/job_repository.dart';

class PostJob {
  final JobRepository _repository;
  const PostJob(this._repository);

  Future<JobRequest> call(PostJobParams params) => _repository.postJob(
        clientId: params.clientId,
        providerId: params.providerId,
        category: params.category,
        description: params.description,
        clientLat: params.clientLat,
        clientLng: params.clientLng,
        offerPrice: params.offerPrice,
        attachments: params.attachments,
      );
}

class PostJobParams extends Equatable {
  final String clientId;
  final String providerId;
  final String category;
  final String description;
  final double clientLat;
  final double clientLng;
  final double? offerPrice;
  final List<dynamic> attachments;

  const PostJobParams({
    required this.clientId,
    required this.providerId,
    required this.category,
    required this.description,
    this.clientLat = 0.0,
    this.clientLng = 0.0,
    this.offerPrice,
    this.attachments = const [],
  });

  @override
  List<Object?> get props =>
      [clientId, providerId, category, description, clientLat, clientLng, offerPrice, attachments];
}
