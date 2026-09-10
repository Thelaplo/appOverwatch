import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/hero.dart';
import '../utils/image_helper.dart';
import '../widgets/hero_counters_section.dart';

class HeroDetailScreen extends StatefulWidget {
  final String heroKey;
  const HeroDetailScreen({super.key, required this.heroKey});

  @override
  State<HeroDetailScreen> createState() => _HeroDetailScreenState();
}

class _HeroDetailScreenState extends State<HeroDetailScreen> {
  late Future<HeroDetail> _detailFuture;

  final Map<String, String> _heroCinematics = const {
    'kiriko': 'https://overwatch.blizzard.com/fr-fr/heroes/kiriko/',
    'reinhardt': 'https://overwatch.blizzard.com/fr-fr/heroes/reinhardt/',
    'winston': 'https://overwatch.blizzard.com/fr-fr/heroes/winston/',
    'dva': 'https://overwatch.blizzard.com/fr-fr/heroes/dva/',
    'genji': 'https://overwatch.blizzard.com/fr-fr/heroes/genji/',
    'hanzo': 'https://overwatch.blizzard.com/fr-fr/heroes/hanzo/',
  };

  @override
  void initState() {
    super.initState();
    _detailFuture = _fetchDetail(widget.heroKey);
  }

  Future<HeroDetail> _fetchDetail(String key) async {
    final url = Uri.parse('https://overfast-api.tekrop.fr/heroes/$key?locale=fr-fr');
    final res = await http.get(url);
    if (res.statusCode == 200) {
      return HeroDetail.fromJson(jsonDecode(utf8.decode(res.bodyBytes)));
    }
    throw Exception('Impossible de charger le héros');
  }

  @override
  Widget build(BuildContext context) {
    final cinematic = _heroCinematics[widget.heroKey.toLowerCase()];

    return Scaffold(
      backgroundColor: const Color(0xFF0C0F16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080A0F),
        elevation: 0,
        title: Transform(
          transform: Matrix4.skewX(-0.16),
          child: const Text('FICHE DE COMBAT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18)),
        ),
      ),
      body: FutureBuilder<HeroDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF99E1A)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
          }

          final hero = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(hero),
                _buildHpSection(hero),
                HeroCountersSection(heroKey: widget.heroKey),
                if (hero.description != null && hero.description!.isNotEmpty)
                  _buildBioSection(hero.description!, cinematic),
                _buildAbilities(hero),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(HeroDetail hero) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF1E2433), Color(0xFF0C0F16)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0xFFF99E1A), width: 3)),
            child: ClipOval(child: Image.network(buildImageUrl(hero.portrait, width: 280), fit: BoxFit.cover)),
          ),
          const SizedBox(height: 10),
          Transform(
            transform: Matrix4.skewX(-0.18),
            child: Text(hero.name.toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _badge(hero.role.toUpperCase(), const Color(0xFFF99E1A), Colors.black),
              if (hero.location != null && hero.location!.isNotEmpty)
                _badge(hero.location!, const Color(0xFF1B202D), Colors.white70),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHpSection(HeroDetail hero) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFF141822), border: Border.all(color: Colors.white12)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('POINTS DE VIE', style: TextStyle(color: Color(0xFFF99E1A), fontWeight: FontWeight.w900, fontSize: 11)),
                Text('${hero.totalHp} PV', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: SizedBox(
                height: 10,
                child: Row(
                  children: [
                    if (hero.health > 0) Expanded(flex: hero.health, child: Container(color: Colors.white)),
                    if (hero.armor > 0) Expanded(flex: hero.armor, child: Container(color: const Color(0xFFF99E1A))),
                    if (hero.shields > 0) Expanded(flex: hero.shields, child: Container(color: const Color(0xFF00E5FF))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection(String desc, String? cineUrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(color: Color(0xFF141822), border: Border(left: BorderSide(color: Color(0xFFF99E1A), width: 4))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
            if (cineUrl != null) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF99E1A), foregroundColor: Colors.black),
                icon: const Icon(Icons.movie, size: 16),
                label: const Text('COURT-MÉTRAGE OFFICIEL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11)),
                onPressed: () => launchUrl(Uri.parse(cineUrl), mode: LaunchMode.externalApplication),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAbilities(HeroDetail hero) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: hero.abilities.length,
      itemBuilder: (ctx, i) {
        final a = hero.abilities[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          color: const Color(0xFF141822),
          child: Row(
            children: [
              Image.network(buildImageUrl(a.iconUrl, width: 60), width: 40, height: 40, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.flash_on, color: Color(0xFFF99E1A))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFF99E1A))),
                    Text(a.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _badge(String txt, Color bg, Color clr) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), color: bg, child: Text(txt, style: TextStyle(color: clr, fontWeight: FontWeight.bold, fontSize: 10)));
}