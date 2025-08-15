class LocationResult {
  final String name;
  final String? state;
  final String country;
  final double lat;
  final double lon;

  LocationResult({
    required this.name,
    this.state,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory LocationResult.fromJson(Map<String, dynamic> json) {
    return LocationResult(
      name: json['name'] as String,
      state: json['state'] as String?,
      country: json['country'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  String displayName() {
    if (state != null && state!.isNotEmpty) return "$name, $state, $country";
    return "$name, $country";
  }
}
