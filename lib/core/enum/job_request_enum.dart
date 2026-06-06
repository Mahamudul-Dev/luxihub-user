enum JobRequestStatus {
  pending,
  accepted,
  rejected,
  awaitingPaymentConfirmation,
  awaitingOfflineConfirmation,
  completed,
}

extension JobRequestStatusX on JobRequestStatus {
  String get label => switch (this) {
        JobRequestStatus.pending => 'Pending',
        JobRequestStatus.accepted => 'Accepted',
        JobRequestStatus.rejected => 'Rejected',
        JobRequestStatus.awaitingPaymentConfirmation => 'Awaiting Payment',
        JobRequestStatus.awaitingOfflineConfirmation => 'Awaiting Cash Confirm',
        JobRequestStatus.completed => 'Completed',
      };

  static JobRequestStatus fromString(String s) => switch (s) {
        'accepted' => JobRequestStatus.accepted,
        'rejected' => JobRequestStatus.rejected,
        'awaiting_payment_confirmation' =>
          JobRequestStatus.awaitingPaymentConfirmation,
        'awaiting_offline_confirmation' =>
          JobRequestStatus.awaitingOfflineConfirmation,
        'completed' => JobRequestStatus.completed,
        _ => JobRequestStatus.pending,
      };
}
