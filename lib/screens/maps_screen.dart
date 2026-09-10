import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/map_item.dart';
import '../utils/image_helper.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late Future<List<MapItem>> _mapsFuture;
  String _selectedMode = 'ALL';

  @override
  void initState() {
    super.initState();
    _mapsFuture = fetchMaps();
  }

  Future<List<MapItem>> fetchMaps() async {
    final url = Uri.parse('https://overfast-api.tekrop.fr/maps?locale=fr-fr');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((json) => MapItem.fromJson(json)).toList();
    }
    throw Exception('Impossible de charger les cartes');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1017),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080A0F),
        elevation: 0,
        title: Transform(
          transform: Matrix4.skewX(-0.18),
          child: const Text(
            'CHAMPS DE BATAILLE',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white),
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                _buildModeBtn('TOUS', 'ALL'),
                const SizedBox(width: 8),
                _buildModeBtn('CONTRÔLE', 'CONTROL'),
                const SizedBox(width: 8),
                _buildModeBtn('CONVOI', 'ESCORT'),
                const SizedBox(width: 8),
                _buildModeBtn('HYBRIDE', 'HYBRID'),
                const SizedBox(width: 8),
                _buildModeBtn('POINT CHAUD', 'FLASHPOINT'),
                const SizedBox(width: 8),
                _buildModeBtn('AVANCÉE', 'PUSH'),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<MapItem>>(
              future: _mapsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFF99E1A)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.white70)));
                }

                final all = snapshot.data ?? [];
                final maps = _selectedMode == 'ALL'
                    ? all
                    : all.where((m) => m.gamemodes.any((g) => g.contains(_selectedMode))).toList();

                if (maps.isEmpty) {
                  return const Center(child: Text('Aucune carte trouvée pour ce mode', style: TextStyle(color: Colors.white54)));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 420,
                    mainAxisExtent: 180,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: maps.length,
                  itemBuilder: (context, index) => _CinematicMapCard(map: maps[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeBtn(String label, String modeKey) {
    final active = _selectedMode == modeKey;
    return InkWell(
      onTap: () => setState(() => _selectedMode = modeKey),
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

class _CinematicMapCard extends StatefulWidget {
  final MapItem map;
  const _CinematicMapCard({required this.map});

  @override
  State<_CinematicMapCard> createState() => _CinematicMapCardState();
}

class _CinematicMapCardState extends State<_CinematicMapCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: _hover ? const Color(0xFFF99E1A) : Colors.white12,
            width: _hover ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (widget.map.image != null && widget.map.image!.isNotEmpty)
              AnimatedScale(
                scale: _hover ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Image.network(buildImageUrl(widget.map.image!, width: 600), fit: BoxFit.cover, cacheWidth: 600),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withAlpha(30), Colors.black.withAlpha(210)],
                ),
              ),
            ),
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Transform(
                      transform: Matrix4.skewX(-0.16),
                      child: Text(
                        widget.map.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.white),
                      ),
                    ),
                  ),
                  if (widget.map.gamemodes.isNotEmpty)
                    Transform(
                      transform: Matrix4.skewX(-0.16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        color: _hover ? const Color(0xFFF99E1A) : Colors.black87,
                        child: Text(
                          widget.map.gamemodes.first,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            color: _hover ? Colors.black : const Color(0xFFF99E1A),
                          ),
                        ),
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