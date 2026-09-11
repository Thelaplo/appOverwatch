import 'dart:convert';

import 'package:http/http.dart' as http;

/// Points de vie d'un heros, tels que publies par l'API OverFast.
class HeroHitpoints {
  final int health;
  final int armor;
  final int shields;
  final int total;

  const HeroHitpoints({
    required this.health,
    required this.armor,
    required this.shields,
    required this.total,
  });

  factory HeroHitpoints.fromJson(Map<String, dynamic> json) {
    final health = (json['health'] as num?)?.toInt() ?? 0;
    final armor = (json['armor'] as num?)?.toInt() ?? 0;
    final shields = (json['shields'] as num?)?.toInt() ?? 0;
    return HeroHitpoints(
      health: health,
      armor: armor,
      shields: shields,
      total: (json['total'] as num?)?.toInt() ?? health + armor + shields,
    );
  }
}

/// Recupere les points de vie reels des heros.
///
/// L'endpoint /heroes ne renvoie que le portrait et les roles ; il faut
/// interroger /heroes/{cle} pour obtenir les points de vie. Le resultat est
/// mis en cache : un heros n'est demande qu'une fois par session.
class HeroStatsApi {
  static final Map<String, HeroHitpoints> _cache = {};

  /// Points de vie deja connus, sans declencher d'appel reseau.
  static Map<String, HeroHitpoints> get cached => Map.unmodifiable(_cache);

  static Future<HeroHitpoints?> fetch(String heroKey) async {
    final cached = _cache[heroKey];
    if (cached != null) return cached;

    try {
      final res = await http.get(
        Uri.parse('https://overfast-api.tekrop.fr/heroes/$heroKey?locale=fr-fr'),
      );
      if (res.statusCode != 200) return null;

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final raw = data['hitpoints'] as Map<String, dynamic>?;
      if (raw == null) return null;

      return _cache[heroKey] = HeroHitpoints.fromJson(raw);
    } catch (_) {
      // Hors ligne : l'analyse retombera sur une estimation par role.
      return null;
    }
  }

  /// Charge en parallele les points de vie de plusieurs heros.
  static Future<Map<String, HeroHitpoints>> fetchAll(Iterable<String> heroKeys) async {
    await Future.wait(heroKeys.toSet().map(fetch));
    return {
      for (final key in heroKeys)
        if (_cache[key] != null) key: _cache[key]!,
    };
  }
}
