class WealthSummary {
  final double goldValueEgp;
  final double stocksValueEgp;
  final double liquidityValueEgp;
  final double realEstateValueEgp;
  final double usdToEgpRate;

  const WealthSummary({
    required this.goldValueEgp,
    required this.stocksValueEgp,
    required this.liquidityValueEgp,
    required this.realEstateValueEgp,
    required this.usdToEgpRate,
  });

  double get totalEgp =>
      goldValueEgp + stocksValueEgp + liquidityValueEgp + realEstateValueEgp;

  double get totalUsd => usdToEgpRate > 0 ? totalEgp / usdToEgpRate : 0;

  double get goldPercent => totalEgp > 0 ? (goldValueEgp / totalEgp) * 100 : 0;
  double get stocksPercent =>
      totalEgp > 0 ? (stocksValueEgp / totalEgp) * 100 : 0;
  double get liquidityPercent =>
      totalEgp > 0 ? (liquidityValueEgp / totalEgp) * 100 : 0;
  double get realEstatePercent =>
      totalEgp > 0 ? (realEstateValueEgp / totalEgp) * 100 : 0;

  double get goldValueUsd =>
      usdToEgpRate > 0 ? goldValueEgp / usdToEgpRate : 0;
  double get stocksValueUsd =>
      usdToEgpRate > 0 ? stocksValueEgp / usdToEgpRate : 0;
  double get liquidityValueUsd =>
      usdToEgpRate > 0 ? liquidityValueEgp / usdToEgpRate : 0;
  double get realEstateValueUsd =>
      usdToEgpRate > 0 ? realEstateValueEgp / usdToEgpRate : 0;

  static const empty = WealthSummary(
    goldValueEgp: 0,
    stocksValueEgp: 0,
    liquidityValueEgp: 0,
    realEstateValueEgp: 0,
    usdToEgpRate: 1,
  );
}

class SnapshotEntity {
  final String date;
  final double totalValueEgp;
  final double totalValueUsd;
  final double goldValueEgp;
  final double stocksValueEgp;
  final double liquidityValueEgp;
  final double realEstateValueEgp;

  const SnapshotEntity({
    required this.date,
    required this.totalValueEgp,
    required this.totalValueUsd,
    required this.goldValueEgp,
    required this.stocksValueEgp,
    required this.liquidityValueEgp,
    required this.realEstateValueEgp,
  });
}
