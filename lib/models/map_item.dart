class MapItem {
  final String name;
  final String? image;
  final String? countryCode;
  final List<String> gamemodes;

  MapItem({
    required this.name,
    this.image,
    this.countryCode,
    required this.gamemodes,
  });

  factory MapItem.fromJson(Map<String, dynamic> json) {
    final modes = (json['gamemodes'] as List<dynamic>?)
            ?.map((e) => e.toString().toUpperCase())
            .toList() ??
        [];
    return MapItem(
      name: json['name'] ?? 'Carte inconnue',
      // L'API nomme la clé "screenshot"
      image: json['screenshot'] ?? json['image'],
      countryCode: json['country_code'],
      gamemodes: modes,
    );
  }
}