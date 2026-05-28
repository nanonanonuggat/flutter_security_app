import 'dart:convert';

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'amount': amount,
      'recipientName': recipientName,
      'recipientAccount': recipientAccount,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'notes': notes,
      'isEncrypted': isEncrypted,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      type: TransactionType.values.firstWhere(
        (value) => value.name == map['type'],
        orElse: () => TransactionType.transfer,
      ),
      amount: (map['amount'] as num).toDouble(),
      recipientName: map['recipientName'] as String,
      recipientAccount: map['recipientAccount'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      status: TransactionStatus.values.firstWhere(
        (value) => value.name == map['status'],
        orElse: () => TransactionStatus.pending,
      ),
      notes: map['notes'] as String?,
      isEncrypted: map['isEncrypted'] as bool? ?? true,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory TransactionModel.fromJson(String source) {
    return TransactionModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}
