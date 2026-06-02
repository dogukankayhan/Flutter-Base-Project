import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_kit_firebase/notification/handlers/notification_background_handler.dart';
import 'package:flutter_kit_firebase/notification/notification_manager.dart';

/// Firebase paketinin init fonksiyonu.
/// [options] environment'a göre app katmanından verilir.
Future<void> setupFirebase({required FirebaseOptions options}) async {
  await Firebase.initializeApp(options: options);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}

/// Bildirim servisini başlatır. Splash ekranında çağrılır.
Future<void> setupNotifications() =>
    NotificationManager.instance.init().catchError((e) {
      debugPrint('[NotificationManager] init error: $e');
    });
