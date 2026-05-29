/// RevenueCat ürün ID sabitleri.
/// Bu değerleri App Store Connect / Google Play Console ve
/// RevenueCat Dashboard'dan aldığınız gerçek ID'lerle değiştirin.
abstract final class StoreProductIds {
  // ── RevenueCat API Key ───────────────────────────────────────────────────
  /// iOS için RevenueCat public API key
  static const String appleApiKey = 'appl_REPLACE_WITH_YOUR_KEY';

  /// Android için RevenueCat public API key
  static const String googleApiKey = 'goog_REPLACE_WITH_YOUR_KEY';

  // ── Entitlement ID'leri (RevenueCat Dashboard'dan) ──────────────────────
  static const String entitlementPremium = 'premium';

  // ── Abonelik ürün ID'leri ────────────────────────────────────────────────
  static const String subMonthly = 'flutter_base_premium_monthly';
  static const String subAnnual = 'flutter_base_premium_annual';

  // ── Kristal paketi ürün ID'leri ──────────────────────────────────────────
  static const String crystalSmall = 'flutter_base_crystal_100';
  static const String crystalMedium = 'flutter_base_crystal_550';
  static const String crystalLarge = 'flutter_base_crystal_1200';
  static const String crystalMega = 'flutter_base_crystal_2500';
  static const String crystalUltra = 'flutter_base_crystal_6500';
}
