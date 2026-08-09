import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/transaction_entity.dart';

abstract interface class TransactionsDatasource {
  Future<List<TransactionEntity>> getTransactions(String clientId);
  Future<Uint8List> getInvoicePdf(String transactionId);
}

class TransactionsDatasourceImpl implements TransactionsDatasource {
  final SupabaseClient _client;
  const TransactionsDatasourceImpl(this._client);

  @override
  Future<List<TransactionEntity>> getTransactions(String clientId) async {
    try {
      final rows = await _client
          .from('transactions')
          .select('*')
          .eq('client_id', clientId)
          .order('created_at', ascending: false) as List;

      if (rows.isEmpty) return [];

      // Batch-join job_requests (category/description) and provider names
      // manually — these tables aren't confirmed to have named FK constraints
      // PostgREST could use for a `.select('*, job_requests(...)')` embed.
      final jobIds = rows.map((r) => r['job_request_id'] as String).toSet().toList();
      final providerIds = rows.map((r) => r['provider_id'] as String).whereType<String>().toSet().toList();

      final jobsById = <String, Map<String, dynamic>>{};
      if (jobIds.isNotEmpty) {
        final jobs = await _client
            .from('job_requests')
            .select('id, category, description, completed_at')
            .inFilter('id', jobIds) as List;
        for (final j in jobs) {
          jobsById[j['id'] as String] = j as Map<String, dynamic>;
        }
      }

      final providersById = <String, Map<String, dynamic>>{};
      if (providerIds.isNotEmpty) {
        final providers = await _client
            .from('profiles')
            .select('id, name')
            .inFilter('id', providerIds) as List;
        for (final p in providers) {
          providersById[p['id'] as String] = p as Map<String, dynamic>;
        }
      }

      return rows.map((row) {
        final map = Map<String, dynamic>.from(row as Map);
        map['job_requests'] = jobsById[map['job_request_id']];
        map['provider'] = providersById[map['provider_id']];
        return TransactionEntity.fromJson(map);
      }).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Uint8List> getInvoicePdf(String transactionId) async {
    try {
      final res = await _client.functions.invoke(
        'generate-invoice',
        body: {'transactionId': transactionId},
      );

      final data = res.data;
      if (data is Uint8List) return data;
      if (data is List<int>) return Uint8List.fromList(data);
      throw ServerException('Unexpected invoice response (${data.runtimeType})');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
