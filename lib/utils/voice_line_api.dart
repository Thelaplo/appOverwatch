import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'skin_api.dart';

/// Une replique officielle d'un heros, avec son fichier audio.
class WikiVoiceLine {
  final String heroLabel;
  final String text;
  final String audioUrl;

  /// Replique liee a l'ultime du heros : mise en avant dans l'interface.
  final bool isUltimate;

  const WikiVoiceLine({
    required this.heroLabel,
    required this.text,
    required this.audioUrl,
    this.isUltimate = false,
  });
}

/// Recupere les vraies repliques audio depuis le wiki Overwatch.
///
/// Le wiki heberge les extraits du jeu en .ogg sous la forme
/// `<Heros>_-_<Replique>.ogg`. C'est la vraie voix des comediens, la ou la
/// synthese vocale du systeme ne donnait qu'une voix robotique.
class VoiceLineApi {
  static const String _endpoint = 'https://overwatch.fandom.com/api.php';

  static final Map<String, List<WikiVoiceLine>> _cache = {};

  /// Mot-cle identifiant la replique d'ultime de chaque heros.
  ///
  /// Le wiki ne marque pas les ultimes ; on les reconnait au nom de la
  /// capacite, qui apparait dans le texte de la replique.
  static const Map<String, List<String>> _ultimateKeywords = {
    'mauga': ['cage fight'],
    'dva': ['nerf this', 'self-destruct'],
    'reinhardt': ['hammer down', 'earthshatter'],
    'genji': ['dragonblade', 'ryujin', 'ryūjin'],
    'ana': ['nano'],
    'kiriko': ['kitsune'],
    'jetpack-cat': ['terrifying roar', 'roar'],
    'zenyatta': ['transcendence', 'experience tranquility'],
    'winston': ['primal'],
    'sigma': ['gravitic flux'],
    'zarya': ['graviton'],
  };

  /// Interroge le wiki une fois, a partir d'un point de depart alphabetique.
  static Future<List<Map<String, dynamic>>> _query(String prefix, {String? from}) async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'action': 'query',
      'list': 'allimages',
      'aiprefix': prefix,
      if (from != null) 'aifrom': from,
      'ailimit': '100',
      'format': 'json',
      'origin': '*', // requis pour le CORS sur le web
    });

    final res = await http.get(uri);
    if (res.statusCode != 200) return const [];

    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return ((data['query']?['allimages'] as List<dynamic>?) ?? const [])
        .cast<Map<String, dynamic>>();
  }

  static Future<List<WikiVoiceLine>> fetchVoiceLines(
    String heroKey,
    String heroLabel,
  ) async {
    final cached = _cache[heroKey];
    if (cached != null) return cached;

    final prefix = '${SkinApi.wikiNameFor(heroKey)}_-_';

    try {
      // Deux passes : les fichiers sont renvoyes par ordre alphabetique et
      // ceux entre parentheses passent avant les lettres. La premiere passe
      // les attrape (dont les vocalises de Jetpack Cat), la seconde demarre a
      // la premiere lettre pour atteindre les repliques anglaises, sans quoi
      // les 100 premiers resultats de D.Va sont tous en coreen.
      final results = await Future.wait([
        _query(prefix),
        _query(prefix, from: '${prefix}A'),
      ]);

      final seen = <String>{};
      final lines = <WikiVoiceLine>[];

      for (final file in [...results[0], ...results[1]]) {
        final fileName = file['name'] as String? ?? '';
        final url = file['url'] as String? ?? '';

        if (!fileName.toLowerCase().endsWith('.ogg')) continue;
        if (url.isEmpty || !seen.add(fileName)) continue;

        var text = fileName.startsWith(prefix) ? fileName.substring(prefix.length) : fileName;
        text = text.replaceAll(RegExp(r'\.ogg$', caseSensitive: false), '');
        text = text.replaceAll('_', ' ').trim();

        if (_isForeignLanguage(text)) continue;

        lines.add(WikiVoiceLine(
          heroLabel: heroLabel,
          text: text,
          audioUrl: url,
          isUltimate: _isUltimate(heroKey, text),
        ));
      }

      return _cache[heroKey] = lines;
    } catch (_) {
      return _cache[heroKey] = const [];
    }
  }

  /// Ecarte les versions en langue native du personnage et les narrations.
  ///
  /// Le wiki les prefixe par une parenthese en majuscule — `(Korean)`,
  /// `(Samoan)`, `(Narrator)`. Les descriptions sonores, elles, sont en
  /// minuscule — `(angry meow)`, `(terrifying roar)` — et doivent etre
  /// gardees : ce sont les seules « repliques » de Jetpack Cat.
  static bool _isForeignLanguage(String text) {
    if (!text.startsWith('(')) return false;
    final close = text.indexOf(')');
    if (close <= 1) return false;

    final inside = text.substring(1, close);
    return inside.isNotEmpty && inside[0] == inside[0].toUpperCase() && inside[0] != inside[0].toLowerCase();
  }

  static bool _isUltimate(String heroKey, String text) {
    final keywords = _ultimateKeywords[heroKey];
    if (keywords == null) return false;

    final lower = text.toLowerCase();
    return keywords.any(lower.contains);
  }

  /// Tire quelques repliques au hasard, en gardant toujours l'ultime en tete
  /// quand le heros en a une : c'est la replique que l'on veut entendre.
  static Future<List<WikiVoiceLine>> sample(
    String heroKey,
    String heroLabel,
    int count,
    Random random,
  ) async {
    final lines = await fetchVoiceLines(heroKey, heroLabel);
    if (lines.isEmpty) return const [];

    final ultimates = lines.where((l) => l.isUltimate).toList();
    final others = lines.where((l) => !l.isUltimate).toList()..shuffle(random);

    final picked = <WikiVoiceLine>[
      ...ultimates.take(count),
      ...others.take((count - ultimates.length).clamp(0, count)),
    ];
    return picked.take(count).toList();
  }
}
