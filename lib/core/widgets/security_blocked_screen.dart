import 'package:flutter/material.dart';

class SecurityBlockedScreen extends StatelessWidget {
  final List<String> issues;

  const SecurityBlockedScreen({super.key, required this.issues});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.security, size: 88, color: Colors.redAccent),
                  const SizedBox(height: 24),
                  const Text(
                    'Akses Diblokir',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aplikasi mendeteksi kondisi perangkat yang tidak aman. Tutup akses sampai perangkat kembali trusted.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ...issues.map(
                    (issue) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(issue)),
                        ],
                      ),
                    ),
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
