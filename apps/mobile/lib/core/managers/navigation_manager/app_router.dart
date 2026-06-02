import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/splash/splash_coordinator.dart';
import '../../../features/home/view/home_screen.dart';
import 'guards.dart';

final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final class AppRouter {
  AppRouter._();

  static GoRouter create({
    required ChangeNotifier auth,
    String initialLocation = SplashCoordinator.path,
  }) {
    return GoRouter(
      navigatorKey: rootKey,
      initialLocation: initialLocation,
      refreshListenable: auth,
      debugLogDiagnostics: kDebugMode,
      redirect: (context, state) => null,
      routes: [
        SplashCoordinator.route(rootKey),
        GoRoute(
          path: '/home',
          parentNavigatorKey: rootKey,
          pageBuilder: (context, state) => fadeTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
        ),
      ],
    );
  }
}
