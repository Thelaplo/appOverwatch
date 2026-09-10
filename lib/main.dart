import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const OverwatchApp());
}

// Optimisation CDN : cache mondial + redimensionnement à la volée pour zéro lag
String buildImageUrl(String originalUrl, {int? width}) {
  if (originalUrl.isEmpty) return '';
  if (kIsWeb) {
    final cleanUrl = originalUrl.replaceFirst(RegExp(r'^https?:\/\/'), '');
    final resizeParam = width != null ? '&w=$width&q=80&output=webp' : '&q=85&output=webp';
    return 'https://images.weserv.nl/?url=$cleanUrl$resizeParam';
  }
  return originalUrl;
}

class OverwatchApp extends StatelessWidget {
  const OverwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overwatch Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF14171E),
        primaryColor: const Color(0xFFF99E1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF99E1A),
          secondary: Color(0xFF405275),
          surface: Color(0xFF1F232D),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF11141A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ),
      home: const HeroCatalogScreen(),
    );
  }
}

// -------------------------------------------------------------
// Modèles de données
// -------------------------------------------------------------
class HeroSummary {
  final String key;
  final String name;
  final String role;
  final String portrait;

  HeroSummary({
    required this.key,
    required this.name,
    required this.role,
    required this.portrait,
  });

  factory HeroSummary.fromJson(Map<String, dynamic> json) {
    return HeroSummary(
      key: json['key'] ?? '',
      name: json['name'] ?? 'Inconnu',
      role: json['role'] ?? 'unknown',
      portrait: json['portrait'] ?? '',
    );
  }
}

class Ability {
  final String name;
  final String description;
  final String iconUrl;

  Ability({
    required this.name,
    required this.description,
    required this.iconUrl,
  });

  factory Ability.fromJson(Map<String, dynamic> json) {
    return Ability(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['icon'] ?? '',
    );
  }
}

class HeroDetail {
  final String name;
  final String role;
  final String portrait;
  final String? realName;
  final String? location;
  final String? description;
  final List<Ability> abilities;

  HeroDetail({
    required this.name,
    required this.role,
    required this.portrait,
    this.realName,
    this.location,
    this.description,
    required this.abilities,
  });

  factory HeroDetail.fromJson(Map<String, dynamic> json) {
    final story = json['story'] as Map<String, dynamic>?;
    final abilitiesList = (json['abilities'] as List<dynamic>?) ?? [];

    return HeroDetail(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      portrait: json['portrait'] ?? '',
      realName: json['real_name'] ?? story?['real_name'],
      location: json['location'] ?? story?['location'],
      description: story?['summary'] ?? json['description'],
      abilities: abilitiesList.map((a) => Ability.fromJson(a)).toList(),
    );
  }
}

// -------------------------------------------------------------
// Écran 1 : Grille des héros
// -------------------------------------------------------------
class HeroCatalogScreen extends StatefulWidget {
  const HeroCatalogScreen({super.key});

  @override
  State<HeroCatalogScreen> createState() => _HeroCatalogScreenState();
}

class _HeroCatalogScreenState extends State<HeroCatalogScreen> {
  late Future<List<HeroSummary>> _heroesFuture;
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    _heroesFuture = fetchHeroes();
  }

  Future<List<HeroSummary>> fetchHeroes() async {
    final url = Uri.parse('https://overfast-api.tekrop.fr/heroes?locale=fr-fr');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => HeroSummary.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de chargement');
    }
  }

  String _formatRole(String role) {
    switch (role) {
      case 'tank':
        return 'TANK';
      case 'damage':
        return 'DÉGÂTS';
      case 'support':
        return 'SOUTIEN';
      default:
        return role.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OVERWATCH HEROES'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  _buildFilterChip('TOUS', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('TANK', 'tank'),
                  const SizedBox(width: 8),
                  _buildFilterChip('DÉGÂTS', 'damage'),
                  const SizedBox(width: 8),
                  _buildFilterChip('SOUTIEN', 'support'),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<HeroSummary>>(
              future: _heroesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFF99E1A)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }

                final allHeroes = snapshot.data ?? [];
                final heroes = _selectedRole == 'all'
                    ? allHeroes
                    : allHeroes.where((h) => h.role == _selectedRole).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: heroes.length,
                  itemBuilder: (context, index) {
                    final hero = heroes[index];
                    return _buildHeroCard(hero);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String roleKey) {
    final isSelected = _selectedRole == roleKey;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: isSelected ? Colors.black : Colors.white70,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFFF99E1A),
      backgroundColor: const Color(0xFF1F232D),
      onSelected: (_) => setState(() => _selectedRole = roleKey),
    );
  }

  Widget _buildHeroCard(HeroSummary hero) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HeroDetailScreen(heroKey: hero.key),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F232D),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withAlpha(15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: hero.key,
                child: Image.network(
                  buildImageUrl(hero.portrait, width: 250),
                  fit: BoxFit.cover,
                  cacheWidth: 250,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFF181B22),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF99E1A)),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 40, color: Colors.white38),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                children: [
                  Text(
                    hero.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatRole(hero.role),
                    style: const TextStyle(
                      color: Color(0xFFF99E1A),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// Écran 2 : Fiche de profil détaillée du Héros
// -------------------------------------------------------------
class HeroDetailScreen extends StatefulWidget {
  final String heroKey;

  const HeroDetailScreen({super.key, required this.heroKey});

  @override
  State<HeroDetailScreen> createState() => _HeroDetailScreenState();
}

class _HeroDetailScreenState extends State<HeroDetailScreen> {
  late Future<HeroDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = fetchHeroDetail(widget.heroKey);
  }

  Future<HeroDetail> fetchHeroDetail(String key) async {
    final url = Uri.parse('https://overfast-api.tekrop.fr/heroes/$key?locale=fr-fr');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return HeroDetail.fromJson(data);
    } else {
      throw Exception('Impossible de charger les détails du héros');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFIL DU HÉROS'),
      ),
      body: FutureBuilder<HeroDetail>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFF99E1A)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final hero = snapshot.data!;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // En-tête / Bannière de profil
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF282E3E), Color(0xFF14171E)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Hero(
                        tag: widget.heroKey,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFF99E1A), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF99E1A).withAlpha(70),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              buildImageUrl(hero.portrait, width: 300),
                              fit: BoxFit.cover,
                              cacheWidth: 300,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        hero.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      if (hero.realName != null && hero.realName!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          hero.realName!,
                          style: const TextStyle(color: Colors.white60, fontSize: 14),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF99E1A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          hero.role.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Section Lore / Biographie
                if (hero.description != null && hero.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F232D),
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(
                          left: BorderSide(color: Color(0xFFF99E1A), width: 4),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HISTOIRE',
                            style: TextStyle(
                              color: Color(0xFFF99E1A),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            hero.description!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Section Capacités
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Text(
                    'CAPACITÉS',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: hero.abilities.length,
                  itemBuilder: (context, index) {
                    final ability = hero.abilities[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F232D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14171E),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ability.iconUrl.isNotEmpty
                                ? Image.network(
                                    buildImageUrl(ability.iconUrl, width: 80),
                                    fit: BoxFit.contain,
                                    cacheWidth: 80,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.flash_on, color: Color(0xFFF99E1A)),
                                  )
                                : const Icon(Icons.flash_on, color: Color(0xFFF99E1A)),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ability.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ability.description,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}