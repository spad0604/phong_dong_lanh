class WarehouseTelemetry {
  const WarehouseTelemetry({
    required this.temperatureC,
    required this.humidityPct,
    required this.updatedAtMs,
  });

  final double temperatureC;
  final double humidityPct;
  final int updatedAtMs;

  static const WarehouseTelemetry defaults = WarehouseTelemetry(
    temperatureC: 0,
    humidityPct: 0,
    updatedAtMs: 0,
  );

  static double _toDouble(Object? value, {required double fallback}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static int _toInt(Object? value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  factory WarehouseTelemetry.fromJson(Map<Object?, Object?> json) {
    return WarehouseTelemetry(
      temperatureC: _toDouble(json['temperatureC'], fallback: defaults.temperatureC),
      humidityPct: _toDouble(json['humidityPct'], fallback: defaults.humidityPct),
      updatedAtMs: _toInt(json['updatedAtMs'], fallback: defaults.updatedAtMs),
    );
  }
}
