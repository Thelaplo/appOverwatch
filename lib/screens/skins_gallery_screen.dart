import 'package:flutter/material.dart';

import '../utils/skin_api.dart';

/// Un skin du wiki, rattache au heros auquel il appartient.
class _GallerySkin {
  final String heroLabel;
  final WikiSkin skin;

  const _GallerySkin({required this.heroLabel, required this.skin});
}

class SkinsGalleryScreen extends StatefulWidget {
  const SkinsGalleryScreen({super.key});

  @override
  State<SkinsGalleryScreen> createState() => _SkinsGalleryScreenState();
}

class _SkinsGalleryScreenState extends State<SkinsGalleryScreen> {
  /// Heros mis en avant dans la galerie. La cle sert au wiki, le libelle a
  /// l'affichage des filtres.
  static const Map<String, String> _featuredHeroes = {
    'dva': 'D.VA',
    'genji': 'GENJI',
    'reinhardt': 'REINHARDT',
    'ana': 'ANA',
    'kiriko': 'KIRIKO',
    'mauga': 'MAUGA',
    'jetpack-cat': 'JETPACK CAT',
  };

  /// Nombre de skins retenus par heros, pour garder la grille lisible.
  static const int _skinsPerHero = 8;


  String _activeFilter = 'TOUS';
  List<_GallerySkin>? _skins;

  @override
  void initState() {
    super.initState();
    _loadSkins();
  }

  Future<void> _loadSkins() async {
    final collected = <_GallerySkin>[];

    for (final entry in _featuredHeroes.entries) {
      final skins = await SkinApi.fetchSkins(entry.key);
      collected.addAll(
        skins.take(_skinsPerHero).map((s) => _GallerySkin(heroLabel: entry.value, skin: s)),
      );
    }

    if (!mounted) return;
    setState(() => _skins = collected);
  }

  @override
  Widget build(BuildContext context) {
    final skins = _skins;
    final filtered = skins == null
        ? const <_GallerySkin>[]
        : (_activeFilter == 'TOUS'
            ? skins
            : skins.where((s) => s.heroLabel == _activeFilter).toList());

    return Scaffold(
      backgroundColor: const Color(0xFF090D15),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GALERIE DES SKINS OFFICIELS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skins == null
                        ? 'Chargement des modèles officiels...'
                        : '${skins.length} modèles officiels issus du wiki Overwatch.',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  _buildHeroFilters(),
                ],
              ),
            ),
          ),
          if (skins == null)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator(color: Color(0xFFF99E1A))),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildSkinCard(filtered[i]),
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroFilters() {
    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: ['TOUS', ..._featuredHeroes.values].map((filter) {
          final active = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter,
                style: TextStyle(
                  color: active ? Colors.black : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              selected: active,
              selectedColor: const Color(0xFFF99E1A),
              backgroundColor: const Color(0xFF141926),
              onSelected: (_) => setState(() => _activeFilter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSkinCard(_GallerySkin item) {
    const accent = Color(0xFFF99E1A);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141926),
        border: Border.all(color: accent.withAlpha(160), width: 2),
        boxShadow: [BoxShadow(color: accent.withAlpha(40), blurRadius: 10)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: accent,
            child: Text(
              item.heroLabel,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 9,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: const Color(0xFF0C101A),
              child: Image.network(
                item.skin.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.shield, color: accent, size: 36),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.black87,
            padding: const EdgeInsets.all(8),
            child: Text(
              item.skin.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
