class LiquidityEntity {
  final String id;
  final String label;
  final double amountUsd;
  final DateTime dateAdded;

  const LiquidityEntity({
    required this.id,
    required this.label,
    required this.amountUsd,
    required this.dateAdded,
  });

  LiquidityEntity copyWith({
    String? id,
    String? label,
    double? amountUsd,
    DateTime? dateAdded,
  }) {
    return LiquidityEntity(
      id: id ?? this.id,
      label: label ?? this.label,
      amountUsd: amountUsd ?? this.amountUsd,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
