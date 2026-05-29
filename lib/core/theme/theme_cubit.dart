// ignore_for_file: unintended_html_in_doc_comment

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tema durumunu yöneten Cubit.
///
/// 3 mod destekler:
/// - [ThemeMode.system] → cihaz ayarını takip eder (varsayılan)
/// - [ThemeMode.light]  → her zaman light
/// - [ThemeMode.dark]   → her zaman dark
///
/// Seçim [SharedPreferences] ile kalıcı hale gelir.
///
/// Kullanım:
///   context.read<ThemeCubit>().setThemeMode(ThemeMode.dark);
///   context.read<ThemeCubit>().toggleTheme();
///
///   // Widget'ta dinleme:
///   BlocBuilder<ThemeCubit, ThemeMode>(
///     builder: (context, mode) => MaterialApp(themeMode: mode, ...),
///   )
class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'app_theme_mode';

  ThemeCubit() : super(ThemeMode.system);

  /// SharedPreferences'tan kaydedilmiş tema modunu yükle.
  /// Uygulama başlangıcında çağrılmalı.
  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null) {
      final mode = ThemeMode.values.firstWhere(
        (e) => e.name == stored,
        orElse: () => ThemeMode.system,
      );
      emit(mode);
    }
  }

  /// Tema modunu değiştir ve kaydet.
  /// System seçilirse kayıt silinir → sonraki açılışta varsayılan system olur.
  Future<void> setThemeMode(ThemeMode mode) async {
    debugPrint('[ThemeCubit] setThemeMode → ${mode.name}');
    emit(mode);
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.system) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, mode.name);
    }
  }

  /// Light ↔ Dark arası geçiş.
  /// System modundayken mevcut brightness'a göre tersine çevirir.
  Future<void> toggleTheme([BuildContext? context]) async {
    if (context != null) {
      final brightness = MediaQuery.platformBrightnessOf(context);
      debugPrint(brightness.name);
    }
    if (state == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // System modunda → mevcut brightness'a bak
      if (context != null) {
        final brightness = MediaQuery.platformBrightnessOf(context);
        await setThemeMode(
          brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
        );
      } else {
        await setThemeMode(ThemeMode.dark);
      }
    }
  }

  /// Mevcut modun karanlık olup olmadığını kontrol et.
  bool isDark([BuildContext? context]) {
    if (state == ThemeMode.dark) return true;
    if (state == ThemeMode.light) return false;
    // System mode
    if (context != null) {
      return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    }
    return false;
  }
}
