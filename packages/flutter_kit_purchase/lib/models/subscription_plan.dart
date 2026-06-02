import 'package:purchases_flutter/purchases_flutter.dart';

enum SubscriptionPeriod { monthly, annual }

class SubscriptionPlan {
  final Package? package;
  final String productId;
  final SubscriptionPeriod period;
  final String localizedPrice;
  final String? savingsLabel; // örn: "%40 tasarruf"
  final List<String> perks;

  const SubscriptionPlan({
    this.package,
    required this.productId,
    required this.period,
    required this.localizedPrice,
    required this.perks,
    this.savingsLabel,
  });

  String get periodLabel => switch (period) {
        SubscriptionPeriod.monthly => 'Aylık',
        SubscriptionPeriod.annual  => 'Yıllık',
      };
}
