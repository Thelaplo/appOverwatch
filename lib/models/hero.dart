import 'ability.dart';

class HeroSummary {
  final String key;
  final String name;
  final String role;
  final String portrait;

  HeroSummary({
    required this.key,
    required this.name,
    required this.role,
    required this.portrait,
  });

  factory HeroSummary.fromJson(Map<String, dynamic> json) {
    return HeroSummary(
      key: json['key'] ?? '',
      name: json['name'] ?? 'Inconnu',
      role: json['role'] ?? 'unknown',
      portrait: json['portrait'] ?? '',
    );
  }
}

class HeroDetail {
  final String name;
  final String role;
  final String portrait;
  final String? realName;
  final String? location;
  final String? description;
  final int health;
  final int armor;
  final int shields;
  final int totalHp;
  final List<Ability> abilities;

  HeroDetail({
    required this.name,
    required this.role,
    required this.portrait,
    this.realName,
    this.location,
    this.description,
    required this.health,
    required this.armor,
    required this.shields,
    required this.totalHp,
    required this.abilities,
  });

  factory HeroDetail.fromJson(Map<String, dynamic> json) {
    final story = json['story'] as Map<String, dynamic>?;
    final hp = json['hitpoints'] as Map<String, dynamic>?;
    final abilitiesList = (json['abilities'] as List<dynamic>?) ?? [];

    return HeroDetail(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      portrait: json['portrait'] ?? '',
      realName: json['real_name'] ?? story?['real_name'],
      location: json['location'] ?? story?['location'],
      description: story?['summary'] ?? json['description'],
      health: hp?['health'] ?? 200,
      armor: hp?['armor'] ?? 0,
      shields: hp?['shields'] ?? 0,
      totalHp: hp?['total'] ?? 200,
      abilities: abilitiesList.map((a) => Ability.fromJson(a)).toList(),
    );
  }
}