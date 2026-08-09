class TransactionEntity {
  final String id;
  final String jobId;
  final double amount;
  final String currency;
  final String paymentMethod; // 'stripe' | 'cash'
  final String status; // 'pending' | 'completed' | 'failed'
  final String category;
  final String? description;
  final String? providerName;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.jobId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    required this.status,
    required this.category,
    required this.createdAt,
    this.description,
    this.providerName,
  });

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    final job = json['job_requests'] as Map<String, dynamic>?;
    final provider = json['provider'] as Map<String, dynamic>?;
    return TransactionEntity(
      id: json['id'] as String,
      jobId: json['job_request_id'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: (json['currency'] as String?) ?? 'gbp',
      paymentMethod: (json['payment_method'] as String?) ?? 'stripe',
      status: (json['status'] as String?) ?? 'pending',
      category: (job?['category'] as String?) ?? 'Service',
      description: job?['description'] as String?,
      providerName: provider?['name'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
