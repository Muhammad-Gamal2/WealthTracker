class GoldEntity {
  final String id;
  final String label;
  final double weightGrams;
  final int karat;
  final double purchasePricePerGram;
  final DateTime dateAdded;

  const GoldEntity({
    required this.id,
    required this.label,
    required this.weightGrams,
    required this.karat,
    this.purchasePricePerGram = 0,
    required this.dateAdded,
  });

  double get totalPurchaseCost => weightGrams * purchasePricePerGram;

  GoldEntity copyWith({
    String? id,
    String? label,
    double? weightGrams,
    int? karat,
    double? purchasePricePerGram,
    DateTime? dateAdded,
  }) {
    return GoldEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      weightGrams: weightGrams ?? this.weightGrams,
      karat: karat ?? this.karat,
      purchasePricePerGram: purchasePricePerGram ?? this.purchasePricePerGram,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
