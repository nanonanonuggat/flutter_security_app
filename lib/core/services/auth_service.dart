import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../utils/input_validator.dart';
import 'api_service.dart';
import 'secure_vault_service.dart';
import 'sensitive_data_service.dart';

enum AuthLoginStatus {
  success,
  invalidCredentials,
  invalidPayload,
  dailyLocked,
}

class AuthLoginResult {
  final AuthLoginStatus status;
  final String message;
  final int remainingAttempts;
  final DateTime? lockedUntil;
  final String? sessionToken;

  const AuthLoginResult({
    required this.status,
    required this.message,
    required this.remainingAttempts,
    this.lockedUntil,
    this.sessionToken,
  });

  bool get isSuccess => status == AuthLoginStatus.success;
}

class AuthSecurityState {
  final int failedAttempts;
  final DateTime? lockedUntil;

  const AuthSecurityState({
    required this.failedAttempts,
    required this.lockedUntil,
  });

  factory AuthSecurityState.initial() {
    return const AuthSecurityState(failedAttempts: 0, lockedUntil: null);
  }

  bool get isLocked =>
      lockedUntil != null && DateTime.now().isBefore(lockedUntil!);

  bool get isDailyLock => isLocked;

  int get remainingAttempts => AuthService.maxLoginAttempts - failedAttempts;

  Duration get remainingLockDuration {
    if (lockedUntil == null) {
      return Duration.zero;
    }
    final remaining = lockedUntil!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Map<String, dynamic> toMap() {
    return {
      'failedAttempts': failedAttempts,
      'lockedUntil': lockedUntil?.toIso8601String(),
    };
  }

  factory AuthSecurityState.fromMap(Map<String, dynamic> map) {
    return AuthSecurityState(
      failedAttempts: map['failedAttempts'] as int? ?? 0,
      lockedUntil: map['lockedUntil'] == null
          ? null
          : DateTime.tryParse(map['lockedUntil'] as String),
    );
  }

  AuthSecurityState copyWith({
    int? failedAttempts,
    DateTime? lockedUntil,
    bool clearLock = false,
  }) {
    return AuthSecurityState(
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockedUntil: clearLock ? null : (lockedUntil ?? this.lockedUntil),
    );
  }
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const Duration sessionTimeout = Duration(minutes: 9);
  static const int maxLoginAttempts = 5;
  static const Duration dailyLockDuration = Duration(hours: 24);
  static const String defaultPin = '123456';
  static const String defaultPassword = 'Citizen@2026';
  static const String _sessionKey = 'auth.session.payload';
  static const String _securityStateKey = 'auth.security.state';

  Future<void> ensureInitialized() async {
    await SensitiveDataService.instance.ensureInitialized(
      pinHash: hashPin(defaultPin),
    );
    final state = await SecureVaultService.instance.read(_securityStateKey);
    if (state == null) {
      await _persistSecurityState(AuthSecurityState.initial());
    }
  }

  String hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  Future<AuthSecurityState> getSecurityState() async {
    await ensureInitialized();
    final payload = await SecureVaultService.instance.read(_securityStateKey);
    var state = payload == null
        ? AuthSecurityState.initial()
        : AuthSecurityState.fromMap(
            jsonDecode(payload) as Map<String, dynamic>,
          );

    if (state.lockedUntil != null &&
        DateTime.now().isAfter(state.lockedUntil!)) {
      state = AuthSecurityState.initial();
      await _persistSecurityState(state);
    }

    return state;
  }

  Future<AuthLoginResult> login({
    required String username,
    required String password,
    required String pin,
  }) async {
    await ensureInitialized();

    final usernameValidation = InputValidator.validateUsername(username);
    if (!usernameValidation.isValid) {
      return AuthLoginResult(
        status: AuthLoginStatus.invalidPayload,
        message: usernameValidation.message!,
        remainingAttempts: maxLoginAttempts,
      );
    }

    final passwordValidation = InputValidator.validatePassword(password);
    if (!passwordValidation.isValid) {
      return AuthLoginResult(
        status: AuthLoginStatus.invalidPayload,
        message: passwordValidation.message!,
        remainingAttempts: maxLoginAttempts,
      );
    }

    final pinValidation = InputValidator.validatePin(pin);
    if (!pinValidation.isValid) {
      return AuthLoginResult(
        status: AuthLoginStatus.invalidPayload,
        message: pinValidation.message!,
        remainingAttempts: maxLoginAttempts,
      );
    }

    final securityState = await getSecurityState();
    if (securityState.isLocked) {
      return AuthLoginResult(
        status: AuthLoginStatus.dailyLocked,
        message:
            'Login diblokir 24 jam karena 5x gagal memasukkan password atau PIN.',
        remainingAttempts: maxLoginAttempts,
        lockedUntil: securityState.lockedUntil,
      );
    }

    final profile = await SensitiveDataService.instance.loadProfile();
    final normalizedUsername = InputValidator.normalize(username);
    final normalizedPassword = password.trim();
    final hashedPin = hashPin(pin);

    if (normalizedUsername != profile.username ||
        normalizedPassword != profile.password ||
        hashedPin != profile.pinHash) {
      return _registerFailedAttempt(securityState);
    }

    final response = await ApiService.instance.login(
      username: normalizedUsername,
      pinHash: hashedPin,
    );
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    final responsePayload = responseBody['response'] as Map<String, dynamic>;
    final sessionToken = responsePayload['sessionToken'] as String;

    await _persistSecurityState(AuthSecurityState.initial());
    await _createSession(
      username: normalizedUsername,
      sessionToken: sessionToken,
    );

    return AuthLoginResult(
      status: AuthLoginStatus.success,
      message: 'Login aman berhasil dibuat.',
      remainingAttempts: maxLoginAttempts,
      sessionToken: sessionToken,
    );
  }

  Future<AuthLoginResult> _registerFailedAttempt(
    AuthSecurityState securityState,
  ) async {
    final updatedAttempts = securityState.failedAttempts + 1;

    if (updatedAttempts < maxLoginAttempts) {
      final updatedState = securityState.copyWith(
        failedAttempts: updatedAttempts,
      );
      await _persistSecurityState(updatedState);
      final remaining = updatedState.remainingAttempts;
      return AuthLoginResult(
        status: AuthLoginStatus.invalidCredentials,
        message: updatedAttempts == 1
            ? 'Peringatan: kesempatan anda 5x sebelum aplikasi dikunci 24 jam. Sisa percobaan saat ini ${remaining}x.'
            : 'Password atau PIN salah. Sisa kesempatan login ${remaining}x.',
        remainingAttempts: remaining,
      );
    }

    final lockedState = AuthSecurityState(
      failedAttempts: 0,
      lockedUntil: DateTime.now().add(dailyLockDuration),
    );
    await _persistSecurityState(lockedState);
    return AuthLoginResult(
      status: AuthLoginStatus.dailyLocked,
      message:
          'Password atau PIN salah 5x. Aplikasi dikunci selama 24 jam untuk mengantisipasi brute force.',
      remainingAttempts: maxLoginAttempts,
      lockedUntil: lockedState.lockedUntil,
    );
  }

  Future<void> _createSession({
    required String username,
    required String sessionToken,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    await SecureVaultService.instance.write(
      _sessionKey,
      jsonEncode({
        'username': username,
        'sessionToken': sessionToken,
        'createdAt': now,
        'lastActivityAt': now,
      }),
    );
  }

  Future<bool> hasActiveSession() async {
    final payload = await SecureVaultService.instance.read(_sessionKey);
    if (payload == null) {
      return false;
    }

    final session = jsonDecode(payload) as Map<String, dynamic>;
    final lastActivity = DateTime.tryParse(
      session['lastActivityAt'] as String? ?? '',
    );
    if (lastActivity == null) {
      await clearSession();
      return false;
    }

    if (DateTime.now().toUtc().difference(lastActivity) > sessionTimeout) {
      await clearSession();
      return false;
    }

    return true;
  }

  Future<void> touchSession() async {
    final payload = await SecureVaultService.instance.read(_sessionKey);
    if (payload == null) {
      return;
    }

    final session = jsonDecode(payload) as Map<String, dynamic>;
    session['lastActivityAt'] = DateTime.now().toUtc().toIso8601String();
    await SecureVaultService.instance.write(_sessionKey, jsonEncode(session));
  }

  Future<void> clearSession() async {
    await SecureVaultService.instance.delete(_sessionKey);
  }

  Future<void> _persistSecurityState(AuthSecurityState state) async {
    await SecureVaultService.instance.write(
      _securityStateKey,
      jsonEncode(state.toMap()),
    );
  }
}
