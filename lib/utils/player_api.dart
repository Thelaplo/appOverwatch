import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/player_profile.dart';

/// Acces aux profils de joueurs publies par l'API OverFast.
///
/// Blizzard ne donne pas d'acces direct aux profils : l'identifiant qui
/// circule cote API est un jeton opaque, pas le BattleTag. On passe donc
/// toujours par la recherche par pseudo, qui renvoie cet identifiant.
///
/// Un profil configure en prive chez Blizzard reste inaccessible : c'est une
/// limite du jeu, pas de l'application.
class PlayerApi {
  static const String _base = 'https://overfast-api.tekrop.fr';

  /// Cherche des joueurs par pseudo. Renvoie une liste vide si rien ne
  /// correspond ou si l'API est injoignable.
  static Future<List<PlayerSearchResult>> search(String name) async {
    final query = name.trim();
    if (query.isEmpty) return const [];

    try {
      final res = await http.get(
        Uri.parse('$_base/players').replace(queryParameters: {'name': query}),
      );
      if (res.statusCode != 200) return const [];

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>? ?? const [];
      return results
          .map((e) => PlayerSearchResult.fromJson(e as Map<String, dynamic>))
          .where((p) => p.playerId.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  /// Recupere le resume d'un profil, ou null s'il est prive ou introuvable.
  static Future<PlayerProfile?> summary(String playerId) async {
    try {
      final res = await http.get(Uri.parse('$_base/players/$playerId/summary'));
      if (res.statusCode != 200) return null;

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      return PlayerProfile.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
