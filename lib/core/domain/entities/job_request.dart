import 'package:equatable/equatable.dart';

class JobRequest extends Equatable {
  final String id;
  final String clientId;
  final String? providerId;
  final String category;
  final String description;
  final String status;
  final double clientLat;
  final double clientLng;
  final double? amount;
  final DateTime postedAt;
  final DateTime? completedAt;

  // Embedded for display (from profiles JOIN)
  final String? providerName;
  final String? providerAvatarPath;
  final double providerRating;
  final int providerReviewCount;
  final String? providerStripeAccountId;
  final double? providerHourlyRate;

  const JobRequest({
    required this.id,
    required this.clientId,
    this.providerId,
    required this.category,
    required this.description,
    required this.status,
    required this.clientLat,
    required this.clientLng,
    this.amount,
    required this.postedAt,
    this.completedAt,
    this.providerName,
    this.providerAvatarPath,
    this.providerRating = 0.0,
    this.providerReviewCount = 0,
    this.providerStripeAccountId,
    this.providerHourlyRate,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isAwaitingPayment => status == 'awaiting_payment_confirmation';
  bool get isCompleted => status == 'completed';

  /// Amount to charge: offer price if set, otherwise provider's hourly rate.
  double get payableAmount => amount ?? providerHourlyRate ?? 0.0;

  @override
  List<Object?> get props => [
        id, clientId, providerId, category, description, status,
        clientLat, clientLng, amount, postedAt, completedAt,
        providerName, providerAvatarPath, providerRating, providerReviewCount,
      ];
}
