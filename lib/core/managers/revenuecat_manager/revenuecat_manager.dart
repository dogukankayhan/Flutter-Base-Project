import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart' hide PurchaseResult;
import 'constants/store_product_ids.dart';
import 'models/crystal_pack.dart';
import 'models/purchase_result.dart';
import 'models/subscription_plan.dart';

class RevenueCatManager {
  RevenueCatManager._();
  static final RevenueCatManager instance = RevenueCatManager._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  // ── Başlatma ──────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_initialized) return;

    await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.error);

    final config = PurchasesConfiguration(
      Platform.isIOS ? StoreProductIds.appleApiKey : StoreProductIds.googleApiKey,
    );

    await Purchases.configure(config);
    _initialized = true;
  }

  /// Kullanıcı girişi yapınca çağır — satın alımlar kullanıcıya bağlanır.
  Future<void> logIn(String userId) async {
    _assertInitialized();
    await Purchases.logIn(userId);
  }

  /// Kullanıcı çıkış yapınca çağır.
  Future<void> logOut() async {
    _assertInitialized();
    await Purchases.logOut();
  }

  // ── Ürün & Paket bilgileri ────────────────────────────────────────────────

  /// RevenueCat'ten mevcut teklifleri çeker.
  Future<Offerings?> fetchOfferings() async {
    _assertInitialized();
    try {
      return await Purchases.getOfferings();
    } on PlatformException catch (e) {
      debugPrint('[RevenueCat] fetchOfferings error: $e');
      return null;
    }
  }

  /// Offerings'ten kristal paketleri oluşturur.
  List<CrystalPack> buildCrystalPacks(Offerings? offerings) {
    final current = offerings?.current;
    if (current == null) return _fallbackCrystalPacks();

    final result = <CrystalPack>[];
    for (final package in current.availablePackages) {
      final id = package.storeProduct.identifier;
      final price = package.storeProduct.priceString;
      switch (id) {
        case StoreProductIds.crystalSmall:
          result.add(CrystalPack(package: package, productId: id, title: '100 Kristal', crystalAmount: 100, localizedPrice: price));
        case StoreProductIds.crystalMedium:
          result.add(CrystalPack(package: package, productId: id, title: '550 Kristal', crystalAmount: 550, localizedPrice: price, bonusLabel: '+50 Bonus'));
        case StoreProductIds.crystalLarge:
          result.add(CrystalPack(package: package, productId: id, title: '1.200 Kristal', crystalAmount: 1200, localizedPrice: price, bonusLabel: '+200 Bonus', isBestValue: true));
        case StoreProductIds.crystalMega:
          result.add(CrystalPack(package: package, productId: id, title: '2.500 Kristal', crystalAmount: 2500, localizedPrice: price, bonusLabel: '+500 Bonus'));
        case StoreProductIds.crystalUltra:
          result.add(CrystalPack(package: package, productId: id, title: '6.500 Kristal', crystalAmount: 6500, localizedPrice: price, bonusLabel: '+1500 Bonus'));
      }
    }
    return result.isEmpty ? _fallbackCrystalPacks() : result;
  }

  /// Offerings'ten abonelik planlarını oluşturur.
  List<SubscriptionPlan> buildSubscriptionPlans(Offerings? offerings) {
    final current = offerings?.current;
    if (current == null) return _fallbackSubscriptionPlans();

    final result = <SubscriptionPlan>[];
    for (final package in current.availablePackages) {
      final id = package.storeProduct.identifier;
      final price = package.storeProduct.priceString;
      switch (id) {
        case StoreProductIds.subMonthly:
          result.add(SubscriptionPlan(
            package: package,
            productId: id,
            period: SubscriptionPeriod.monthly,
            localizedPrice: price,
            perks: ['Reklamsız oyun', '10% inşaat hız bonusu', 'Özel komutan çerçevesi'],
          ));
        case StoreProductIds.subAnnual:
          result.add(SubscriptionPlan(
            package: package,
            productId: id,
            period: SubscriptionPeriod.annual,
            localizedPrice: price,
            savingsLabel: '%40 tasarruf',
            perks: ['Reklamsız oyun', '25% inşaat hız bonusu', 'Özel komutan çerçevesi', 'Aylık 200 ücretsiz kristal', 'VIP destek'],
          ));
      }
    }
    return result.isEmpty ? _fallbackSubscriptionPlans() : result;
  }

  // ── Satın alma ────────────────────────────────────────────────────────────

  /// Kristal paketi veya abonelik satın alır.
  Future<PurchaseResult> purchase(Package package) async {
    _assertInitialized();
    try {
      final params = PurchaseParams.package(package);
      final result = await Purchases.purchase(params);
      return _validateEntitlement(result.customerInfo, package.storeProduct.identifier);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);

      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return const PurchaseCancelled();
      }
      if (code == PurchasesErrorCode.networkError) {
        return const PurchaseFailure(
          message: 'İnternet bağlantısı bulunamadı. Lütfen tekrar dene.',
          isNetworkError: true,
        );
      }
      if (code == PurchasesErrorCode.productAlreadyPurchasedError) {
        return const PurchaseFailure(message: 'Bu ürün zaten satın alınmış.');
      }
      return PurchaseFailure(message: e.message ?? 'Bilinmeyen bir hata oluştu.');
    }
  }

  /// Önceki satın alımları geri yükler (App Store zorunluluğu).
  Future<PurchaseResult> restorePurchases() async {
    _assertInitialized();
    try {
      final info = await Purchases.restorePurchases();
      final hasPremium = info.entitlements.active.containsKey(StoreProductIds.entitlementPremium);
      return RestoreSuccess(hasPremium: hasPremium);
    } on PlatformException catch (e) {
      return PurchaseFailure(message: e.message ?? 'Geri yükleme başarısız.');
    }
  }

  // ── Entitlement kontrolü ─────────────────────────────────────────────────

  /// Kullanıcının premium yetkisi olup olmadığını kontrol eder.
  /// ⚠️ Yetki gerektiren işlemler için her zaman bunu kullan,
  ///    yerel state'e güvenme.
  Future<bool> hasPremiumEntitlement() async {
    _assertInitialized();
    try {
      final info = await Purchases.getCustomerInfo();
      return info.entitlements.active.containsKey(StoreProductIds.entitlementPremium);
    } on PlatformException {
      return false;
    }
  }

  Future<CustomerInfo?> getCustomerInfo() async {
    _assertInitialized();
    try {
      return await Purchases.getCustomerInfo();
    } on PlatformException {
      return null;
    }
  }

  // ── Yardımcılar ───────────────────────────────────────────────────────────

  PurchaseResult _validateEntitlement(CustomerInfo info, String productId) {
    final isSubscription = productId == StoreProductIds.subMonthly ||
        productId == StoreProductIds.subAnnual;
    if (isSubscription) {
      final active = info.entitlements.active.containsKey(StoreProductIds.entitlementPremium);
      if (!active) {
        return const PurchaseFailure(
          message: 'Satın alma tamamlandı fakat yetki doğrulanamadı. Lütfen geri yükle.',
        );
      }
    }
    return PurchaseSuccess(productId: productId);
  }

  void _assertInitialized() {
    assert(_initialized, 'RevenueCatManager.init() henüz çağrılmadı.');
  }

  // ── Fallback placeholder'lar ──────────────────────────────────────────────

  List<CrystalPack> _fallbackCrystalPacks() => [
    const CrystalPack(productId: StoreProductIds.crystalSmall,  title: '100 Kristal',   crystalAmount: 100,  localizedPrice: '—'),
    const CrystalPack(productId: StoreProductIds.crystalMedium, title: '550 Kristal',   crystalAmount: 550,  localizedPrice: '—', bonusLabel: '+50 Bonus'),
    const CrystalPack(productId: StoreProductIds.crystalLarge,  title: '1.200 Kristal', crystalAmount: 1200, localizedPrice: '—', bonusLabel: '+200 Bonus', isBestValue: true),
    const CrystalPack(productId: StoreProductIds.crystalMega,   title: '2.500 Kristal', crystalAmount: 2500, localizedPrice: '—', bonusLabel: '+500 Bonus'),
    const CrystalPack(productId: StoreProductIds.crystalUltra,  title: '6.500 Kristal', crystalAmount: 6500, localizedPrice: '—', bonusLabel: '+1500 Bonus'),
  ];

  List<SubscriptionPlan> _fallbackSubscriptionPlans() => [
    const SubscriptionPlan(
      productId: StoreProductIds.subMonthly,
      period: SubscriptionPeriod.monthly,
      localizedPrice: '—',
      perks: ['Reklamsız oyun', '10% inşaat hız bonusu', 'Özel komutan çerçevesi'],
    ),
    const SubscriptionPlan(
      productId: StoreProductIds.subAnnual,
      period: SubscriptionPeriod.annual,
      localizedPrice: '—',
      savingsLabel: '%40 tasarruf',
      perks: ['Reklamsız oyun', '25% inşaat hız bonusu', 'Özel komutan çerçevesi', 'Aylık 200 ücretsiz kristal', 'VIP destek'],
    ),
  ];
}
