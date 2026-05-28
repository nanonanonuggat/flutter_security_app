enum TransactionType { transfer, receive, payment, topup }

enum TransactionStatus { success, pending, failed }

class TransactionModel {
  final String id;
  final TransactionType type;
  final double amount;
  final String recipientName;
  final String recipientAccount;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? notes;
  final bool isEncrypted;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.recipientName,
    required this.recipientAccount,
    required this.timestamp,
    required this.status,
    this.notes,
    this.isEncrypted = true,
  });

  bool get isCredit =>
      type == TransactionType.receive || type == TransactionType.topup;

  bool get isDebit =>
      type == TransactionType.transfer || type == TransactionType.payment;

  String get typeLabel {
    switch (type) {
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.receive:
        return 'Terima Dana';
      case TransactionType.payment:
        return 'Pembayaran';
      case TransactionType.topup:
        return 'Top Up';
    }
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.success:
        return 'Berhasil';
      case TransactionStatus.pending:
        return 'Diproses';
      case TransactionStatus.failed:
        return 'Gagal';
    }
  }
}
