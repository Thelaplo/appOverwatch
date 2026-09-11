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

  /// Replique prononcee a l'activation de l'ultime, par heros.
  ///
  /// Ni le wiki ni l'API OverFast ne marquent les ultimes : l'ordre des
  /// capacites de l'API n'est pas fiable (elle donne « Cyber-Agility » pour
  /// Genji) et les sections de la page Quotes ne suivent pas un ordre stable.
  /// Chaque entree ci-dessous a donc ete verifiee une a une contre le wiki ;
  /// un heros absent n'a simplement pas d'ultime mise en avant.
  ///
  /// Note : en jeu, l'ultime a deux repliques, une pour les allies et une
  /// pour les ennemis, cette derniere souvent dans la langue natale du
  /// personnage. Le wiki ne les nomme pas de facon systematique, donc seule
  /// la version alliee est identifiee ici ; les versions en langue natale
  /// restent accessibles dans la liste complete des repliques.
  static const Map<String, String> _ultimateFiles = {
    'ana': 'Ana - Nano-Boost administered.ogg',
    'brigitte': 'Brigitte - Rally to me.ogg',
    'cassidy': "Cassidy - It's high noon.ogg",
    'doomfist': 'Doomfist - Meteor strike.ogg',
    'dva': 'D.Va - Nerf this.ogg',
    'junkrat': 'Junkrat - Fire in the hole.ogg',
    'lucio': "Lúcio - Oh, let's break it down.ogg",
    'mauga': "Mauga - You can check in but you can't check out.ogg",
    'mei': "Mei - Freeze! Don't move.ogg",
    'mercy': 'Mercy - Heroes never die.ogg',
    'pharah': 'Pharah - Justice rains from above.ogg',
    'reaper': 'Reaper - Die... Die... Die.ogg',
    'reinhardt': 'Reinhardt - Hammer down.ogg',
    'sigma': 'Sigma - The universe is singing to me.ogg',
    'torbjorn': 'Torbjörn - Molten core.ogg',
    'zarya': 'Zarya - Fire at will.ogg',
    'zenyatta': 'Zenyatta - Experience tranquility.ogg',
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
          isUltimate: _isUltimate(heroKey, fileName),
        ));
      }

      // La replique d'ultime peut tomber hors des 100 premiers resultats
      // alphabetiques ; on la demande alors nommement pour ne jamais la rater.
      final ultimateFile = _ultimateFiles[heroKey];
      if (ultimateFile != null && !lines.any((l) => l.isUltimate)) {
        final url = await _resolveFileUrl(ultimateFile);
        if (url != null) {
          lines.insert(
            0,
            WikiVoiceLine(
              heroLabel: heroLabel,
              text: _stripPrefix(ultimateFile, prefix),
              audioUrl: url,
              isUltimate: true,
            ),
          );
        }
      }

      return _cache[heroKey] = lines;
    } catch (_) {
      return _cache[heroKey] = const [];
    }
  }

  /// Resout l'URL d'un fichier du wiki a partir de son nom exact.
  static Future<String?> _resolveFileUrl(String fileName) async {
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'action': 'query',
      'titles': 'File:$fileName',
      'prop': 'imageinfo',
      'iiprop': 'url',
      'format': 'json',
      'origin': '*',
    });

    final res = await http.get(uri);
    if (res.statusCode != 200) return null;

    final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final pages = data['query']?['pages'] as Map<String, dynamic>?;
    if (pages == null) return null;

    for (final page in pages.values) {
      final info = (page as Map<String, dynamic>)['imageinfo'] as List<dynamic>?;
      if (info != null && info.isNotEmpty) {
        return (info.first as Map<String, dynamic>)['url'] as String?;
      }
    }
    return null;
  }

  static String _stripPrefix(String fileName, String prefix) {
    final normalized = prefix.replaceAll('_', ' ');
    var text = fileName.startsWith(normalized) ? fileName.substring(normalized.length) : fileName;
    return text.replaceAll(RegExp(r'\.ogg$', caseSensitive: false), '').trim();
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

  static bool _isUltimate(String heroKey, String fileName) {
    final expected = _ultimateFiles[heroKey];
    if (expected == null) return false;

    // Les noms de fichiers du wiki utilisent des underscores la ou l'API
    // renvoie des espaces.
    return fileName.replaceAll('_', ' ') == expected;
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
