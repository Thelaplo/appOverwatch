import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

/// Un skin officiel recupere depuis le wiki Overwatch.
class WikiSkin {
  final String name;
  final String imageUrl;

  const WikiSkin({required this.name, required this.imageUrl});
}

/// Recupere les vraies images de skins depuis le wiki Overwatch (Fandom).
///
/// L'API OverFast ne fournit aucun endpoint de cosmetiques, et les URLs de
/// skins qui etaient codees en dur dans l'app renvoyaient 403. Le wiki, lui,
/// expose ses fichiers sous la forme `<Heros>_Skin_<Nom>.png` via l'API
/// MediaWiki, en acces libre et sans User-Agent particulier.
class SkinApi {
  static const String _endpoint = 'https://overwatch.fandom.com/api.php';

  /// Un heros n'est interroge qu'une fois par session.
  static final Map<String, List<WikiSkin>> _cache = {};

  /// Heros dont le nom de fichier sur le wiki ne se deduit pas de la cle.
  static const Map<String, String> _specialNames = {
    'dva': 'D.Va',
    'soldier-76': 'S76',
    'lucio': 'Lúcio',
    'torbjorn': 'Torbjörn',
  };

  /// Convertit la cle de l'API OverFast en nom de fichier du wiki.
  ///
  /// On part de la cle (stable et en anglais) et non du nom affiche, qui est
  /// traduit quand l'app tourne en francais.
  static String wikiNameFor(String heroKey) {
    final special = _specialNames[heroKey];
    if (special != null) return special;

    return heroKey
        .split('-')
        .map((part) => part.isEmpty ? part : part[0].toUpperCase() + part.substring(1))
        .join('_');
  }

  /// Liste les skins d'un heros. Renvoie une liste vide si le wiki est
  /// injoignable ou ne connait pas ce heros : l'appelant doit prevoir un repli.
  static Future<List<WikiSkin>> fetchSkins(String heroKey) async {
    final cached = _cache[heroKey];
    if (cached != null) return cached;

    final prefix = '${wikiNameFor(heroKey)}_Skin_';
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'action': 'query',
      'list': 'allimages',
      'aiprefix': prefix,
      // 100 suffit largement pour alimenter la galerie et les tirages, et
      // evite de rapatrier plusieurs centaines de Ko de JSON par heros.
      'ailimit': '100',
      'format': 'json',
      'origin': '*', // requis pour le CORS sur le web
    });

    try {
      final res = await http.get(uri);
      if (res.statusCode != 200) return _cache[heroKey] = const [];

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final images = (data['query']?['allimages'] as List<dynamic>?) ?? const [];

      final skins = <WikiSkin>[];
      for (final raw in images) {
        final image = raw as Map<String, dynamic>;
        final fileName = image['name'] as String? ?? '';
        final url = image['url'] as String? ?? '';
        if (fileName.isEmpty || url.isEmpty) continue;

        // Les fichiers `..._Weapon_1.png` sont des variantes d'arme, pas des skins.
        if (fileName.contains('_Weapon_')) continue;

        skins.add(WikiSkin(name: _prettifyName(fileName, prefix), imageUrl: _thumbnail(url)));
      }

      return _cache[heroKey] = skins;
    } catch (_) {
      // Hors ligne : on met en cache le vide pour ne pas retenter en boucle.
      return _cache[heroKey] = const [];
    }
  }

  /// Tire un skin au hasard parmi ceux du heros, ou null si aucun n'est connu.
  static Future<WikiSkin?> randomSkinFor(String heroKey, Random random) async {
    final skins = await fetchSkins(heroKey);
    if (skins.isEmpty) return null;
    return skins[random.nextInt(skins.length)];
  }

  /// « D.Va_Skin_Black_Cat.png » -> « Black Cat »
  static String _prettifyName(String fileName, String prefix) {
    var name = fileName;
    if (name.startsWith(prefix)) name = name.substring(prefix.length);
    name = name.replaceAll(RegExp(r'\.(png|jpg|jpeg|webp)$', caseSensitive: false), '');
    return name.replaceAll('_', ' ').trim();
  }

  /// Demande a Wikia une version reduite : les originaux font plusieurs
  /// centaines de Ko, inutiles pour une vignette.
  static String _thumbnail(String url, {int width = 400}) {
    return url.replaceFirst(
      '/revision/latest',
      '/revision/latest/scale-to-width-down/$width',
    );
  }
}
