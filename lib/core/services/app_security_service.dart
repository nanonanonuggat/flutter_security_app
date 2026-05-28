import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:root_checker_plus/root_checker_plus.dart';

import 'auth_service.dart';

class AppSecurityState {
  final List<String> issues;

  const AppSecurityState({required this.issues});

  bool get isCompromised => issues.isNotEmpty;
}

class AppSecurityService {
  AppSecurityService._();

  static final AppSecurityService instance = AppSecurityService._();
  final NoScreenshot _noScreenshot = NoScreenshot.instance;

  Future<AppSecurityState> initialize() async {
    await AuthService.instance.ensureInitialized();
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return const AppSecurityState(issues: []);
    }
    await _enableScreenProtection();
    final issues = await _detectCompromiseIssues();
    return AppSecurityState(issues: issues);
  }

  Future<void> _enableScreenProtection() async {
    try {
      await _noScreenshot.screenshotOff();
    } catch (_) {
      // Best-effort only.
    }
  }

  Future<List<String>> _detectCompromiseIssues() async {
    if (kIsWeb) {
      return const [];
    }

    final issues = <String>[];

    try {
      if (Platform.isAndroid) {
        final isRooted = (await RootCheckerPlus.isRootChecker()) ?? false;
        final developerMode =
            (await RootCheckerPlus.isDeveloperMode()) ?? false;
        if (isRooted) {
          issues.add('Perangkat Android terdeteksi root.');
        }
        if (developerMode) {
          issues.add('Developer mode aktif pada perangkat Android.');
        }
      } else if (Platform.isIOS) {
        final isJailbroken = (await RootCheckerPlus.isJailbreak()) ?? false;
        if (isJailbroken) {
          issues.add('Perangkat iOS terdeteksi jailbreak.');
        }
      }
    } on MissingPluginException {
      return const [];
    } on PlatformException {
      return const [];
    } on UnsupportedError {
      return const [];
    }

    return issues;
  }
}
