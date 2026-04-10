import 'dart:math';

class RealEstateEntity {
  final String id;
  final String projectName;
  final DateTime purchaseDate;
  final double purchaseAmountEgp;
  final double annualAppreciationPercent;
  final DateTime dateAdded;

  const RealEstateEntity({
    required this.id,
    required this.projectName,
    required this.purchaseDate,
    required this.purchaseAmountEgp,
    required this.annualAppreciationPercent,
    required this.dateAdded,
  });

  /// Compute current value using compound appreciation from purchase date
  double get currentValueEgp {
    final yearsElapsed =
        DateTime.now().difference(purchaseDate).inDays / 365.25;
    return purchaseAmountEgp *
        pow(1 + annualAppreciationPercent / 100, yearsElapsed);
  }

  /// Total gain in EGP
  double get gainEgp => currentValueEgp - purchaseAmountEgp;

  /// Gain as a percentage
  double get gainPercent =>
      purchaseAmountEgp > 0
          ? ((currentValueEgp - purchaseAmountEgp) / purchaseAmountEgp) * 100
          : 0;

  RealEstateEntity copyWith({
    String? id,
    String? projectName,
    DateTime? purchaseDate,
    double? purchaseAmountEgp,
    double? annualAppreciationPercent,
    DateTime? dateAdded,
  }) {
    return RealEstateEntity(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchaseAmountEgp: purchaseAmountEgp ?? this.purchaseAmountEgp,
      annualAppreciationPercent:
          annualAppreciationPercent ?? this.annualAppreciationPercent,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
