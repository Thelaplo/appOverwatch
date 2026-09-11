import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/skin_api.dart';
import '../utils/voice_clip_player.dart';
import '../utils/voice_line_api.dart';

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

  /// Nombre de repliques proposees par heros.
  static const int _voiceLinesPerHero = 3;

  String _activeFilter = 'TOUS';
  String? _playingLine;
  List<_GallerySkin>? _skins;
  List<WikiVoiceLine> _voiceLines = [];

  @override
  void initState() {
    super.initState();
    _loadSkins();
    _loadVoiceLines();
  }

  Future<void> _loadVoiceLines() async {
    final random = Random();
    final collected = <WikiVoiceLine>[];

    for (final entry in _featuredHeroes.entries) {
      collected.addAll(
        await VoiceLineApi.sample(entry.key, entry.value, _voiceLinesPerHero, random),
      );
    }

    if (!mounted) return;
    setState(() => _voiceLines = collected);
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

  Future<void> _playVoiceSound(WikiVoiceLine line) async {
    setState(() => _playingLine = line.audioUrl);

    await VoiceClipPlayer.play(line.audioUrl);

    // Les extraits du jeu sont courts ; on retire la mise en avant peu apres.
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted && _playingLine == line.audioUrl) {
        setState(() => _playingLine = null);
      }
    });
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
                  const SizedBox(height: 18),
                  const Text(
                    'RÉPLIQUES AUDIO (CLIQUE POUR ÉCOUTER)',
                    style: TextStyle(
                      color: Color(0xFFF99E1A),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildVoiceLines(),
                  const SizedBox(height: 16),
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

  Widget _buildVoiceLines() {
    if (_voiceLines.isEmpty) {
      return const SizedBox(
        height: 64,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Chargement des répliques officielles...',
            style: TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ),
      );
    }

    return SizedBox(
      height: 64,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _voiceLines.length,
        itemBuilder: (ctx, i) {
          final v = _voiceLines[i];
          final isPlaying = _playingLine == v.audioUrl;

          return InkWell(
            onTap: () => _playVoiceSound(v),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isPlaying ? const Color(0xFF1F2838) : const Color(0xFF141926),
                border: Border.all(
                  color: isPlaying ? const Color(0xFFF99E1A) : Colors.white12,
                  width: isPlaying ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(
                    isPlaying ? Icons.graphic_eq : Icons.volume_up,
                    color: const Color(0xFFF99E1A),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            v.heroLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (v.isUltimate) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              color: const Color(0xFFD500F9),
                              child: const Text(
                                'ULTI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: Text(
                          v.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
