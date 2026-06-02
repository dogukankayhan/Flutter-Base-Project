import 'package:flutter/material.dart';

class JailbreakBlockApp extends StatelessWidget {
  const JailbreakBlockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF1a1a1a),
        body: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            // Prevent back navigation
            return;
          },
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.security_outlined,
                    size: 80,
                    color: Color(0xFFe74c3c),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Cihaz Güvenliği Uyarısı',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Bu uygulama güvenlik nedenileri ile jailbreak veya root\'lanmış cihazlarda çalıştırılamaz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFFbdbdbd),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
