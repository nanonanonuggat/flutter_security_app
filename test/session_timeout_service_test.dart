import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_security_app/core/services/session_timeout_service.dart';

void main() {
  test('ignores stop calls from stale owners', () async {
    final service = SessionTimeoutService.instance;
    final ownerA = Object();
    final ownerB = Object();
    final completer = Completer<void>();

    service.reset(
      ownerId: ownerA,
      timeout: const Duration(milliseconds: 200),
      onTimeout: () async {},
    );
    service.reset(
      ownerId: ownerB,
      timeout: const Duration(milliseconds: 40),
      onTimeout: () async {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    service.stop(ownerId: ownerA);

    await expectLater(completer.future, completes);
    service.stop(ownerId: ownerB);
  });
}
