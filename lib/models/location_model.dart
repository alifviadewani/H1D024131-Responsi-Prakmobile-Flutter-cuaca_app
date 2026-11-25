/// Model data lokasi (hasil Geocoding API & data favorit di local storage).
class LocationModel {
  final int? id;
  final String name;
  final String? admin1; // provinsi / wilayah
  final String country;
  final double latitude;
  final double longitude;

  const LocationModel({
    this.id,
    required this.name,
    this.admin1,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String? ?? '-',
      admin1: json['admin1'] as String?,
      country: json['country'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'admin1': admin1,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
      };

  /// Contoh: "Jawa Tengah, Indonesia"
  String get subtitle {
    final parts = <String>[
      if (admin1 != null && admin1!.isNotEmpty) admin1!,
      if (country.isNotEmpty) country,
    ];
    return parts.join(', ');
  }

  /// Kunci unik berdasarkan koordinat (untuk cek favorit).
  String get key =>
      '${latitude.toStringAsFixed(3)},${longitude.toStringAsFixed(3)}';
}
