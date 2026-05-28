import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/input_validator.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();
  static const String baseUrl = 'https://api.rpay-secure.local';

  Future<http.Response> login({
    required String username,
    required String pinHash,
  }) async {
    final request = http.Request('POST', Uri.parse('$baseUrl/auth/login'))
      ..headers.addAll({'Content-Type': 'application/json'})
      ..body = jsonEncode({
        'username': InputValidator.sanitizeForPayload(username),
        'pinHash': pinHash,
        'device': 'mobile-app',
      });

    return _fakeDispatch(request, {
      'status': 'ok',
      'sessionToken': 'fake-session-${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Login accepted by internal secure gateway.',
    });
  }

  Future<http.Response> submitTransfer({
    required String recipientName,
    required String recipientAccount,
    required double amount,
  }) async {
    final request =
        http.Request('POST', Uri.parse('$baseUrl/transactions/secure-transfer'))
          ..headers.addAll({'Content-Type': 'application/json'})
          ..body = jsonEncode({
            'recipientName': InputValidator.sanitizeForPayload(recipientName),
            'recipientAccount': InputValidator.maskAccount(recipientAccount),
            'amount': amount,
            'channel': 'rpay-mobile',
          });

    return _fakeDispatch(request, {
      'status': 'queued',
      'referenceId': 'TRX-${DateTime.now().millisecondsSinceEpoch}',
      'message': 'Transfer payload accepted by fake internal API.',
    });
  }

  Future<http.Response> _fakeDispatch(
    http.Request request,
    Map<String, dynamic> responseBody,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    final envelope = {
      'request': {
        'method': request.method,
        'url': request.url.toString(),
        'headers': request.headers,
        'body': jsonDecode(request.body),
      },
      'response': responseBody,
    };

    return http.Response(
      jsonEncode(envelope),
      200,
      headers: const {'content-type': 'application/json'},
      request: request,
    );
  }
}
