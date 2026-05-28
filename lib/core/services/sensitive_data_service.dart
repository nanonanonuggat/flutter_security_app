import 'dart:convert';

import 'secure_vault_service.dart';

class SensitiveProfile {
  final String username;
  final String password;
  final String displayName;
  final String pinHash;
  final double balance;
  final String accountNumber;

  const SensitiveProfile({
    required this.username,
    required this.password,
    required this.displayName,
    required this.pinHash,
    required this.balance,
    required this.accountNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'displayName': displayName,
      'pinHash': pinHash,
      'balance': balance,
      'accountNumber': accountNumber,
    };
  }

  factory SensitiveProfile.fromMap(Map<String, dynamic> map) {
    return SensitiveProfile(
      username: map['username'] as String? ?? 'citizen.id',
      password: map['password'] as String? ?? 'Citizen@2026',
      displayName: map['displayName'] as String? ?? 'National Citizen',
      pinHash: map['pinHash'] as String,
      balance: (map['balance'] as num?)?.toDouble() ?? 12450000,
      accountNumber: map['accountNumber'] as String? ?? '9988776655',
    );
  }

  SensitiveProfile copyWith({
    String? username,
    String? password,
    String? displayName,
    String? pinHash,
    double? balance,
    String? accountNumber,
  }) {
    return SensitiveProfile(
      username: username ?? this.username,
      password: password ?? this.password,
      displayName: displayName ?? this.displayName,
      pinHash: pinHash ?? this.pinHash,
      balance: balance ?? this.balance,
      accountNumber: accountNumber ?? this.accountNumber,
    );
  }
}

class SensitiveDataService {
  SensitiveDataService._();

  static final SensitiveDataService instance = SensitiveDataService._();
  static const String _profileKey = 'sensitive.user.profile';

  Future<void> ensureInitialized({required String pinHash}) async {
    final encryptedProfile = await SecureVaultService.instance.read(
      _profileKey,
    );
    if (encryptedProfile != null) {
      return;
    }

    final seededProfile = SensitiveProfile(
      username: 'citizen.id',
      password: 'Citizen@2026',
      displayName: 'National Citizen',
      pinHash: pinHash,
      balance: 12450000,
      accountNumber: '9988776655',
    );

    await _persist(seededProfile);
  }

  Future<SensitiveProfile> loadProfile() async {
    final payload = await SecureVaultService.instance.read(_profileKey);
    if (payload == null) {
      throw StateError('Sensitive profile has not been initialized.');
    }

    return SensitiveProfile.fromMap(
      jsonDecode(payload) as Map<String, dynamic>,
    );
  }

  Future<void> updateBalance(double newBalance) async {
    final profile = await loadProfile();
    await _persist(profile.copyWith(balance: newBalance));
  }

  Future<void> updatePinHash(String pinHash) async {
    final profile = await loadProfile();
    await _persist(profile.copyWith(pinHash: pinHash));
  }

  Future<void> _persist(SensitiveProfile profile) async {
    await SecureVaultService.instance.write(
      _profileKey,
      jsonEncode(profile.toMap()),
    );
  }
}
