class TelemetryPoint {
  const TelemetryPoint({
    required this.timestampMs,
    required this.temperatureC,
    required this.humidityPct,
  });

  final int timestampMs;
  final double temperatureC;
  final double humidityPct;

  static double _toDouble(Object? value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static int _toInt(Object? value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  factory TelemetryPoint.fromJson(Map<Object?, Object?> json) {
    return TelemetryPoint(
      timestampMs: _toInt(json['ts'] ?? json['timestampMs']),
      temperatureC: _toDouble(json['t'] ?? json['temperatureC']),
      humidityPct: _toDouble(json['h'] ?? json['humidityPct']),
    );
  }
}
