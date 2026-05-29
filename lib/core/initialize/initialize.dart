import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_base_kit/core/localization/i18n/strings.g.dart';
import '../config/app_environment.dart';
import '../di/injection.dart';
import '../firebase/firebase_options_dev.dart' as dev;
import '../firebase/firebase_options_staging.dart' as staging;
import '../firebase/firebase_options_prod.dart' as prod;
import '../managers/notification_manager/handlers/notification_background_handler.dart';
import '../managers/notification_manager/notification_manager.dart';
// import '../managers/revenuecat_manager/revenuecat_manager.dart';
import '../security/jailbreak_detector.dart';
import '../theme/theme_cubit.dart';

class Initialize {
  Initialize._();

  static bool isDeviceCompromised = false;
  static late ThemeCubit themeCubit;

  /// mainCommon'da çağrılır — runApp öncesi tüm hazırlığı yapar.
  static Future<void> prepare(AppEnvironment env) async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: binding);

    await Future.wait([
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]),
      AppConfig.init(env),
    ]);

    await _initFirebase(env);
    await Injection.init();
    await _setup();
  }

  static Future<void> _initFirebase(AppEnvironment env) async {
    final options = switch (env) {
      AppEnvironment.dev => dev.DefaultFirebaseOptions.currentPlatform,
      AppEnvironment.staging => staging.DefaultFirebaseOptions.currentPlatform,
      AppEnvironment.prod => prod.DefaultFirebaseOptions.currentPlatform,
    };

    await Firebase.initializeApp(options: options);

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Splash screen'de çağrılır.
  static Future<void> run() async {
    final results = await Future.wait([
      // RevenueCatManager.instance.init(),
      NotificationManager.instance.init().catchError((e) {
        debugPrint('[NotificationManager] init error: $e');
      }),
      JailbreakDetector.isDeviceCompromised(),
    ]);
    isDeviceCompromised = results[1] as bool;
  }

  static Future<void> _setup() async {
    LocaleSettings.useDeviceLocale();
    themeCubit = ThemeCubit();
    await themeCubit.loadSavedTheme();
  }
}
