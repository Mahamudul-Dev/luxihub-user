import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/get_invoice_pdf.dart';
import '../../domain/usecases/get_transactions.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  List<TransactionEntity> _transactions = [];
  bool _loading = true;
  String? _error;
  String? _downloadingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final transactions = await sl<GetTransactions>()(authState.user.id);
      if (mounted) setState(() => _transactions = transactions);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _downloadInvoice(TransactionEntity transaction) async {
    setState(() => _downloadingId = transaction.id);
    try {
      final bytes = await sl<GetInvoicePdf>()(transaction.id);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoice-${transaction.id.substring(0, 8)}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], fileNameOverrides: [file.uri.pathSegments.last]),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not download invoice: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _downloadingId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Transaction History'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 300, child: Center(child: CircularProgressIndicator())),
        ],
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 400,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textHint)),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_transactions.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(
            height: 400,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.textHint),
                  SizedBox(height: 16),
                  Text('No transactions yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  SizedBox(height: 8),
                  Text('Completed and pending job payments will show up here',
                      textAlign: TextAlign.center, style: TextStyle(color: AppColors.textHint)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _TransactionTile(
        transaction: _transactions[index],
        isDownloading: _downloadingId == _transactions[index].id,
        onDownload: () => _downloadInvoice(_transactions[index]),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.isDownloading,
    required this.onDownload,
  });

  final TransactionEntity transaction;
  final bool isDownloading;
  final VoidCallback onDownload;

  Color _statusColor() {
    switch (transaction.status) {
      case 'completed':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.warning;
    }
  }

  String _formatAmount() {
    final symbol = transaction.currency.toLowerCase() == 'gbp' ? '£' : transaction.currency.toUpperCase();
    return '$symbol${transaction.amount.toStringAsFixed(2)}';
  }

  String _formatDate() {
    final d = transaction.createdAt;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final category = transaction.category.isNotEmpty
        ? transaction.category[0].toUpperCase() + transaction.category.substring(1)
        : 'Service';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.splashBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.build_outlined, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 3),
                Text(
                  '${transaction.paymentMethod == 'stripe' ? 'Card' : 'Cash'} · ${_formatDate()}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textHint),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    transaction.status[0].toUpperCase() + transaction.status.substring(1),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor()),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatAmount(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              const SizedBox(height: 6),
              if (transaction.status == 'completed')
                isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.download_outlined, size: 20, color: AppColors.primary),
                        tooltip: 'Download invoice',
                        onPressed: onDownload,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
            ],
          ),
        ],
      ),
    );
  }
}
