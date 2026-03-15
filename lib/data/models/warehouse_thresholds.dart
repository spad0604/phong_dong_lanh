class WarehouseThresholds {
  const WarehouseThresholds({
    required this.tempMaxC,
    required this.humidityMaxPct,
  });

  final double tempMaxC;
  final double humidityMaxPct;

  static const WarehouseThresholds defaults = WarehouseThresholds(
    tempMaxC: 10,
    humidityMaxPct: 75,
  );

  static double _toDouble(Object? value, {required double fallback}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  factory WarehouseThresholds.fromJson(Map<Object?, Object?> json) {
    return WarehouseThresholds(
      tempMaxC: _toDouble(json['tempMaxC'], fallback: defaults.tempMaxC),
      humidityMaxPct: _toDouble(
        json['humidityMaxPct'],
        fallback: defaults.humidityMaxPct,
      ),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'tempMaxC': tempMaxC,
      'humidityMaxPct': humidityMaxPct,
    };
  }
}
