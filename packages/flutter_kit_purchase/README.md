# flutter_kit_purchase

In-app purchase layer for flutter_base_kit monorepo. Wraps RevenueCat (`purchases_flutter`) with a clean API for consumable packs and subscription plans.

## Features

- `RevenueCatManager` — single instance for all purchase operations
- Consumable crystal packs with fallback placeholders
- Monthly and annual subscription plans
- `PurchaseResult` sealed class for exhaustive result handling
- Purchase restore support (required by App Store)
- Premium entitlement check

## Setup

### 1. Update product IDs

Edit `lib/constants/store_product_ids.dart` with your own App Store / Play Store product identifiers:

```dart
abstract final class StoreProductIds {
  static const String appleApiKey  = 'appl_YOUR_KEY';
  static const String googleApiKey = 'goog_YOUR_KEY';

  // Consumables
  static const String crystalSmall  = 'crystal_100';
  static const String crystalMedium = 'crystal_550';
  // ...

  // Subscriptions
  static const String subMonthly = 'sub_monthly';
  static const String subAnnual  = 'sub_annual';

  // Entitlement
  static const String entitlementPremium = 'premium';
}
```

### 2. Initialise

```dart
// At app startup
await RevenueCatManager.instance.init();

// After user logs in
await RevenueCatManager.instance.logIn(userId);

// After user logs out
await RevenueCatManager.instance.logOut();
```

## Loading Products

```dart
final offerings = await RevenueCatManager.instance.fetchOfferings();

// Consumable packs — mapped from current offering
final packs = RevenueCatManager.instance.buildCrystalPacks(offerings);
// CrystalPack: productId, title, crystalAmount, localizedPrice, bonusLabel, isBestValue

// Subscription plans — mapped from current offering
final plans = RevenueCatManager.instance.buildSubscriptionPlans(offerings);
// SubscriptionPlan: productId, period, localizedPrice, savingsLabel, perks
```

If RevenueCat is unreachable, both methods return fallback placeholder lists so the UI can still render.

## Purchasing

```dart
final result = await RevenueCatManager.instance.purchase(package);

switch (result) {
  case PurchaseSuccess(:final productId):
    handleSuccess(productId);
  case PurchaseCancelled():
    // user cancelled — no error shown
  case PurchaseFailure(:final message, :final isNetworkError):
    showError(message);
  case RestoreSuccess(:final hasPremium):
    handleRestore(hasPremium);
}
```

Or use the `when` pattern if you extend `PurchaseResult`:

```dart
result.when(
  (success) => handleSuccess(success.productId),
  (cancelled) => {},
  (failure) => showError(failure.message),
  (restore) => handleRestore(restore.hasPremium),
);
```

## Restoring Purchases

Required by App Store guidelines. Provide a "Restore Purchases" button:

```dart
final result = await RevenueCatManager.instance.restorePurchases();
// Returns RestoreSuccess(hasPremium: true/false) or PurchaseFailure
```

## Checking Premium Entitlement

Always verify server-side entitlement — do not rely on local state:

```dart
final isPremium = await RevenueCatManager.instance.hasPremiumEntitlement();

// Full CustomerInfo if needed
final info = await RevenueCatManager.instance.getCustomerInfo();
final activeEntitlements = info?.entitlements.active;
```

## PurchaseResult Types

| Type | When |
|---|---|
| `PurchaseSuccess` | Purchase completed, entitlement active |
| `PurchaseCancelled` | User cancelled the native payment sheet |
| `PurchaseFailure` | Network error, already purchased, or unknown error |
| `RestoreSuccess` | Restore completed (hasPremium indicates entitlement status) |

## Dependencies

- `purchases_flutter`
