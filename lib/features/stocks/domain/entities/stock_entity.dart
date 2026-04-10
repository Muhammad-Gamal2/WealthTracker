class StockEntity {
  final String id;
  final String symbol;
  final String name;
  final double quantity;
  final double purchasePrice;
  final String market; // 'EGX' or 'US'
  final String currency; // 'EGP' or 'USD'
  final DateTime dateAdded;

  const StockEntity({
    required this.id,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.purchasePrice,
    required this.market,
    required this.currency,
    required this.dateAdded,
  });

  bool get isEgx => market == 'EGX';
  bool get isUs => market == 'US';

  /// The symbol used for API calls (EGX stocks need :XCAI suffix)
  String get apiSymbol => isEgx ? '$symbol:XCAI' : symbol;

  StockEntity copyWith({
    String? id,
    String? symbol,
    String? name,
    double? quantity,
    double? purchasePrice,
    String? market,
    String? currency,
    DateTime? dateAdded,
  }) {
    return StockEntity(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      market: market ?? this.market,
      currency: currency ?? this.currency,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }
}
