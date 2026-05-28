import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/session_timeout_service.dart';

class SessionGuard extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onSessionExpired;

  const SessionGuard({
    super.key,
    required this.child,
    required this.onSessionExpired,
  });

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard>
    with WidgetsBindingObserver {
  bool _handlingExpiry = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SessionTimeoutService.instance.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _validateSession();
    }
  }

  Future<void> _validateSession() async {
    final hasSession = await AuthService.instance.hasActiveSession();
    if (!hasSession) {
      await _handleSessionExpired();
      return;
    }
    _resetTimer();
  }

  Future<void> _handleSessionExpired() async {
    if (_handlingExpiry) {
      return;
    }
    _handlingExpiry = true;
    await widget.onSessionExpired();
  }

  void _resetTimer() {
    unawaited(AuthService.instance.touchSession());
    SessionTimeoutService.instance.reset(
      timeout: AuthService.sessionTimeout,
      onTimeout: () async {
        await AuthService.instance.clearSession();
        await _handleSessionExpired();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
