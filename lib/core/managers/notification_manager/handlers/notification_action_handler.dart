import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_payload.dart';

/// App arka planda/kapalıyken action button'a tıklanınca bu fonksiyon çalışır.
/// Ayrı bir Dart isolate'inde çalışır — DI, BuildContext veya UI'a erişemez.
/// Sadece HTTP isteği veya SharedPreferences gibi stateless işlemler yapılabilir.
@pragma('vm:entry-point')
void notificationActionBackgroundHandler(NotificationResponse response) {
  final actionId = response.actionId;
  final approvalId = response.payload; // payload'a approvalId yazıyoruz

  if (approvalId == null || actionId == null) return;

  switch (actionId) {
    case NotificationActionId.approve:
      debugPrint('[Notification] Background APPROVE: $approvalId');
      // TODO: backend'e HTTP POST /approvals/$approvalId/approve
    case NotificationActionId.reject:
      debugPrint('[Notification] Background REJECT: $approvalId');
      // TODO: backend'e HTTP POST /approvals/$approvalId/reject
  }
}

/// App açıkken action button'a tıklanınca çağrılır.
/// DI ve navigator kullanılabilir.
typedef ApprovalCallback = Future<void> Function(
  String approvalId,
  bool isApproved,
);
