import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/managers/navigation_manager/guards.dart';
import 'view/home_screen.dart';
import 'view/architecture_showcase_screen.dart';

final class HomeCoordinator {
  const HomeCoordinator(this.navigatorKey);

  final GlobalKey<NavigatorState> navigatorKey;

  static const String path = '/home';
  static const String showcasePath = '/architecture-showcase';

  void show() => navigatorKey.currentState?.context.go(path);

  void pushShowcase() => navigatorKey.currentState?.context.push(showcasePath);

  List<GoRoute> get routes => [
        GoRoute(
          path: path,
          parentNavigatorKey: navigatorKey,
          pageBuilder: (context, state) => fadeTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: showcasePath,
          parentNavigatorKey: navigatorKey,
          pageBuilder: (context, state) => fadeTransitionPage(
            key: state.pageKey,
            child: const ArchitectureShowcaseScreen(),
          ),
        ),
      ];
}
