import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/sensitive_data_service.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_input.dart';
import '../../core/widgets/security_lock_screen.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();

  AuthSecurityState? _securityState;
  bool _isLoading = true;
  bool _isSubmitting = false;
  Timer? _lockRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  void dispose() {
    _lockRefreshTimer?.cancel();
    _usernameController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _loadState() async {
    await AuthService.instance.ensureInitialized();
    final profile = await SensitiveDataService.instance.loadProfile();
    final securityState = await AuthService.instance.getSecurityState();
    if (!mounted) {
      return;
    }

    _usernameController.text = profile.username;
    setState(() {
      _securityState = securityState;
      _isLoading = false;
    });
    _scheduleLockRefresh(securityState);
  }

  void _scheduleLockRefresh(AuthSecurityState state) {
    _lockRefreshTimer?.cancel();
    if (!state.isLocked) {
      return;
    }

    _lockRefreshTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      final nextState = await AuthService.instance.getSecurityState();
      if (!mounted) {
        return;
      }
      if (!nextState.isLocked) {
        _lockRefreshTimer?.cancel();
      }
      setState(() {
        _securityState = nextState;
      });
    });
  }

  Future<void> _login() async {
    setState(() {
      _isSubmitting = true;
    });

    final result = await AuthService.instance.login(
      username: _usernameController.text,
      password: _passwordController.text,
      pin: _pinController.text,
    );
    final latestState = await AuthService.instance.getSecurityState();

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
      _securityState = latestState;
    });
    _scheduleLockRefresh(latestState);

    if (result.isSuccess) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _securityState == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryDark),
        ),
      );
    }

    if (_securityState!.isLocked) {
      return SecurityLockScreen(
        remainingDuration: _securityState!.remainingLockDuration,
        isDailyLock: _securityState!.isDailyLock,
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.cardGradient,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: AppColors.textWhite,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Rpay',
                          style: TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pay with Rupiah',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Secure Access',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Demo username: citizen.id | Demo password: Citizen@2026 | Demo PIN: 123456',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomInput(
                    label: 'Username',
                    hint: 'Masukkan username',
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    maxLength: 32,
                    enableSuggestions: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[A-Za-z0-9._@-]'),
                      ),
                    ],
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  const SizedBox(height: 20),
                  CustomInput(
                    label: 'Password',
                    hint: 'Masukkan password',
                    controller: _passwordController,
                    isPassword: true,
                    keyboardType: TextInputType.visiblePassword,
                    maxLength: 32,
                    enableSuggestions: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[A-Za-z0-9!@#\$%\^&\*\(\)_\+\-=\.]"),
                      ),
                    ],
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  const SizedBox(height: 20),
                  CustomInput(
                    label: 'PIN',
                    hint: 'Masukkan 6 digit PIN',
                    controller: _pinController,
                    isPassword: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    prefixIcon: const Icon(Icons.pin_outlined),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: _isSubmitting ? 'Memverifikasi...' : 'Masuk ke Rpay',
                    onPressed: _isSubmitting ? null : _login,
                    icon: Icons.lock_open_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
