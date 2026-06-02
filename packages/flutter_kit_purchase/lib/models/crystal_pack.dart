import 'package:purchases_flutter/purchases_flutter.dart';

class CrystalPack {
  final Package? package;
  final String productId;
  final String title;
  final int crystalAmount;
  final String? bonusLabel;    // örn: "+%10 bonus"
  final bool isBestValue;
  final String localizedPrice; // RevenueCat'ten gelen fiyat

  const CrystalPack({
    this.package,
    required this.productId,
    required this.title,
    required this.crystalAmount,
    required this.localizedPrice,
    this.bonusLabel,
    this.isBestValue = false,
  });
}
