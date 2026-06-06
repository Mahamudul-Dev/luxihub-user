import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/utils.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entities/job_request.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/job_request_bloc.dart';

class PaymentMethodSheet extends StatefulWidget {
  const PaymentMethodSheet({
    super.key,
    required this.job,
    required this.clientId,
  });

  final JobRequest job;
  final String clientId;

  @override
  State<PaymentMethodSheet> createState() => _PaymentMethodSheetState();
}

class _PaymentMethodSheetState extends State<PaymentMethodSheet> {
  bool _onlineLoading = false;
  bool _offlineLoading = false;
  String? _errorMessage;

  double get _amount => widget.job.payableAmount;

  Future<void> _payOnline() async {
    final providerId = widget.job.providerId;
    if (providerId == null || providerId.isEmpty) {
      _setError('No provider assigned to this job.');
      return;
    }

    setState(() { _onlineLoading = true; _errorMessage = null; });
    try {
      // 1. Create PaymentIntent via Edge Function
      debugPrint('[Stripe] Invoking create-payment-intent: amount=$_amount, providerId=$providerId');
      final res = await sl<SupabaseClient>().functions.invoke(
        'create-payment-intent',
        body: {
          'amount': _amount,
          'currency': 'gbp',
          'providerId': providerId,
          'jobRequestId': widget.job.id,
        },
      );

      debugPrint('[Stripe] Edge Function response: ${res.data}');

      final data = res.data as Map?;
      if (data == null || data['clientSecret'] == null) {
        throw Exception(data?['error']?.toString() ?? 'No clientSecret returned from server.');
      }

      final clientSecret = data['clientSecret'] as String;
      final paymentIntentId = clientSecret.split('_secret_').first;
      debugPrint('[Stripe] clientSecret obtained, paymentIntentId: $paymentIntentId');

      // 2. Init payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'LuxiHub',
          style: ThemeMode.light,
        ),
      );
      debugPrint('[Stripe] Payment sheet initialized');

      // 3. Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      debugPrint('[Stripe] Payment sheet completed successfully');

      // 4. Success
      if (mounted) {
        context.read<JobRequestBloc>().add(JobOnlinePaymentConfirmed(
              jobId: widget.job.id,
              clientId: widget.clientId,
              providerId: widget.job.providerId!,
              amount: _amount,
              paymentIntentId: paymentIntentId,
            ));
        Navigator.of(context).pop();
      }
    } on StripeException catch (e) {
      debugPrint('[Stripe] StripeException: code=${e.error.code}, msg=${e.error.localizedMessage}, type=${e.error.type}');
      // Only suppress genuine user-initiated cancellation
      if (e.error.code == FailureCode.Canceled &&
          (e.error.localizedMessage == null ||
              e.error.localizedMessage!.toLowerCase().contains('cancel'))) {
        debugPrint('[Stripe] User cancelled payment sheet.');
      } else {
        _setError('Payment failed: ${e.error.localizedMessage ?? e.error.code.name}');
      }
    } on FunctionException catch (e) {
      debugPrint('[Stripe] FunctionException: ${e.details}');
      _setError('Server error: ${e.details}');
    } catch (e) {
      debugPrint('[Stripe] Unexpected error: $e');
      _setError(e.toString());
    } finally {
      if (mounted) setState(() => _onlineLoading = false);
    }
  }

  void _payOffline() {
    setState(() => _offlineLoading = true);
    context.read<JobRequestBloc>().add(JobOfflinePaymentRequested(
          jobId: widget.job.id,
          clientId: widget.clientId,
          providerId: widget.job.providerId!,
          amount: _amount,
        ));
    Navigator.of(context).pop();
  }

  void _setError(String msg) {
    debugPrint('[PaymentSheet] Error: $msg');
    if (mounted) setState(() => _errorMessage = msg);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        Utils.defaultPadding * 2,
        Utils.defaultPadding * 1.5,
        Utils.defaultPadding * 2,
        Utils.defaultPadding * 2 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: Utils.defaultPadding * 1.5),

          const Icon(Icons.payments_outlined, size: 48, color: AppColors.primary),
          const SizedBox(height: Utils.defaultPadding),

          Text(
            'How would you like to pay?',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Amount due: £${_amount.toStringAsFixed(2)}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey.shade600),
          ),

          // Inline error message
          if (_errorMessage != null) ...[
            const SizedBox(height: Utils.defaultPadding),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Utils.defaultPadding),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(Utils.defaultBorderRadius),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.red.shade700,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: Utils.defaultPadding * 2),

          // Online payment button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_onlineLoading || _offlineLoading) ? null : _payOnline,
              icon: _onlineLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.credit_card, color: Colors.white),
              label: Text(
                _onlineLoading ? 'Processing...' : 'Pay Online (Card / Stripe)',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                    vertical: Utils.defaultPadding * 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Utils.defaultBorderRadius),
                ),
              ),
            ),
          ),

          const SizedBox(height: Utils.defaultPadding),

          // Offline payment button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: (_onlineLoading || _offlineLoading) ? null : _payOffline,
              icon: _offlineLoading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                  : const Icon(Icons.handshake_outlined, color: AppColors.primary),
              label: const Text(
                'Pay Offline (Cash to Handyman)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(
                    vertical: Utils.defaultPadding * 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Utils.defaultBorderRadius),
                ),
              ),
            ),
          ),

          const SizedBox(height: Utils.defaultPadding / 2),
          Text(
            'Offline payment requires handyman confirmation before the job is marked complete.',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
