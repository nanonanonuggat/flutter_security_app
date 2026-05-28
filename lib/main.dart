import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'core/services/app_security_service.dart';
import 'core/services/auth_service.dart';
import 'core/themes/app_theme.dart';
import 'core/widgets/security_blocked_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/login/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Security App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _AppGate(),
    );
  }
}

class _AppLaunchState {
  final AppSecurityState securityState;
  final bool hasSession;

  const _AppLaunchState({
    required this.securityState,
    required this.hasSession,
  });
}

class _AppGate extends StatefulWidget {
  const _AppGate();

  @override
  State<_AppGate> createState() => _AppGateState();
}

class _AppGateState extends State<_AppGate> {
  late final Future<_AppLaunchState> _launchFuture;

  @override
  void initState() {
    super.initState();
    _launchFuture = _bootstrap();
  }

  Future<_AppLaunchState> _bootstrap() async {
    final securityState = await AppSecurityService.instance.initialize();
    final hasSession = securityState.isCompromised
        ? false
        : await AuthService.instance.hasActiveSession();
    return _AppLaunchState(
      securityState: securityState,
      hasSession: hasSession,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppLaunchState>(
      future: _launchFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryDark),
            ),
          );
        }

        final launchState = snapshot.data!;
        if (launchState.securityState.isCompromised) {
          return SecurityBlockedScreen(
            issues: launchState.securityState.issues,
          );
        }

        return launchState.hasSession
            ? const DashboardScreen()
            : const LoginScreen();
      },
    );
  }
}
