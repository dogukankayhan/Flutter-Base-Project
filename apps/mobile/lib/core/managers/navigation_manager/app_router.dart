import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../../core/splash/splash_coordinator.dart';
import 'app_coordinator.dart';
import 'guards.dart';

export 'app_coordinator.dart' show rootKey;

final class AppRouter {
  AppRouter._();

  static GoRouter create({
    required ChangeNotifier auth,
    String initialLocation = SplashCoordinator.path,
  }) {
    final coordinator = AppCoordinator.instance;

    return GoRouter(
      navigatorKey: rootKey,
      initialLocation: initialLocation,
      refreshListenable: auth,
      debugLogDiagnostics: kDebugMode,
      redirect: (context, state) {
        if (state.uri.path == SplashCoordinator.path) return null;
        return coordinator.redirect(
          isLoggedIn: (auth as AuthRouterNotifier).isLoggedIn,
          path: state.uri.path,
        );
      },
      routes: [
        SplashCoordinator.route(rootKey),
        ...coordinator.routes,
      ],
    );
  }
}
