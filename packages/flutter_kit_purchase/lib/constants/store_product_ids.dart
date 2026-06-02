/// RevenueCat product ID constants.
/// Replace these with the real IDs from App Store Connect / Google Play Console
/// and the RevenueCat Dashboard.
abstract final class StoreProductIds {
  // ── RevenueCat API Keys ───────────────────────────────────────────────────
  static const String appleApiKey  = 'appl_REPLACE_WITH_YOUR_KEY';
  static const String googleApiKey = 'goog_REPLACE_WITH_YOUR_KEY';

  // ── Entitlement IDs (from RevenueCat Dashboard) ──────────────────────────
  static const String entitlementPremium = 'premium';

  // ── Subscription product IDs ─────────────────────────────────────────────
  static const String subMonthly = 'flutter_base_premium_monthly';
  static const String subAnnual  = 'flutter_base_premium_annual';

  // ── Consumable coin pack product IDs ─────────────────────────────────────
  static const String crystalSmall  = 'flutter_base_coins_100';
  static const String crystalMedium = 'flutter_base_coins_550';
  static const String crystalLarge  = 'flutter_base_coins_1200';
  static const String crystalMega   = 'flutter_base_coins_2500';
  static const String crystalUltra  = 'flutter_base_coins_6500';
}
