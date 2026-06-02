import 'package:flutter/foundation.dart';
import '../models/notification_payload.dart';

/// Router bağımlılığını kesmek için callback pattern kullanılır.
/// App katmanı başlangıçta `onNavigate` atar:
/// `NotificationDeepLinkHandler.onNavigate = (path, params) => router.go(path);`
abstract final class NotificationDeepLinkHandler {
  static void Function(String path, Map<String, dynamic>? params)? onNavigate;

  static void handle(NotificationPayload payload) {
    switch (payload.actionType) {
      case NotificationActionType.navigate:
        _navigate(payload);
      case NotificationActionType.openUrl:
        debugPrint('[Notification] Open URL: ${payload.url}');
      case NotificationActionType.dismiss:
      case NotificationActionType.approval:
        break;
    }
  }

  static void _navigate(NotificationPayload payload) {
    final path = payload.path;
    if (path != null) {
      onNavigate?.call(
        path,
        payload.params.isNotEmpty ? payload.params : null,
      );
    }
  }
}
