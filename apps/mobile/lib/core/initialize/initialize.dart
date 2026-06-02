import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_kit_firebase/firebase_setup.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_base_kit/core/localization/i18n/strings.g.dart';
import '../config/app_environment.dart';
import '../di/injection.dart';
import '../firebase/firebase_options_dev.dart' as dev;
import '../firebase/firebase_options_staging.dart' as staging;
import '../firebase/firebase_options_prod.dart' as prod;
import 'package:flutter_kit_network/core/config/api_config.dart';
import '../security/jailbreak_detector.dart';
import 'package:flutter_kit_ui/theme/theme_cubit.dart';

class Initialize {
  Initialize._();

  static bool isDeviceCompromised = false;
  static late ThemeCubit themeCubit;

  /// runApp öncesi çağrılır. Her sorumluluk kendi metodunda.
  static Future<void> prepare(AppEnvironment env) async {
    await _initBinding();
    await Future.wait([
      _initOrientation(),
      AppConfig.init(env),
    ]);
    await _initFirebase(env);
    await _initDI(env);
    await _initLocaleAndTheme();
  }

  /// Splash ekranında çağrılır — ağır işler burada yapılır.
  static Future<void> run() async {
    final results = await Future.wait([
      _initNotifications(),
      _checkJailbreak(),
    ]);
    isDeviceCompromised = results[1] as bool;
  }

  // ─────────────────────────────────────────────
  // Private init steps
  // ─────────────────────────────────────────────

  static Future<WidgetsBinding> _initBinding() async {
    final binding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: binding);
    return binding;
  }

  static Future<void> _initOrientation() =>
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

  static Future<void> _initFirebase(AppEnvironment env) async {
    final options = switch (env) {
      AppEnvironment.dev => dev.DefaultFirebaseOptions.currentPlatform,
      AppEnvironment.staging => staging.DefaultFirebaseOptions.currentPlatform,
      AppEnvironment.prod => prod.DefaultFirebaseOptions.currentPlatform,
    };
    await setupFirebase(options: options);
  }

  static Future<void> _initDI(AppEnvironment env) async {
    final apiConfig = ApiConfig(
      baseUrl: AppConfig.instance.baseUrl,
      enableLogging: !AppConfig.instance.isProd,
    );
    await Injection.init(apiConfig: apiConfig);
  }

  static Future<void> _initLocaleAndTheme() async {
    LocaleSettings.useDeviceLocale();
    themeCubit = ThemeCubit();
    await themeCubit.loadSavedTheme();
  }

  static Future<void> _initNotifications() => setupNotifications();

  static Future<bool> _checkJailbreak() =>
      JailbreakDetector.isDeviceCompromised();
}
