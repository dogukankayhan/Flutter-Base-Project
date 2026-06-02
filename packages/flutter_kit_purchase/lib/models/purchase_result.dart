sealed class PurchaseResult {
  const PurchaseResult();
}

/// Satın alma başarılı ve entitlement aktif
final class PurchaseSuccess extends PurchaseResult {
  final String productId;
  const PurchaseSuccess({required this.productId});
}

/// Kullanıcı satın alma diyaloğunu kapattı (hata değil)
final class PurchaseCancelled extends PurchaseResult {
  const PurchaseCancelled();
}

/// Gerçek bir hata oluştu
final class PurchaseFailure extends PurchaseResult {
  final String message;
  final bool isNetworkError;
  const PurchaseFailure({required this.message, this.isNetworkError = false});
}

/// Restore işlemi tamamlandı
final class RestoreSuccess extends PurchaseResult {
  final bool hasPremium;
  const RestoreSuccess({required this.hasPremium});
}
