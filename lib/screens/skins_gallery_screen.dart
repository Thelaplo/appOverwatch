import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import '../models/hero.dart';
import '../models/hero_cosmetics.dart';
import '../utils/image_helper.dart';

class SkinsGalleryScreen extends StatefulWidget {
  const SkinsGalleryScreen({super.key});

  @override
  State<SkinsGalleryScreen> createState() => _SkinsGalleryScreenState();
}

class _SkinsGalleryScreenState extends State<SkinsGalleryScreen> {
  String _activeFilter = 'TOUS';
  String? _playingHero;
  List<HeroSummary> _apiHeroes = [];

  @override
  void initState() {
    super.initState();
    _loadHeroesFromApi();
  }

  Future<void> _loadHeroesFromApi() async {
    try {
      final res = await http.get(Uri.parse('https://overfast-api.tekrop.fr/heroes?locale=fr-fr'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        if (mounted) {
          setState(() {
            _apiHeroes = data.map((j) => HeroSummary.fromJson(j)).toList();
          });
        }
      }
    } catch (_) {}
  }

  void _playVoiceSound(HeroVoiceLine line) {
    setState(() => _playingHero = line.hero);

    if (kIsWeb) {
      try {
        js.context.callMethod('eval', [
          '''
          (function(text, freq) {
            try {
              var AudioCtx = window.AudioContext || window.webkitAudioContext;
              if (AudioCtx) {
                var ctx = new AudioCtx();
                ctx.resume().then(function() {
                  var osc = ctx.createOscillator();
                  var gain = ctx.createGain();
                  osc.type = 'sawtooth';
                  osc.frequency.setValueAtTime(freq, ctx.currentTime);
                  osc.frequency.exponentialRampToValueAtTime(freq * 1.6, ctx.currentTime + 0.3);
                  gain.gain.setValueAtTime(0.3, ctx.currentTime);
                  gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.35);
                  osc.connect(gain);
                  gain.connect(ctx.destination);
                  osc.start(0);
                  osc.stop(ctx.currentTime + 0.35);
                });
              }
              // Prononce également la réplique officielle à voix haute
              if ('speechSynthesis' in window) {
                window.speechSynthesis.cancel();
                var msg = new SpeechSynthesisUtterance(text.replace(/[«»]/g, ''));
                msg.lang = 'fr-FR';
                msg.rate = 1.05;
                window.speechSynthesis.speak(msg);
              }
            } catch(e) {}
          })('${line.text.replaceAll("'", "\\'")}', ${line.freq})
          '''
        ]);
      } catch (_) {}
    }

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _playingHero = null);
    });
  }

  String _findHeroPortrait(String heroName) {
    final clean = heroName.toUpperCase().trim();
    final match = _apiHeroes.where((h) => h.name.toUpperCase().contains(clean) || clean.contains(h.name.toUpperCase())).toList();
    if (match.isNotEmpty) return match.first.portrait;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final filteredSkins = _activeFilter == 'TOUS'
        ? kOfficialSkins
        : kOfficialSkins.where((s) => s.rarity.label == _activeFilter).toList();

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
                  const Text('GALERIE DES SKINS OFFICIELS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  const Text('Modèles rares, épiques et légendaires déblocables.', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 14),

                  Row(
                    children: ['TOUS', 'LÉGENDAIRE', 'ÉPIQUE'].map((filter) {
                      final active = _activeFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter, style: TextStyle(color: active ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          selected: active,
                          selectedColor: const Color(0xFFF99E1A),
                          backgroundColor: const Color(0xFF141926),
                          onSelected: (_) => setState(() => _activeFilter = filter),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  const Text('RÉPLIQUES AUDIO (CLIQUE POUR ÉCOUTER)', style: TextStyle(color: Color(0xFFF99E1A), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
                  const SizedBox(height: 8),

                  SizedBox(
                    height: 64,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: kOfficialVoiceLines.length,
                      itemBuilder: (ctx, i) {
                        final v = kOfficialVoiceLines[i];
                        final isPlaying = _playingHero == v.hero;

                        return InkWell(
                          onTap: () => _playVoiceSound(v),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isPlaying ? const Color(0xFF1F2838) : const Color(0xFF141926),
                              border: Border.all(color: isPlaying ? const Color(0xFFF99E1A) : Colors.white12, width: isPlaying ? 2 : 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Icon(isPlaying ? Icons.graphic_eq : Icons.volume_up, color: const Color(0xFFF99E1A), size: 20),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(v.hero.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                                    Text(v.text, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final skin = filteredSkins[i];
                  final rarityColor = Color(skin.rarity.colorValue);
                  final portrait = _findHeroPortrait(skin.heroName);

                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF141926),
                      border: Border.all(color: rarityColor, width: 2),
                      boxShadow: [BoxShadow(color: rarityColor.withAlpha(60), blurRadius: 10)],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          color: rarityColor,
                          child: Text(skin.rarity.label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 9)),
                        ),
                        Expanded(
                          child: Container(
                            color: const Color(0xFF0C101A),
                            child: portrait.isNotEmpty
                                ? Image.network(
                                    buildImageUrl(portrait, width: 340),
                                    fit: BoxFit.cover,
                                  )
                                : Center(child: Icon(Icons.shield, color: rarityColor, size: 36)),
                          ),
                        ),
                        Container(
                          color: Colors.black87,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(skin.heroName, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                              Text(skin.skinName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: filteredSkins.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}