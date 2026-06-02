import 'package:flutter/foundation.dart';
import 'package:flutter_kit_network/core/di/service_locator.dart';

/// Active cubit helper fonksiyonları
/// GetIt kullanarak cubit'leri key'li veya key'siz register/unregister eder
///
/// Bu fonksiyonlar aynı tipten birden fazla ekran açıkken (örn: 2 detail ekranı)
/// bunları ayırt etmek için kullanılır.

/// Aktif kayıtları takip et (debug & getAllActive için)
final Set<String> _activeKeys = {};

/// Aktif cubit'i yayınla (register et)
void publishActive<T extends Object>(T instance, {String? key}) {
  final instanceName = key ?? '_default_${T.toString()}';

  if (getIt.isRegistered<T>(instanceName: instanceName)) {
    // Debug modda uyar: aynı key ile tekrar publish ediliyor
    assert(() {
      debugPrint(
        '[ActiveCubit] ⚠️ Override: $instanceName was already registered. '
        'Did you forget to pass activeKey for multiple instances of $T?',
      );
      return true;
    }());
    getIt.unregister<T>(instanceName: instanceName);
  }

  getIt.registerSingleton<T>(instance, instanceName: instanceName);
  _activeKeys.add(instanceName);
}

/// Aktif cubit yayınını kaldır (unregister)
void unpublishActive<T extends Object>({String? key}) {
  final instanceName = key ?? '_default_${T.toString()}';

  if (getIt.isRegistered<T>(instanceName: instanceName)) {
    getIt.unregister<T>(instanceName: instanceName);
  }
  _activeKeys.remove(instanceName);
}

/// Aktif cubit'i al (nullable)
T? getActiveOrNull<T extends Object>({String? key}) {
  final instanceName = key ?? '_default_${T.toString()}';

  if (getIt.isRegistered<T>(instanceName: instanceName)) {
    return getIt<T>(instanceName: instanceName);
  }
  return null;
}

/// Aktif cubit'i al (non-null, bulamazsa fırlatır)
T getActive<T extends Object>({String? key}) {
  final instance = getActiveOrNull<T>(key: key);
  if (instance == null) {
    throw ActiveCubitNotFoundException<T>(key);
  }
  return instance;
}

/// Şu an aktif olan tüm cubit key'lerini döndürür (debug/logging için)
Set<String> getAllActiveKeys() => Set.unmodifiable(_activeKeys);

/// Belirtilen tipte aktif cubit var mı?
bool hasActive<T extends Object>({String? key}) {
  final instanceName = key ?? '_default_${T.toString()}';
  return getIt.isRegistered<T>(instanceName: instanceName);
}

/// Custom exception - stack trace'de hemen görünür
class ActiveCubitNotFoundException<T> implements Exception {
  final String? key;
  const ActiveCubitNotFoundException(this.key);

  @override
  String toString() =>
      'ActiveCubitNotFoundException: No active $T found '
      '(key: ${key ?? "default"}). '
      'Active keys: ${_activeKeys.isEmpty ? "none" : _activeKeys.join(", ")}';
}
