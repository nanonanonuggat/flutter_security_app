import 'dart:async';

class SessionTimeoutService {
  SessionTimeoutService._();

  static final SessionTimeoutService instance = SessionTimeoutService._();

  Timer? _timer;

  void start({
    required Duration timeout,
    required Future<void> Function() onTimeout,
  }) {
    stop();
    _timer = Timer(timeout, () {
      onTimeout();
    });
  }

  void reset({
    required Duration timeout,
    required Future<void> Function() onTimeout,
  }) {
    start(timeout: timeout, onTimeout: onTimeout);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
