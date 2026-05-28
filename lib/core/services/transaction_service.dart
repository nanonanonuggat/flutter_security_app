import 'dart:convert';

import '../../models/transaction_model.dart';
import '../utils/input_validator.dart';
import 'api_service.dart';
import 'secure_vault_service.dart';
import 'sensitive_data_service.dart';

class TransactionService {
  TransactionService._();

  static final TransactionService instance = TransactionService._();
  static const String _transactionKey = 'transaction.secure.list';

  Future<void> ensureInitialized() async {
    final payload = await SecureVaultService.instance.read(_transactionKey);
    if (payload != null) {
      return;
    }
    await _persist(_seedTransactions());
  }

  Future<List<TransactionModel>> loadTransactions() async {
    await ensureInitialized();
    final encryptedPayload = await SecureVaultService.instance.read(
      _transactionKey,
    );
    if (encryptedPayload == null) {
      return const [];
    }

    final decoded = jsonDecode(encryptedPayload) as List<dynamic>;
    return decoded
        .map((item) => TransactionModel.fromMap(item as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> saveTransfer({
    required String recipientName,
    required String recipientAccount,
    required double amount,
  }) async {
    final recipientValidation = InputValidator.validateRecipient(recipientName);
    if (!recipientValidation.isValid) {
      throw ArgumentError(recipientValidation.message!);
    }

    final accountValidation = InputValidator.validateAccountNumber(
      recipientAccount,
    );
    if (!accountValidation.isValid) {
      throw ArgumentError(accountValidation.message!);
    }

    final amountValidation = InputValidator.validateAmount(amount.toString());
    if (!amountValidation.isValid) {
      throw ArgumentError(amountValidation.message!);
    }

    final profile = await SensitiveDataService.instance.loadProfile();
    if (amount > profile.balance) {
      throw StateError('Saldo tidak mencukupi untuk transfer ini.');
    }

    final apiResponse = await ApiService.instance.submitTransfer(
      recipientName: recipientName,
      recipientAccount: recipientAccount,
      amount: amount,
    );
    final responseBody = jsonDecode(apiResponse.body) as Map<String, dynamic>;
    final responsePayload = responseBody['response'] as Map<String, dynamic>;
    final referenceId = responsePayload['referenceId'] as String;

    final transactions = await loadTransactions();
    transactions.insert(
      0,
      TransactionModel(
        id: referenceId,
        type: TransactionType.transfer,
        amount: amount,
        recipientName: InputValidator.sanitizeForPayload(recipientName),
        recipientAccount: recipientAccount,
        timestamp: DateTime.now(),
        status: TransactionStatus.success,
        notes: 'Encrypted transfer saved locally with ref $referenceId.',
        isEncrypted: true,
      ),
    );

    await _persist(transactions);
    await SensitiveDataService.instance.updateBalance(profile.balance - amount);
  }

  Future<void> _persist(List<TransactionModel> transactions) async {
    final payload = jsonEncode(
      transactions.map((transaction) => transaction.toMap()).toList(),
    );
    await SecureVaultService.instance.write(_transactionKey, payload);
  }

  List<TransactionModel> _seedTransactions() {
    return [
      TransactionModel(
        id: 'seed-1',
        type: TransactionType.receive,
        amount: 5000000,
        recipientName: 'Kementerian Keuangan',
        recipientAccount: 'GOV001',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        status: TransactionStatus.success,
      ),
      TransactionModel(
        id: 'seed-2',
        type: TransactionType.transfer,
        amount: 2500000,
        recipientName: 'Budi Santoso',
        recipientAccount: '12345678',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        status: TransactionStatus.success,
      ),
      TransactionModel(
        id: 'seed-3',
        type: TransactionType.payment,
        amount: 375000,
        recipientName: 'PLN Pascabayar',
        recipientAccount: 'BILL-001',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        status: TransactionStatus.success,
      ),
    ];
  }
}
