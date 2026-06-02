import 'package:flutter/material.dart';

/// Oyunun tüm renk ve tema sabitleri burada yönetilir.
class AppColors {
  AppColors._();

  // ── Arka plan renkleri ──────────────────────────────────────────────────────
  static const Color background     = Color(0xFF0D0905); // Ana arka plan
  static const Color panel          = Color(0xFF13100A); // Panel/kart arka planı
  static const Color surface        = Color(0xFF1A1208); // Yüzey (header, sidebar)
  static const Color surfaceLight   = Color(0xFF2A1C06); // Açık yüzey (aktif buton)

  // ── Kenarlık renkleri ────────────────────────────────────────────────────────
  static const Color border         = Color(0xFF3D2B0A); // Genel kenarlık
  static const Color borderActive   = Color(0xFF5C3A0A); // Aktif/hover kenarlık

  // ── Vurgu renkleri ──────────────────────────────────────────────────────────
  static const Color gold           = Color(0xFFD4A017); // Altın (seçili nav, vurgu)
  static const Color cyan           = Color(0xFF00E5FF); // Cyan (tech tree, ERA)
  static const Color cyanDark       = Color(0xFF002A33); // Cyan arka plan dolgusu

  // ── Eylem / bilgi renkleri ───────────────────────────────────────────────────
  static const Color amber          = Colors.amber;      // Altın/para
  static const Color success        = Color(0xFF4CAF50); // Yeşil (XP bar)
  static const Color danger         = Colors.red;        // Kırmızı (uyarı)
  static const Color darkButton     = Color(0xFF282828); // Alt bar butonu

  // ── Metin renkleri ───────────────────────────────────────────────────────────
  static const Color textPrimary    = Colors.white;
  static const Color textSecondary  = Colors.white70;
  static const Color textMuted      = Colors.grey;
  static const Color textDisabled   = Colors.white54;

  // ── Kart arka plan renkleri (inşaat kartları) ────────────────────────────────
  static const Color cardBaraka     = Color(0xFF2A1A08);
  static const Color cardResidance  = Color(0xFF08182A);
  static const Color cardKomando    = Color(0xFF0A1A0A);

  // ── Dashboard Renkleri ──────────────────────────────────────────────────────
  static const Color cardBg         = Color(0xFF140D04); // Koyu kahve/siyah kart
  static const Color cardBorder     = Color(0xFF2D1F0A); // Kart kenarlığı
  static const Color requirementBg  = Color(0xFF1A1208); // Gereksinim listesi öğesi
  static const Color statsGlow      = Color(0xFFFFD700); // Sarımtırak parlama
  static const Color eraOrange      = Color(0xFFFF9800); // Çağ turuncusu

  // ── Sıralama kartı renkleri ──────────────────────────────────────────────────
  static const Color rankCardYou    = Color(0xFF0E1E0A);
  static const Color rankCardOther  = Color(0xFF1A1208);
}
