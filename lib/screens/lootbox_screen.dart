import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/hero.dart';
import '../models/inventory.dart';
import '../models/loot_drop.dart';
import '../utils/image_helper.dart';

class LootboxScreen extends StatefulWidget {
  /// Previent le hub qu'un tirage a modifie l'inventaire, pour que l'onglet
  /// INVENTAIRE se recharge.
  final VoidCallback? onInventoryChanged;

  const LootboxScreen({super.key, this.onInventoryChanged});

  @override
  State<LootboxScreen> createState() => _LootboxScreenState();
}

class _LootboxScreenState extends State<LootboxScreen> with SingleTickerProviderStateMixin {
  List<HeroSummary> _heroes = [];
  List<LootItem>? _drops;
  bool _saving = false;
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
    try {
      final res = await http.get(Uri.parse('https://overfast-api.tekrop.fr/heroes?locale=fr-fr'));
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
        if (mounted) setState(() => _heroes = data.map((j) => HeroSummary.fromJson(j)).toList());
      }
    } catch (_) {
      // Hors ligne : le bouton reste desactive.
    }
  }

  Future<void> _openBox() async {
    if (_heroes.isEmpty || _anim.isAnimating || _saving) return;

    setState(() {
      _drops = null;
      _saving = true;
    });

    await _anim.forward(from: 0.0);
    if (!mounted) return;

    final rolled = LootboxRoll.roll4Items(_heroes);
    final result = await InventoryStore.addAll(
      rolled.map((e) => e.toInventoryItem()).toList(),
    );
    if (!mounted) return;

    // `remove` ne renvoie true qu'une fois par identifiant : les doublons
    // presents dans le tirage lui-meme sont donc aussi marques comme tels.
    final newIds = result.added.map((e) => e.uniqueId).toSet();

    setState(() {
      _drops = rolled
          .map((e) => e.copyWith(isNew: newIds.remove('${e.hero.key}::${e.skinName}')))
          .toList();
      _saving = false;
    });

    widget.onInventoryChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final drops = _drops;
    final busy = _heroes.isEmpty || _anim.isAnimating || _saving;

    return ColoredBox(
      color: const Color(0xFF07090E),
      child: Stack(
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

          // Contenu principal : coffre 3D ou les 4 drops
          Center(child: drops == null ? _build3DBox() : _build4DropsRow(drops)),

          if (drops != null)
            Positioned(
              top: 14,
              child: Text(
                '${drops.where((d) => d.isNew).length} NOUVEAU(X) SUR 4',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
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
                  disabledBackgroundColor: const Color(0xFF2B3345),
                  shape: const BeveledRectangleBorder(),
                ),
                onPressed: busy ? null : _openBox,
                child: Transform(
                  transform: Matrix4.skewX(-0.16),
                  child: Text(
                    _heroes.isEmpty
                        ? 'CHARGEMENT...'
                        : (drops == null ? 'OUVRIR LE COFFRE (1)' : 'OUVRIR UN AUTRE COFFRE'),
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
              gradient: const LinearGradient(
                colors: [Color(0xFF2B3345), Color(0xFF141824)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xFFF99E1A), width: 3),
              boxShadow: [
                BoxShadow(color: const Color(0xFFF99E1A).withAlpha(120), blurRadius: 35, spreadRadius: 4),
              ],
            ),
            child: const Center(child: Icon(Icons.token, size: 75, color: Color(0xFFF99E1A))),
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
          // Rotation et inclinaison pour faire l'effet d'eventail 3D
          final angle = (idx - 1.5) * 0.08;

          return Transform(
            alignment: Alignment.bottomCenter,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateZ(angle),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              width: 140,
              height: 260,
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
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          buildImageUrl(item.hero.portrait, width: 220),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: Color(0xFF1B2233),
                            child: Center(child: Icon(Icons.person, color: Colors.white24, size: 36)),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            color: item.isNew ? const Color(0xFF00C853) : Colors.black87,
                            child: Text(
                              item.isNew ? 'NOUVEAU' : 'DOUBLON',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    color: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Column(
                      children: [
                        Text(
                          item.hero.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.skinName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10, color: item.rarity.color),
                        ),
                      ],
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
