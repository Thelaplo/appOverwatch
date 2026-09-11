import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/hero.dart';
import '../widgets/hero_card_blizzard.dart';
import 'hero_detail_screen.dart';

class HeroCatalogScreen extends StatefulWidget {
  const HeroCatalogScreen({super.key});

  @override
  State<HeroCatalogScreen> createState() => _HeroCatalogScreenState();
}

class _HeroCatalogScreenState extends State<HeroCatalogScreen> {
  late Future<List<HeroSummary>> _heroesFuture;
  String _selectedRole = 'TOUS';
  String _selectedMode = 'PARTIE RAPIDE';

  @override
  void initState() {
    super.initState();
    _heroesFuture = _fetchHeroes();
  }

  Future<List<HeroSummary>> _fetchHeroes() async {
    try {
      final res = await http.get(Uri.parse('https://overfast-api.tekrop.fr/heroes?locale=fr-fr'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        return data.map((json) => HeroSummary.fromJson(json)).toList();
      }
    } catch (_) {
      // Hors ligne : liste vide plutot qu'un chargement infini.
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D3B73), Color(0xFF091C38), Color(0xFF06101E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildSelectBox('RÔLE', _selectedRole, ['TOUS', 'TANK', 'DÉGÂTS', 'SOUTIEN'], (v) => setState(() => _selectedRole = v))),
                    const SizedBox(width: 12),
                    Expanded(child: _buildSelectBox('MODE DE JEU', _selectedMode, ['PARTIE RAPIDE', 'COMPÉTITIF', 'ARCADE'], (v) => setState(() => _selectedMode = v))),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Overwatch met en avant de puissants héros internationaux aux personnalités et origines captivantes. Découvrez cette impressionnante distribution plus en détails.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<HeroSummary>>(
              future: _heroesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFF99E1A)));
                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Impossible de charger les héros.\nVérifie ta connexion.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                  );
                }
                final heroes = snapshot.data!.where((h) {
                  if (_selectedRole == 'TANK') return h.role == 'tank';
                  if (_selectedRole == 'DÉGÂTS') return h.role == 'damage';
                  if (_selectedRole == 'SOUTIEN') return h.role == 'support';
                  return true;
                }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: heroes.length,
                  itemBuilder: (ctx, i) {
                    final hero = heroes[i];
                    return HeroCardBlizzard(
                      hero: hero,
                      onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => HeroDetailScreen(heroKey: hero.key))),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectBox(String label, String value, List<String> options, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 38,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              dropdownColor: Colors.white, // Résout le fond noir
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
              items: options.map((o) {
                return DropdownMenuItem(
                  value: o,
                  child: Text(
                    o,
                    style: const TextStyle(color: Color(0xFF1B202D), fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                );
              }).toList(),
              onChanged: (v) => v != null ? onChanged(v) : null,
            ),
          ),
        ),
      ],
    );
  }
}