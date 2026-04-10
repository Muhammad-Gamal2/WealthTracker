class GoldEntity {
  final String id;
  final String label;
  final double weightGrams;
  final int karat;
  final DateTime dateAdded;

  const GoldEntity({
    required this.id,
    required this.label,
    required this.weightGrams,
    required this.karat,
    required this.dateAdded,
  });

  GoldEntity copyWith({
    String? id,
    String? label,
    double? weightGrams,
    int? karat,
    DateTime? dateAdded,
  }) {
    return GoldEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      weightGrams: weightGrams ?? this.weightGrams,
      karat: karat ?? this.karat,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
