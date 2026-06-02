import 'package:purchases_flutter/purchases_flutter.dart';

/// A consumable coin pack available for purchase.
class CrystalPack {
  final Package? package;
  final String productId;
  final String title;
  final int crystalAmount;
  final String? bonusLabel;
  final bool isBestValue;
  final String localizedPrice;

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
