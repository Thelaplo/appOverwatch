import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/hero.dart';
import '../utils/image_helper.dart';
import '../widgets/hero_perks_section.dart';
import '../widgets/blizzard_background_video.dart';

class HeroDetailScreen extends StatefulWidget {
  final String heroKey;
  const HeroDetailScreen({super.key, required this.heroKey});

  @override
  State<HeroDetailScreen> createState() => _HeroDetailScreenState();
}

class _HeroDetailScreenState extends State<HeroDetailScreen> {
  late Future<HeroDetail> _detailFuture;
  int _selectedAbilityIndex = 0;

  @override
  void initState() {
    super.initState();
    _detailFuture = _fetchDetail(widget.heroKey);
  }

  Future<HeroDetail> _fetchDetail(String key) async {
    final res = await http.get(Uri.parse('https://overfast-api.tekrop.fr/heroes/$key?locale=fr-fr'));
    if (res.statusCode == 200) {
      return HeroDetail.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
    }
    throw Exception('Erreur');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C101A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: FutureBuilder<HeroDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFF99E1A)));
          final hero = snapshot.data!;
          final activeAbility = hero.abilities.isNotEmpty ? hero.abilities[_selectedAbilityIndex] : null;

          final abilityVideoUrl = (activeAbility != null && activeAbility.videoUrl != null && activeAbility.videoUrl!.isNotEmpty)
              ? activeAbility.videoUrl!
              : 'https://assets.blz-contentstack.com/v3/assets/blt9c12f249ac15c7ec/blt6d55d28aa0743b17/633e0a29482813098319f359/overwatch-bg.mp4';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête héroïque ajusté (visage centré et visible)
                Container(
                  color: const Color(0xFF3B332B),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 380,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          alignment: Alignment.center,
                          children: [
                            // Fond assombri pour l'ambiance
                            Container(color: const Color(0xFF28231E)),
                            // Image avec containment pour éviter de couper le haut du crâne
                            Padding(
                              padding: const EdgeInsets.only(top: 40, bottom: 60),
                              child: Image.network(
                                buildImageUrl(hero.portrait, width: 500),
                                fit: BoxFit.contain,
                                alignment: Alignment.topCenter,
                              ),
                            ),
                            // Dégradé pour fondre dans le texte
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Color(0x663B332B), Color(0xFF3B332B)],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 20,
                              right: 20,
                              child: Column(
                                children: [
                                  Text(
                                    hero.name.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 2),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    hero.description ?? '',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 6, 24, 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _heroInfoRow(Icons.add_circle, hero.role.toUpperCase()),
                            _heroInfoRow(Icons.bolt, 'Tactique & Précision'),
                            if (hero.location != null) _heroInfoRow(Icons.location_on, hero.location!),
                            _heroInfoRow(Icons.card_giftcard, 'Âge classifié (Archives Overwatch)'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Section Capacités avec fond vidéo
                SizedBox(
                  height: 480,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      BlizzardBackgroundVideo(videoUrl: abilityVideoUrl),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withAlpha(200), Colors.black.withAlpha(90), Colors.black.withAlpha(220)],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const Text('CAPACITÉS', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                const SizedBox(height: 16),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: hero.abilities.asMap().entries.map((e) {
                                      final active = e.key == _selectedAbilityIndex;
                                      return GestureDetector(
                                        onTap: () => setState(() => _selectedAbilityIndex = e.key),
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 6),
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: active ? Colors.white : Colors.white38, width: active ? 3 : 1),
                                            color: Colors.black.withAlpha(140),
                                          ),
                                          child: ClipOval(child: Image.network(buildImageUrl(e.value.iconUrl, width: 80), fit: BoxFit.cover)),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                            if (activeAbility != null)
                              Column(
                                children: [
                                  Text(
                                    activeAbility.name.toUpperCase(),
                                    style: const TextStyle(color: Color(0xFFF99E1A), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    activeAbility.description,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Section BONUS
                HeroPerksSection(heroKey: widget.heroKey),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _heroInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.white70),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}