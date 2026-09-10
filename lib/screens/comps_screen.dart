import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/hero.dart';
import '../utils/comp_analyzer.dart';
import '../utils/image_helper.dart';

class CompsScreen extends StatefulWidget {
  const CompsScreen({super.key});

  @override
  State<CompsScreen> createState() => _CompsScreenState();
}

class _CompsScreenState extends State<CompsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<HeroSummary>> _heroesFuture;
  final List<HeroSummary?> _team = [null, null, null, null, null];

  final List<Map<String, dynamic>> _metaComps = const [
    {
      'name': 'DIVE CLASSIQUE (PLONGÉE)',
      'desc': 'Forte mobilité pour assassiner les cibles isolées en retrait.',
      'heroes': ['Winston', 'Genji', 'Tracer', 'Kiriko', 'Lucio'],
      'color': Color(0xFF00E5FF),
    },
    {
      'name': 'BRAWL / RUSH (CHOC FRONTAL)',
      'desc': 'Avancée compacte à haute vitesse sous la protection d\'un bouclier.',
      'heroes': ['Reinhardt', 'Mei', 'Faucheur', 'Lucio', 'Baptiste'],
      'color': Color(0xFFFF5252),
    },
    {
      'name': 'POKE / SPAM (DISTANCE)',
      'desc': 'Pression continue à longue portée pour forcer l\'ennemi à l\'erreur.',
      'heroes': ['Sigma', 'Ashe', 'Fatale', 'Zenyatta', 'Ana'],
      'color': Color(0xFFF99E1A),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _heroesFuture = _fetchHeroes();
  }

  Future<List<HeroSummary>> _fetchHeroes() async {
    final res = await http.get(Uri.parse('https://overfast-api.tekrop.fr/heroes?locale=fr-fr'));
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
      return data.map((j) => HeroSummary.fromJson(j)).toList();
    }
    throw Exception('Erreur API');
  }

  void _openHeroPicker(int slotIndex, String targetRole, List<HeroSummary> heroes) {
    final roleHeroes = heroes.where((h) => h.role == targetRole).toList();
    showModalBottomSheet(
      backgroundColor: const Color(0xFF141822),
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CHOISIR UN ${targetRole.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFFF99E1A))),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8,
                ),
                itemCount: roleHeroes.length,
                itemBuilder: (_, i) {
                  final h = roleHeroes[i];
                  return InkWell(
                    onTap: () {
                      setState(() => _team[slotIndex] = h);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.white24), color: const Color(0xFF0C0F16)),
                      child: Column(
                        children: [
                          Expanded(child: Image.network(buildImageUrl(h.portrait, width: 140), fit: BoxFit.cover)),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(h.name.toUpperCase(), maxLines: 1, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0F16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080A0F),
        elevation: 0,
        title: Transform(
          transform: Matrix4.skewX(-0.16),
          child: const Text('STRATÉGIES & COMPOSITIONS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18)),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF99E1A),
          labelColor: const Color(0xFFF99E1A),
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'MÉTA OFFICIELLES'),
            Tab(text: 'CRÉATEUR 5V5'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet 1 : Les compos méta (Dive, Rush, Poke)
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _metaComps.length,
            itemBuilder: (_, i) {
              final comp = _metaComps[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF141822),
                  border: Border(left: BorderSide(color: comp['color'] as Color, width: 4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(comp['name'], style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: comp['color'] as Color)),
                    const SizedBox(height: 4),
                    Text(comp['desc'], style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      children: (comp['heroes'] as List<String>).map((h) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          color: const Color(0xFF0C0F16),
                          child: Text(h.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),

          // Onglet 2 : Le simulateur interactif
          FutureBuilder<List<HeroSummary>>(
            future: _heroesFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFFF99E1A)));
              final heroes = snapshot.data!;
              final analysis = analyzeTeam(_team);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        _slot(0, 'TANK', 'tank', heroes),
                        _slot(1, 'DPS', 'damage', heroes),
                        _slot(2, 'DPS', 'damage', heroes),
                        _slot(3, 'HEAL', 'support', heroes),
                        _slot(4, 'HEAL', 'support', heroes),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: const Color(0xFF141822),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('POINTS DE VIE ESTIMÉS', style: TextStyle(color: Color(0xFFF99E1A), fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('${analysis.totalHp} PV', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...analysis.strengths.map((s) => _diag(s, const Color(0xFF00E676))),
                    ...analysis.warnings.map((w) => _diag(w, const Color(0xFFFF5252))),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _slot(int i, String label, String role, List<HeroSummary> heroes) {
    final hero = _team[i];
    return Expanded(
      child: GestureDetector(
        onTap: () => _openHeroPicker(i, role, heroes),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF141822),
            border: Border.all(color: hero != null ? const Color(0xFFF99E1A) : Colors.white24),
          ),
          child: hero == null
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.add, color: Colors.white38, size: 20),
                  Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white54)),
                ])
              : Stack(fit: StackFit.expand, children: [
                  Image.network(buildImageUrl(hero.portrait, width: 120), fit: BoxFit.cover),
                  Positioned(bottom: 0, left: 0, right: 0, child: Container(color: Colors.black87, child: Text(hero.name.toUpperCase(), textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold)))),
                ]),
        ),
      ),
    );
  }

  Widget _diag(String text, Color color) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: const Color(0xFF141822), border: Border(left: BorderSide(color: color, width: 3))),
        child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      );
}