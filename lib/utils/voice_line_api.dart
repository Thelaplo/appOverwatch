import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'skin_api.dart';

/// Une replique officielle d'un heros, avec son fichier audio.
class WikiVoiceLine {
  final String heroLabel;
  final String text;
  final String audioUrl;

  const WikiVoiceLine({
    required this.heroLabel,
    required this.text,
    required this.audioUrl,
  });
}

/// Recupere les vraies repliques audio depuis le wiki Overwatch.
///
/// Le wiki heberge les extraits du jeu en .ogg sous la forme
/// `<Heros>_-_<Replique>.ogg`. C'est la vraie voix des comediens, la ou la
/// synthese vocale du systeme ne donnait qu'une voix robotique.
///
/// Seules les versions anglaises sont retenues : les fichiers en langue
/// native du personnage sont prefixes par la langue (`(Korean)`, `(Samoan)`,
/// `(Arabic)`...), et les extraits de narration par `(Narrator)`.
class VoiceLineApi {
  static const String _endpoint = 'https://overwatch.fandom.com/api.php';

  static final Map<String, List<WikiVoiceLine>> _cache = {};

  static Future<List<WikiVoiceLine>> fetchVoiceLines(
    String heroKey,
    String heroLabel,
  ) async {
    final cached = _cache[heroKey];
    if (cached != null) return cached;

    final prefix = '${SkinApi.wikiNameFor(heroKey)}_-_';
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'action': 'query',
      'list': 'allimages',
      'aiprefix': prefix,
      // Les fichiers sont renvoyes par ordre alphabetique et les versions en
      // langue native, prefixees par « ( », passent avant les lettres. Sans
      // ce point de depart, les 100 premiers resultats de D.Va sont tous en
      // coreen et se font tous filtrer plus bas.
      'aifrom': '${prefix}A',
      'ailimit': '100',
      'format': 'json',
      'origin': '*', // requis pour le CORS sur le web
    });

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) return _cache[heroKey] = const [];

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final files = (data['query']?['allimages'] as List<dynamic>?) ?? const [];

      final lines = <WikiVoiceLine>[];
      for (final raw in files) {
        final file = raw as Map<String, dynamic>;
        final fileName = file['name'] as String? ?? '';
        final url = file['url'] as String? ?? '';

        if (!fileName.toLowerCase().endsWith('.ogg')) continue;
        if (url.isEmpty) continue;

        var text = fileName.substring(prefix.length.clamp(0, fileName.length));
        text = text.replaceAll(RegExp(r'\.ogg$', caseSensitive: false), '');

        // `(Korean) ...`, `(Narrator) ...` : on ne garde que l'anglais du heros.
        if (text.startsWith('(')) continue;

        lines.add(WikiVoiceLine(
          heroLabel: heroLabel,
          text: text.replaceAll('_', ' ').trim(),
          audioUrl: url,
        ));
      }

      return _cache[heroKey] = lines;
    } catch (_) {
      return _cache[heroKey] = const [];
    }
  }

  /// Tire quelques repliques au hasard, pour varier d'une session a l'autre.
  static Future<List<WikiVoiceLine>> sample(
    String heroKey,
    String heroLabel,
    int count,
    Random random,
  ) async {
    final lines = await fetchVoiceLines(heroKey, heroLabel);
    if (lines.length <= count) return lines;

    final pool = List<WikiVoiceLine>.from(lines)..shuffle(random);
    return pool.take(count).toList();
  }
}
