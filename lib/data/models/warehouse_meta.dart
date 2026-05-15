class WarehouseMeta {
  const WarehouseMeta({required this.name, required this.subtitle});

  final String? name;
  final String? subtitle;

  static const WarehouseMeta defaults = WarehouseMeta(name: null, subtitle: null);

  factory WarehouseMeta.fromJson(Map<Object?, Object?> json) {
    final name = json['name'];
    final subtitle = json['subtitle'];

    return WarehouseMeta(
      name: name is String && name.trim().isNotEmpty ? name.trim() : null,
      subtitle: subtitle is String && subtitle.trim().isNotEmpty
          ? subtitle.trim()
          : null,
    );
  }
}
