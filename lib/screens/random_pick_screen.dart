import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/hero.dart';
import '../utils/image_helper.dart';

/// « Je joue quoi ? » : tire un heros au hasard, filtrable par role.
class RandomPickScreen extends StatefulWidget {
  const RandomPickScreen({super.key});

  @override
  State<RandomPickScreen> createState() => _RandomPickScreenState();
}

class _RandomPickScreenState extends State<RandomPickScreen>
    with SingleTickerProviderStateMixin {
  static const _accent = Color(0xFFF99E1A);

  final Random _random = Random();

  List<HeroSummary> _heroes = [];
  HeroSummary? _picked;
  String _role = 'TOUS';
  bool _rolling = false;
  late AnimationController _anim;

  /// Defilement de portraits pendant le tirage, pour l'effet de roulette.
  HeroSummary? _flashing;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _load();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final res = await http.get(
        Uri.parse('https://overfast-api.tekrop.fr/heroes?locale=fr-fr'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
        if (!mounted) return;
        setState(() => _heroes = data.map((j) => HeroSummary.fromJson(j)).toList());
      }
    } catch (_) {
      // Hors ligne : le bouton reste desactive.
    }
  }

  List<HeroSummary> get _candidates {
    if (_role == 'TOUS') return _heroes;
    final key = switch (_role) {
      'TANK' => 'tank',
      'DÉGÂTS' => 'damage',
      _ => 'support',
    };
    return _heroes.where((h) => h.role == key).toList();
  }

  Future<void> _roll() async {
    final pool = _candidates;
    if (pool.isEmpty || _rolling) return;

    setState(() {
      _rolling = true;
      _picked = null;
    });

    // Le defilement ralentit progressivement avant de s'arreter.
    var delay = 60;
    for (var i = 0; i < 22; i++) {
      if (!mounted) return;
      setState(() => _flashing = pool[_random.nextInt(pool.length)]);
      await Future.delayed(Duration(milliseconds: delay));
      delay += 12;
    }

    if (!mounted) return;
    setState(() {
      _picked = pool[_random.nextInt(pool.length)];
      _flashing = null;
      _rolling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final shown = _picked ?? _flashing;

    return ColoredBox(
      color: const Color(0xFF090D15),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: SizedBox(
                height: 30,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final r in ['TOUS', 'TANK', 'DÉGÂTS', 'SOUTIEN'])
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: _rolling ? null : () => setState(() => _role = r),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: _role == r ? _accent : const Color(0xFF141926),
                              border: Border.all(color: _role == r ? _accent : Colors.white24),
                            ),
                            child: Text(
                              r,
                              style: TextStyle(
                                color: _role == r ? Colors.black : Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(child: Center(child: _card(shown))),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFF2B3345),
                    shape: const BeveledRectangleBorder(),
                  ),
                  onPressed: _heroes.isEmpty || _rolling ? null : _roll,
                  child: Transform(
                    transform: Matrix4.skewX(-0.16),
                    child: Text(
                      _heroes.isEmpty
                          ? 'CHARGEMENT...'
                          : (_picked == null ? 'TIRER UN HÉROS' : 'RELANCER'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(HeroSummary? hero) {
    if (hero == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.casino, size: 72, color: Colors.white.withAlpha(20)),
            const SizedBox(height: 16),
            const Text(
              'Choisis un rôle puis lance le tirage.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      );
    }

    final settled = _picked != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF10141D),
          border: Border.all(color: _accent, width: settled ? 3 : 1.5),
          boxShadow: settled
              ? [BoxShadow(color: _accent.withAlpha(110), blurRadius: 30, spreadRadius: 3)]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                buildImageUrl(hero.portrait, width: 420),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFF1B2233),
                  child: Icon(Icons.person, color: Colors.white24, size: 48),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Text(
                    hero.name.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  if (settled) ...[
                    const SizedBox(height: 4),
                    Text(
                      _roleLabel(hero.role),
                      style: const TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _roleLabel(String role) => switch (role) {
        'tank' => 'TANK',
        'damage' => 'DÉGÂTS',
        'support' => 'SOUTIEN',
        _ => role.toUpperCase(),
      };
}
