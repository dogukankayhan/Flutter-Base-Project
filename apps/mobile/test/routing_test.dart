import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_kit/core/managers/navigation_manager/app_router.dart';
import 'package:flutter_base_kit/core/managers/navigation_manager/guards.dart';

void main() {
  testWidgets('AuthGate login flow: /settings requires login', (tester) async {
    final auth = TestAuthRouterNotifier();
    final router = AppRouter.create(auth: auth, initialLocation: '/settings');

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );

    await tester.pumpAndSettle();
    expect(find.text('Giriş'), findsOneWidget);

    auth.signIn();
    await tester.pumpAndSettle();

    expect(find.text('Ayarlar'), findsOneWidget);
  });
}
