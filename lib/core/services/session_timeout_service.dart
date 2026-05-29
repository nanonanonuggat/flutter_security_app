import 'dart:async';

class SessionTimeoutService {
  SessionTimeoutService._();

  static final SessionTimeoutService instance = SessionTimeoutService._();

  Timer? _timer;
  Object? _ownerId;

  void start({
    required Object ownerId,
    required Duration timeout,
    required Future<void> Function() onTimeout,
  }) {
    stop(ownerId: _ownerId);
    _ownerId = ownerId;
    _timer = Timer(timeout, () {
      onTimeout();
    });
  }

  void reset({
    required Object ownerId,
    required Duration timeout,
    required Future<void> Function() onTimeout,
  }) {
    start(ownerId: ownerId, timeout: timeout, onTimeout: onTimeout);
  }

  void stop({Object? ownerId}) {
    if (ownerId != null && _ownerId != ownerId) {
      return;
    }
    _timer?.cancel();
    _timer = null;
    _ownerId = null;
  }
}
