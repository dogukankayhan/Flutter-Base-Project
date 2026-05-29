import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_router.dart' show rootKey;

final class Nav {
  Nav._();

  // Context-scoped helpers
  static Future<T?> push<T>(BuildContext context, String path, {Object? extra}) =>
      context.push<T>(path, extra: extra);

  static void go(BuildContext context, String path, {Object? extra}) =>
      context.go(path, extra: extra);

  static void pop<T extends Object?>(BuildContext context, [T? result]) =>
      context.pop<T>(result);

  static bool canPop(BuildContext context) => context.canPop();

  // Root-scoped helpers
  static bool canPopRoot() => rootKey.currentState?.canPop() ?? false;
  static void popRoot<T extends Object?>([T? result]) =>
      rootKey.currentState?.pop<T>(result);

  // Build-safe helpers
  static void goPostFrame(BuildContext context, String path, {Object? extra}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.go(path, extra: extra);
    });
  }

  static void pushPostFrame(BuildContext context, String path, {Object? extra}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) context.push(path, extra: extra);
    });
  }

  static void popPostFrame(BuildContext context, [Object? result]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted && context.canPop()) context.pop(result);
    });
  }

  static void popRootPostFrame([Object? result]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (canPopRoot()) popRoot(result);
    });
  }
}
