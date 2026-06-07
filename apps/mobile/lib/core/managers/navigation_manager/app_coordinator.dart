import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../features/login/login_coordinator.dart';
import '../../../features/register/register_coordinator.dart';
import '../../../features/home/home_coordinator.dart';

/// Root navigator key — tüm route'lar bu key üzerinden açılır.
final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Uygulama geneli MVVM-C Coordinator.
///
/// Her feature coordinator'ı kendi route'larını ve navigation metodlarını tanımlar.
/// AppCoordinator bunları bir araya getirir ve AppRouter'a sağlar.
///
/// Kullanım:
///   AppCoordinator.instance.login.show();
///   AppCoordinator.instance.home.pushShowcase();
final class AppCoordinator {
  AppCoordinator._()
      : login = LoginCoordinator(rootKey),
        register = RegisterCoordinator(rootKey),
        home = HomeCoordinator(rootKey);

  static final instance = AppCoordinator._();

  final LoginCoordinator login;
  final RegisterCoordinator register;
  final HomeCoordinator home;

  List<RouteBase> get routes => [
        login.route,
        register.route,
        ...home.routes,
      ];

  /// GoRouter redirect hook için merkezi yetki kontrolü.
  String? redirect({required bool isLoggedIn, required String path}) {
    if (!isLoggedIn) {
      if (path == HomeCoordinator.path || path == HomeCoordinator.showcasePath) {
        return LoginCoordinator.path;
      }
    } else {
      if (path == LoginCoordinator.path || path == RegisterCoordinator.path) {
        return HomeCoordinator.path;
      }
    }
    return null;
  }
}
