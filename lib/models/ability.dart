class Ability {
  final String name;
  final String description;
  final String iconUrl;

  Ability({
    required this.name,
    required this.description,
    required this.iconUrl,
  });

  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['icon'] ?? '',
    );
  }
}
