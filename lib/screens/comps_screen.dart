import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/hero.dart';
import '../utils/comp_analyzer.dart';
import '../utils/hero_stats_api.dart';
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

  /// Points de vie reels des heros selectionnes, charges a la demande.
  Map<String, HeroHitpoints> _hitpoints = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _heroesFuture = _fetchHeroes();
  }

  /// Recupere les points de vie des heros de l'escouade. Tant qu'ils ne sont
  /// pas la, l'analyse affiche une estimation par role.
  Future<void> _loadHitpoints() async {
    final keys = _team.whereType<HeroSummary>().map((h) => h.key).toList();
    if (keys.isEmpty) return;

    final loaded = await HeroStatsApi.fetchAll(keys);
    if (!mounted) return;
    setState(() => _hitpoints = loaded);
  }

  Future<List<HeroSummary>> _fetchHeroes() async {
    try {
      final res = await http.get(Uri.parse('https://overfast-api.tekrop.fr/heroes?locale=fr-fr'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        return data.map((j) => HeroSummary.fromJson(j)).toList();
      }
    } catch (_) {
      // Hors ligne : on renvoie une liste vide plutot que de laisser le
      // FutureBuilder sur un chargement infini.
    }
    return [];
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
                      _loadHitpoints();
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
              if (heroes.isEmpty) {
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
              final analysis = analyzeTeam(_team, hitpoints: _hitpoints);

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
                    if (!analysis.isEmpty) ...[
                      _styleBanner(analysis),
                      const SizedBox(height: 12),
                      _hitpointsPanel(analysis),
                      const SizedBox(height: 12),
                      _rolePanel(analysis),
                      const SizedBox(height: 12),
                      if (analysis.ultCombos.isNotEmpty) ...[
                        _sectionTitle('COMBOS D\'ULTIMES'),
                        ...analysis.ultCombos.map(
                          (c) => _diag(c, const Color(0xFFD500F9), Icons.auto_awesome),
                        ),
                        const SizedBox(height: 6),
                      ],
                    ],
                    ..._notesSection(analysis, NoteKind.strength, 'POINTS FORTS',
                        const Color(0xFF00E676), Icons.check_circle_outline),
                    ..._notesSection(analysis, NoteKind.warning, 'FAIBLESSES',
                        const Color(0xFFFF5252), Icons.warning_amber_rounded),
                    ..._notesSection(analysis, NoteKind.tip, 'À AJUSTER',
                        const Color(0xFFF99E1A), Icons.lightbulb_outline),
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

  Widget _diag(String text, Color color, [IconData? icon]) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF141822),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ),
          ],
        ),
      );

  Widget _sectionTitle(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      );

  /// Bandeau indiquant le style de jeu identifie.
  Widget _styleBanner(CompAnalysis analysis) {
    const colors = {
      CompStyle.dive: Color(0xFF00E5FF),
      CompStyle.brawl: Color(0xFFFF5252),
      CompStyle.poke: Color(0xFFF99E1A),
      CompStyle.hybrid: Color(0xFF9E9E9E),
      CompStyle.unknown: Color(0xFF9E9E9E),
    };
    final color = colors[analysis.style] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141822),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'STYLE : ${analysis.style.label}',
                style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const Spacer(),
              if (analysis.style != CompStyle.unknown && analysis.style != CompStyle.hybrid)
                Text(
                  '${(analysis.styleConfidence * 100).round()} %',
                  style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            analysis.style.description,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Points de vie cumules, avec le detail armure / boucliers.
  Widget _hitpointsPanel(CompAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF141822),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                analysis.hpIsExact ? 'POINTS DE VIE' : 'POINTS DE VIE (ESTIMÉS)',
                style: const TextStyle(
                  color: Color(0xFFF99E1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                '${analysis.totalHp} PV',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (analysis.armor > 0 || analysis.shields > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (analysis.armor > 0)
                  Text(
                    '${analysis.armor} armure',
                    style: const TextStyle(color: Color(0xFFFFB300), fontSize: 11),
                  ),
                if (analysis.armor > 0 && analysis.shields > 0)
                  const Text('  •  ', style: TextStyle(color: Colors.white24, fontSize: 11)),
                if (analysis.shields > 0)
                  Text(
                    '${analysis.shields} boucliers',
                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Rappel de la repartition des roles, comparee au 1-2-2 de la file par role.
  Widget _rolePanel(CompAnalysis analysis) {
    Widget cell(String label, int count, int expected) {
      final ok = count == expected;
      return Expanded(
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              '$count / $expected',
              style: TextStyle(
                color: ok ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: const Color(0xFF141822),
      child: Row(
        children: [
          cell('TANK', analysis.tanks, 1),
          cell('DÉGÂTS', analysis.damages, 2),
          cell('SOUTIEN', analysis.supports, 2),
        ],
      ),
    );
  }

  /// Une section de notes (forces, faiblesses, conseils), masquee si vide.
  List<Widget> _notesSection(
    CompAnalysis analysis,
    NoteKind kind,
    String title,
    Color color,
    IconData icon,
  ) {
    final notes = analysis.notes.where((n) => n.kind == kind).toList();
    if (notes.isEmpty) return const [];

    return [
      _sectionTitle(title),
      ...notes.map((n) => _diag(n.text, color, icon)),
      const SizedBox(height: 6),
    ];
  }
}