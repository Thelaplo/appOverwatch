import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hero.dart';
import '../utils/image_helper.dart';
import 'hero_detail_screen.dart';

class HeroCatalogScreen extends StatefulWidget {
  const HeroCatalogScreen({super.key});

  @override
  State<HeroCatalogScreen> createState() => _HeroCatalogScreenState();
}

class _HeroCatalogScreenState extends State<HeroCatalogScreen> {
  late Future<List<HeroSummary>> _heroesFuture;
  String _selectedRole = 'all';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();
  Set<String> _favoriteKeys = {};

  @override
  void initState() {
    super.initState();
    _heroesFuture = fetchHeroes();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteKeys = (prefs.getStringList('favorite_heroes') ?? []).toSet();
    });
  }

  Future<void> _toggleFavorite(String key) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favoriteKeys.contains(key)) {
        _favoriteKeys.remove(key);
      } else {
        _favoriteKeys.add(key);
      }
    });
    await prefs.setStringList('favorite_heroes', _favoriteKeys.toList());
  }

  Future<List<HeroSummary>> fetchHeroes() async {
    final url = Uri.parse('https://overfast-api.tekrop.fr/heroes?locale=fr-fr');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => HeroSummary.fromJson(json)).toList();
    }
    throw Exception('Erreur de chargement');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0F16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080A0F),
        elevation: 0,
        title: Transform(
          transform: Matrix4.skewX(-0.18),
          child: const Text(
            'HÉROS D’OVERWATCH',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Transform(
              transform: Matrix4.skewX(-0.16),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF161A24),
                  border: Border.all(color: Colors.white24),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'RECHERCHER UN HÉROS...',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFFF99E1A), size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white54, size: 16),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(top: 8),
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildRoleBtn('TOUS', 'all'),
                const SizedBox(width: 8),
                _buildRoleBtn('⭐ FAVORIS', 'favorites'),
                const SizedBox(width: 8),
                _buildRoleBtn('TANK', 'tank'),
                const SizedBox(width: 8),
                _buildRoleBtn('DÉGÂTS', 'damage'),
                const SizedBox(width: 8),
                _buildRoleBtn('SOUTIEN', 'support'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<HeroSummary>>(
              future: _heroesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFF99E1A)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
                }

                final all = snapshot.data ?? [];
                final heroes = all.where((h) {
                  final matchesFilter = _selectedRole == 'all'
                      ? true
                      : _selectedRole == 'favorites'
                          ? _favoriteKeys.contains(h.key)
                          : h.role == _selectedRole;
                  final matchesSearch = _searchQuery.isEmpty || h.name.toLowerCase().contains(_searchQuery);
                  return matchesFilter && matchesSearch;
                }).toList();

                if (heroes.isEmpty) {
                  return const Center(
                    child: Text('Aucun héros trouvé', style: TextStyle(color: Colors.white54)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 170,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: heroes.length,
                  itemBuilder: (context, index) {
                    final hero = heroes[index];
                    final isFav = _favoriteKeys.contains(hero.key);
                    return _HeroCard(
                      hero: hero,
                      isFavorite: isFav,
                      onToggleFavorite: () => _toggleFavorite(hero.key),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => HeroDetailScreen(heroKey: hero.key)),
                        );
                        _loadFavorites();
                      },
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

  Widget _buildRoleBtn(String label, String roleKey) {
    final active = _selectedRole == roleKey;
    return InkWell(
      onTap: () => setState(() => _selectedRole = roleKey),
      child: Transform(
        transform: Matrix4.skewX(-0.16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          color: active ? const Color(0xFFF99E1A) : const Color(0xFF161A24),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1.0,
              color: active ? Colors.black : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatefulWidget {
  final HeroSummary hero;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const _HeroCard({
    required this.hero,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: const Color(0xFF161A24),
            border: Border.all(
              color: _hover ? const Color(0xFFF99E1A) : Colors.white12,
              width: _hover ? 2 : 1,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                buildImageUrl(widget.hero.portrait, width: 260),
                fit: BoxFit.cover,
                cacheWidth: 260,
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.5, 1.0],
                    colors: [Colors.transparent, Color(0xF50C0F16)],
                  ),
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: Icon(
                    widget.isFavorite ? Icons.star : Icons.star_border,
                    color: widget.isFavorite ? const Color(0xFFF99E1A) : Colors.white54,
                    size: 22,
                  ),
                  onPressed: widget.onToggleFavorite,
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Transform(
                  transform: Matrix4.skewX(-0.16),
                  child: Text(
                    widget.hero.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: _hover ? const Color(0xFFF99E1A) : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}