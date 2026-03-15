class WarehouseState {
  const WarehouseState({
    required this.doorOpen,
    required this.fanOn,
    required this.acOn,
    required this.autoMode,
  });

  final bool doorOpen;
  final bool fanOn;
  final bool acOn;
  final bool autoMode;

  static const WarehouseState defaults = WarehouseState(
    doorOpen: false,
    fanOn: false,
    acOn: false,
    autoMode: true,
  );

  static bool _toBool(Object? value, {required bool fallback}) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == 'on' || normalized == 'open') {
        return true;
      }
      if (normalized == 'false' || normalized == 'off' || normalized == 'closed') {
        return false;
      }
    }
    return fallback;
  }

  factory WarehouseState.fromJson(Map<Object?, Object?> json) {
    return WarehouseState(
      doorOpen: _toBool(json['doorOpen'], fallback: defaults.doorOpen),
      fanOn: _toBool(json['fanOn'], fallback: defaults.fanOn),
      acOn: _toBool(json['acOn'], fallback: defaults.acOn),
      autoMode: _toBool(json['autoMode'], fallback: defaults.autoMode),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'doorOpen': doorOpen,
      'fanOn': fanOn,
      'acOn': acOn,
      'autoMode': autoMode,
    };
  }
}
