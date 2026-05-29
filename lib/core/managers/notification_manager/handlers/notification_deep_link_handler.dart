import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../managers/navigation_manager/app_router.dart' show rootKey;
import '../models/notification_payload.dart';

abstract final class NotificationDeepLinkHandler {
  static void handle(NotificationPayload payload) {
    final context = rootKey.currentContext;
    if (context == null) return;

    switch (payload.actionType) {
      case NotificationActionType.navigate:
        _navigate(context, payload);
      case NotificationActionType.openUrl:
        debugPrint('[Notification] Open URL: ${payload.url}');
      case NotificationActionType.dismiss:
      case NotificationActionType.approval:
        break;
    }
  }

  static void _navigate(BuildContext context, NotificationPayload payload) {
    final path = payload.path;
    if (path != null) {
      context.go(path, extra: payload.params.isNotEmpty ? payload.params : null);
    }
  }
}
