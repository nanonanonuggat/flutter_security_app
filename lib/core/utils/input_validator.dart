class ValidationResult {
  final bool isValid;
  final String? message;

  const ValidationResult._({required this.isValid, this.message});

  factory ValidationResult.valid() => const ValidationResult._(isValid: true);

  factory ValidationResult.invalid(String message) =>
      ValidationResult._(isValid: false, message: message);
}

class InputValidator {
  InputValidator._();

  static final RegExp _unsafePattern = RegExp(
    r'(<|>|;|--|/\*|\*/|\{|\}|\[|\]|\||`|\$)',
    caseSensitive: false,
  );
  static final RegExp _usernamePattern = RegExp(r'^[A-Za-z0-9._@-]{4,32}$');
  static final RegExp _pinPattern = RegExp(r'^[0-9]{6}$');
  static final RegExp _passwordPattern = RegExp(
    r'^[A-Za-z0-9!@#\$%\^&\*\(\)_\+\-=\.]{8,32}$',
  );
  static final RegExp _recipientPattern = RegExp(r"^[A-Za-z0-9 .,'-]{3,60}$");
  static final RegExp _accountPattern = RegExp(r'^[0-9]{8,20}$');

  static String normalize(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static bool containsUnsafePattern(String value) {
    return _unsafePattern.hasMatch(value);
  }

  static ValidationResult validateUsername(String value) {
    final normalized = normalize(value);
    if (normalized.isEmpty) {
      return ValidationResult.invalid('Username wajib diisi.');
    }
    if (containsUnsafePattern(normalized) ||
        !_usernamePattern.hasMatch(normalized)) {
      return ValidationResult.invalid(
        'Format username tidak aman atau tidak valid.',
      );
    }
    return ValidationResult.valid();
  }

  static ValidationResult validatePin(String value) {
    final normalized = value.trim();
    if (!_pinPattern.hasMatch(normalized)) {
      return ValidationResult.invalid('PIN harus 6 digit angka.');
    }
    return ValidationResult.valid();
  }

  static ValidationResult validatePassword(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return ValidationResult.invalid('Password wajib diisi.');
    }
    if (containsUnsafePattern(normalized) ||
        !_passwordPattern.hasMatch(normalized)) {
      return ValidationResult.invalid('Format password tidak valid.');
    }
    return ValidationResult.valid();
  }

  static ValidationResult validateRecipient(String value) {
    final normalized = normalize(value);
    if (normalized.isEmpty) {
      return ValidationResult.invalid('Nama penerima wajib diisi.');
    }
    if (containsUnsafePattern(normalized) ||
        !_recipientPattern.hasMatch(normalized)) {
      return ValidationResult.invalid(
        'Nama penerima mengandung karakter yang tidak diizinkan.',
      );
    }
    return ValidationResult.valid();
  }

  static ValidationResult validateAccountNumber(String value) {
    final normalized = value.trim();
    if (!_accountPattern.hasMatch(normalized)) {
      return ValidationResult.invalid('Nomor rekening harus 8-20 digit angka.');
    }
    return ValidationResult.valid();
  }

  static ValidationResult validateAmount(String value) {
    final normalized = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.isEmpty) {
      return ValidationResult.invalid('Nominal transfer wajib diisi.');
    }

    final amount = double.tryParse(normalized);
    if (amount == null || amount <= 0) {
      return ValidationResult.invalid('Nominal transfer tidak valid.');
    }
    if (amount > 25000000) {
      return ValidationResult.invalid(
        'Nominal melewati limit harian Rp 25.000.000.',
      );
    }
    return ValidationResult.valid();
  }

  static String sanitizeForPayload(String value) {
    return normalize(value).replaceAll(_unsafePattern, '');
  }

  static String maskAccount(String accountNumber) {
    if (accountNumber.length <= 4) {
      return accountNumber;
    }
    final visible = accountNumber.substring(accountNumber.length - 4);
    return '****$visible';
  }
}
