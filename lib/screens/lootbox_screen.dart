import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/hero.dart';
import '../models/loot_drop.dart';
import '../utils/image_helper.dart';

class LootboxScreen extends StatefulWidget {
  const LootboxScreen({super.key});

  @override
  State<LootboxScreen> createState() => _LootboxScreenState();
}

class _LootboxScreenState extends State<LootboxScreen> with SingleTickerProviderStateMixin {
  List<HeroSummary> _heroes = [];
  List<LootItem>? _drops;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
    _fetchHeroes();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _fetchHeroes() async {
    final res = await http.get(Uri.parse('https://overfast-api.tekrop.fr/heroes?locale=fr-fr'));
    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
      if (mounted) setState(() => _heroes = data.map((j) => HeroSummary.fromJson(j)).toList());
    }
  }

  void _openBox() {
    if (_heroes.isEmpty || _anim.isAnimating) return;
    setState(() => _drops = null);
    _anim.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() => _drops = LootboxRoll.roll4Items(_heroes));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07090E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF04060A),
        elevation: 0,
        title: Transform(
          transform: Matrix4.skewX(-0.16),
          child: const Text('COFFRES DE BUTIN', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18)),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Halo d'ambiance au sol (Podium Blizzard)
          Positioned(
            bottom: 60,
            child: Container(
              width: 500,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [const Color(0xFFF99E1A).withAlpha(90), Colors.transparent],
                ),
              ),
            ),
          ),

          // Contenu principal : Coffre 3D ou les 4 drops
          Center(
            child: _drops == null ? _build3DBox() : _build4DropsRow(_drops!),
          ),

          // Bouton d'action en bas
          Positioned(
            bottom: 30,
            child: SizedBox(
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF99E1A),
                  foregroundColor: Colors.black,
                  shape: const BeveledRectangleBorder(),
                ),
                onPressed: _heroes.isEmpty || _anim.isAnimating ? null : _openBox,
                child: Transform(
                  transform: Matrix4.skewX(-0.16),
                  child: Text(
                    _drops == null ? 'OUVRIR LE COFFRE (1)' : 'OUVRIR UN AUTRE COFFRE',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _build3DBox() {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final val = _anim.value;
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.002) // Perspective 3D
          ..rotateX(-0.18 + (val * 0.4))
          ..rotateY((val * 6.28)); // Tour complet lors du clic

        return Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2B3345), Color(0xFF141824)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              border: Border.all(color: const Color(0xFFF99E1A), width: 3),
              boxShadow: [
                BoxShadow(color: const Color(0xFFF99E1A).withAlpha(120), blurRadius: 35, spreadRadius: 4),
              ],
            ),
            child: const Center(
              child: Icon(Icons.token, size: 75, color: Color(0xFFF99E1A)),
            ),
          ),
        );
      },
    );
  }

  Widget _build4DropsRow(List<LootItem> items) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          // Rotation et inclinaison pour faire l'effet d'éventail 3D
          final angle = (idx - 1.5) * 0.08;

          return Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateZ(angle),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 140,
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF10141D),
                border: Border.all(color: item.rarity.color, width: 2.5),
                boxShadow: [
                  BoxShadow(color: item.rarity.color.withAlpha(130), blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: item.rarity.color,
                    child: Text(
                      item.rarity.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1),
                    ),
                  ),
                  Expanded(
                    child: Image.network(
                      buildImageUrl(item.hero.portrait, width: 220),
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text(
                      item.hero.name.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}