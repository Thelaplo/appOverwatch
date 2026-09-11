import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Une collaboration officielle Overwatch 2.
///
/// L'illustration n'est pas codee en dur : les anciennes URLs
/// images.blz-contentstack.com renvoyaient 422. On charge a la place le
/// background officiel du heros vedette, expose par l'API OverFast.
class _Collab {
  final String title;
  final String heroes;
  final String tag;

  /// Cle API du heros dont on affiche le background.
  final String featuredHeroKey;

  const _Collab({
    required this.title,
    required this.heroes,
    required this.tag,
    required this.featuredHeroKey,
  });
}

const List<_Collab> _kCollabs = [
  _Collab(
    title: 'OVERWATCH 2 × LE SSERAFIM',
    heroes: 'D.VA, KIRIKO, TRACER, BRIGITTE, SOMBRA',
    tag: 'PERFECT NIGHT • ÉVÉNEMENT SPÉCIAL',
    featuredHeroKey: 'dva',
  ),
  _Collab(
    title: 'OVERWATCH 2 × PORSCHE',
    heroes: 'D.VA PORSCHE MACAN TURBO & PHARAH TAYCAN',
    tag: 'COLLABORATION ÉLITE',
    featuredHeroKey: 'pharah',
  ),
  _Collab(
    title: 'OVERWATCH 2 × COWBOY BEBOP',
    heroes: 'CASSIDY SPIKE SPIEGEL & ASHE FAYE VALENTINE',
    tag: 'LÉGENDAIRE ANIME',
    featuredHeroKey: 'cassidy',
  ),
  _Collab(
    title: 'OVERWATCH 2 × TRANSFORMERS',
    heroes: 'REINHARDT OPTIMUS PRIME & BASTION BUMBLEBEE',
    tag: 'MECHA SHOWDOWN',
    featuredHeroKey: 'reinhardt',
  ),
];

class ShopCollabScreen extends StatefulWidget {
  const ShopCollabScreen({super.key});

  @override
  State<ShopCollabScreen> createState() => _ShopCollabScreenState();
}

class _ShopCollabScreenState extends State<ShopCollabScreen> {
  /// Cle API du heros -> URL de son background officiel.
  final Map<String, String> _backgrounds = {};

  @override
  void initState() {
    super.initState();
    _loadBackgrounds();
  }

  Future<void> _loadBackgrounds() async {
    for (final collab in _kCollabs) {
      final url = await _fetchBackground(collab.featuredHeroKey);
      if (!mounted) return;
      if (url != null) {
        setState(() => _backgrounds[collab.featuredHeroKey] = url);
      }
    }
  }

  Future<String?> _fetchBackground(String heroKey) async {
    try {
      final res = await http.get(
        Uri.parse('https://overfast-api.tekrop.fr/heroes/$heroKey?locale=fr-fr'),
      );
      if (res.statusCode != 200) return null;

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final backgrounds = data['backgrounds'] as List<dynamic>?;
      if (backgrounds == null || backgrounds.isEmpty) return null;

      return (backgrounds.first as Map<String, dynamic>)['url'] as String?;
    } catch (_) {
      // Hors ligne : la carte garde son visuel de repli.
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF090D15),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'BOUTIQUE DES COLLABORATIONS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Modèles exclusifs, célébrations musicales et partenariats mondiaux.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 18),
          ..._kCollabs.map(_buildCollabCard),
        ],
      ),
    );
  }

  Widget _buildCollabCard(_Collab item) {
    final background = _backgrounds[item.featuredHeroKey];

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF141926),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF99E1A).withAlpha(140), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(90), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 190,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (background == null)
                  _buildPlaceholder()
                else
                  Image.network(
                    background,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xF2141926)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  color: const Color(0xFFF99E1A),
                  child: Text(
                    item.tag,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 9,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(item.heroes, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const ColoredBox(
      color: Color(0xFF1B2233),
      child: Center(child: Icon(Icons.shopping_bag, size: 48, color: Color(0xFFF99E1A))),
    );
  }
}
