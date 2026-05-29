import 'dart:async';

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/session_timeout_service.dart';

final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();

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
    with WidgetsBindingObserver, RouteAware {
  bool _handlingExpiry = false;
  final Object _ownerId = Object();
  ModalRoute<void>? _route;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  @override
  void dispose() {
    if (_route != null) {
      appRouteObserver.unsubscribe(this);
    }
    WidgetsBinding.instance.removeObserver(this);
    SessionTimeoutService.instance.stop(ownerId: _ownerId);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _validateSession();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextRoute = ModalRoute.of(context);
    if (nextRoute is PageRoute && nextRoute != _route) {
      if (_route != null) {
        appRouteObserver.unsubscribe(this);
      }
      _route = nextRoute;
      appRouteObserver.subscribe(this, nextRoute);
    }
  }

  @override
  void didPush() {
    _resetTimer();
  }

  @override
  void didPopNext() {
    _resetTimer();
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
      ownerId: _ownerId,
      timeout: AuthService.sessionTimeout,
      onTimeout: () async {
        await AuthService.instance.clearSession();
        await _handleSessionExpired();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _resetTimer,
      onPanDown: (_) => _resetTimer(),
      child: widget.child,
    );
  }
}
