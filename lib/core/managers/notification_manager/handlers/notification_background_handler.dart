import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification_channel.dart';
import '../extensions/remote_message_ext.dart';

/// Uygulamanın arka planda veya kapalı olduğu durumda FCM mesajlarını yakalar.
/// Bu fonksiyon ayrı bir Dart isolate'inde çalışır — UI'a erişemez.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final payload = message.toPayload();

  // Sadece data-only mesajlarda (notification alanı yoksa) yerel bildirim göster
  if (message.notification == null) {
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );

    await plugin.show(
      id: message.hashCode,
      title: payload.title ?? 'base project',
      body: payload.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          AppNotificationChannel.general.id,
          AppNotificationChannel.general.name,
          channelDescription: AppNotificationChannel.general.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
