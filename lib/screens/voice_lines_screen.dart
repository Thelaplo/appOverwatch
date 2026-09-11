import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/hero.dart';
import '../utils/image_helper.dart';
import '../utils/voice_clip_player.dart';
import '../utils/voice_line_api.dart';

/// Ecran dedie aux repliques audio des heros.
///
/// Les repliques occupaient auparavant un bandeau au milieu de la galerie de
/// skins, ou elles n'avaient rien a faire et se limitaient a une poignee de
/// heros. Elles ont maintenant leur propre ecran, accessible depuis le menu,
/// et couvrent tout le roster.
class VoiceLinesScreen extends StatefulWidget {
  const VoiceLinesScreen({super.key});

  @override
  State<VoiceLinesScreen> createState() => _VoiceLinesScreenState();
}

class _VoiceLinesScreenState extends State<VoiceLinesScreen> {
  List<HeroSummary>? _heroes;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _loadHeroes();
  }

  Future<void> _loadHeroes() async {
    try {
      final res = await http.get(
        Uri.parse('https://overfast-api.tekrop.fr/heroes?locale=fr-fr'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
        if (!mounted) return;
        setState(() => _heroes = data.map((j) => HeroSummary.fromJson(j)).toList());
        return;
      }
    } catch (_) {
      // Hors ligne : on affiche un message plutot qu'un chargement infini.
    }
    if (mounted) setState(() => _heroes = []);
  }

  void _openHero(HeroSummary hero) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0C101A),
      isScrollControlled: true,
      builder: (_) => _HeroVoiceLines(hero: hero),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heroes = _heroes;

    if (heroes == null) {
      return const ColoredBox(
        color: Color(0xFF090D15),
        child: Center(child: CircularProgressIndicator(color: Color(0xFFF99E1A))),
      );
    }

    // On cherche aussi dans la cle, qui est en anglais : l'API renvoie les
    // noms traduits (Mercy devient « Ange », Reaper « Faucheur »), or les
    // joueurs connaissent souvent les deux.
    final query = _search.toLowerCase().trim();
    final filtered = query.isEmpty
        ? heroes
        : heroes
            .where((h) =>
                h.name.toLowerCase().contains(query) ||
                h.key.toLowerCase().replaceAll('-', ' ').contains(query))
            .toList();

    return ColoredBox(
      color: const Color(0xFF090D15),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(
                'RÉPLIQUES AUDIO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Les vraies voix du jeu. Choisis un héros pour écouter ses répliques.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Rechercher un héros',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                  filled: true,
                  fillColor: const Color(0xFF141926),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: heroes.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Impossible de charger les héros.\nVérifie ta connexion.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 130,
                        childAspectRatio: 0.82,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => _heroTile(filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroTile(HeroSummary hero) {
    return GestureDetector(
      onTap: () => _openHero(hero),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141926),
          border: Border.all(color: Colors.white12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                buildImageUrl(hero.portrait, width: 200),
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFF1B2233),
                  child: Center(child: Icon(Icons.person, color: Colors.white24)),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
              child: Text(
                hero.name.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Feuille listant les repliques d'un heros, l'ultime en tete.
class _HeroVoiceLines extends StatefulWidget {
  final HeroSummary hero;

  const _HeroVoiceLines({required this.hero});

  @override
  State<_HeroVoiceLines> createState() => _HeroVoiceLinesState();
}

class _HeroVoiceLinesState extends State<_HeroVoiceLines> {
  List<WikiVoiceLine>? _lines;
  String? _playing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final lines = await VoiceLineApi.fetchVoiceLines(
      widget.hero.key,
      widget.hero.name.toUpperCase(),
    );
    if (!mounted) return;

    // L'ultime d'abord, le reste melange pour varier d'une ouverture a l'autre.
    final random = Random();
    final ultimates = lines.where((l) => l.isUltimate).toList();
    final others = lines.where((l) => !l.isUltimate).toList()..shuffle(random);

    setState(() => _lines = [...ultimates, ...others]);
  }

  Future<void> _play(WikiVoiceLine line) async {
    setState(() => _playing = line.audioUrl);
    await VoiceClipPlayer.play(line.audioUrl);

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted && _playing == line.audioUrl) setState(() => _playing = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lines = _lines;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.hero.name.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFFF99E1A),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white38),
                  onPressed: () {
                    VoiceClipPlayer.stop();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: lines == null
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFF99E1A)))
                : lines.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Aucune réplique disponible pour ce héros sur le wiki.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: controller,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: lines.length,
                        itemBuilder: (context, i) => _lineTile(lines[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _lineTile(WikiVoiceLine line) {
    final isPlaying = _playing == line.audioUrl;
    final accent = line.isUltimate ? const Color(0xFFD500F9) : const Color(0xFFF99E1A);

    return InkWell(
      onTap: () => _play(line),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isPlaying ? const Color(0xFF1F2838) : const Color(0xFF141926),
          border: Border(left: BorderSide(color: accent, width: isPlaying ? 4 : 2)),
        ),
        child: Row(
          children: [
            Icon(
              isPlaying ? Icons.graphic_eq : Icons.play_arrow,
              color: accent,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                line.text,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            if (line.isUltimate)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: accent,
                child: const Text(
                  'ULTI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
