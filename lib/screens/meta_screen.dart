import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/hero.dart';
import '../utils/image_helper.dart';

/// Statistiques d'un heros telles que publiees par l'API.
class HeroStat {
  final String key;
  final double pickrate;
  final double winrate;
  final double banrate;

  const HeroStat({
    required this.key,
    required this.pickrate,
    required this.winrate,
    required this.banrate,
  });

  factory HeroStat.fromJson(Map<String, dynamic> json) => HeroStat(
        key: json['hero'] as String? ?? '',
        pickrate: (json['pickrate'] as num?)?.toDouble() ?? 0,
        winrate: (json['winrate'] as num?)?.toDouble() ?? 0,
        banrate: (json['banrate'] as num?)?.toDouble() ?? 0,
      );
}

enum _SortBy {
  winrate('VICTOIRES'),
  pickrate('SÉLECTION'),
  banrate('BANNIS');

  final String label;
  const _SortBy(this.label);
}

/// Meta du moment : taux de victoire, de selection et de bannissement.
///
/// Ces chiffres viennent de /heroes/stats et ne concernent que les modes en
/// file par role. C'est la donnee la plus directement utile pour decider quoi
/// jouer, et l'application ne l'exploitait pas.
class MetaScreen extends StatefulWidget {
  const MetaScreen({super.key});

  @override
  State<MetaScreen> createState() => _MetaScreenState();
}

class _MetaScreenState extends State<MetaScreen> {
  static const _accent = Color(0xFFF99E1A);

  List<HeroStat>? _stats;
  Map<String, HeroSummary> _heroes = {};
  bool _failed = false;

  String _platform = 'pc';
  String _gamemode = 'competitive';
  String _role = 'TOUS';
  _SortBy _sortBy = _SortBy.winrate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _stats = null;
      _failed = false;
    });

    try {
      final results = await Future.wait([
        http.get(Uri.parse(
          'https://overfast-api.tekrop.fr/heroes/stats'
          '?platform=$_platform&gamemode=$_gamemode&region=europe&locale=fr-fr',
        )),
        http.get(Uri.parse('https://overfast-api.tekrop.fr/heroes?locale=fr-fr')),
      ]);

      if (results[0].statusCode != 200 || results[1].statusCode != 200) {
        throw Exception('API indisponible');
      }

      final rawStats = jsonDecode(utf8.decode(results[0].bodyBytes)) as List<dynamic>;
      final rawHeroes = jsonDecode(utf8.decode(results[1].bodyBytes)) as List<dynamic>;

      if (!mounted) return;
      setState(() {
        _stats = rawStats.map((e) => HeroStat.fromJson(e as Map<String, dynamic>)).toList();
        _heroes = {
          for (final j in rawHeroes)
            (j as Map<String, dynamic>)['key'] as String: HeroSummary.fromJson(j),
        };
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  List<HeroStat> get _visible {
    final stats = _stats ?? const <HeroStat>[];

    final filtered = _role == 'TOUS'
        ? stats
        : stats.where((s) {
            final hero = _heroes[s.key];
            return hero != null && hero.role == _roleKey(_role);
          }).toList();

    final sorted = [...filtered];
    sorted.sort((a, b) => switch (_sortBy) {
          _SortBy.winrate => b.winrate.compareTo(a.winrate),
          _SortBy.pickrate => b.pickrate.compareTo(a.pickrate),
          _SortBy.banrate => b.banrate.compareTo(a.banrate),
        });
    return sorted;
  }

  String _roleKey(String label) => switch (label) {
        'TANK' => 'tank',
        'DÉGÂTS' => 'damage',
        'SOUTIEN' => 'support',
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF090D15),
      child: Column(
        children: [
          _filters(),
          Expanded(child: _body()),
        ],
      ),
    );
  }

  Widget _body() {
    if (_failed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Impossible de charger les statistiques.\nVérifie ta connexion.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _load,
                child: const Text('RÉESSAYER', style: TextStyle(color: _accent, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      );
    }

    if (_stats == null) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }

    final rows = _visible;
    if (rows.isEmpty) {
      return const Center(
        child: Text('Aucun héros pour ce filtre.', style: TextStyle(color: Colors.white54, fontSize: 13)),
      );
    }

    return RefreshIndicator(
      color: _accent,
      backgroundColor: const Color(0xFF141926),
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: rows.length,
        itemBuilder: (context, i) => _row(rows[i], i + 1),
      ),
    );
  }

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Taux issus des files par rôle, région Europe.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip('PC', _platform == 'pc', () => setState(() {
                      _platform = 'pc';
                      _load();
                    })),
                _chip('CONSOLE', _platform == 'console', () => setState(() {
                      _platform = 'console';
                      _load();
                    })),
                const SizedBox(width: 14),
                _chip('COMPÉTITIF', _gamemode == 'competitive', () => setState(() {
                      _gamemode = 'competitive';
                      _load();
                    })),
                _chip('RAPIDE', _gamemode == 'quickplay', () => setState(() {
                      _gamemode = 'quickplay';
                      _load();
                    })),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final r in ['TOUS', 'TANK', 'DÉGÂTS', 'SOUTIEN'])
                  _chip(r, _role == r, () => setState(() => _role = r)),
                const SizedBox(width: 14),
                for (final s in _SortBy.values)
                  _chip('↓ ${s.label}', _sortBy == s, () => setState(() => _sortBy = s)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: active ? _accent : const Color(0xFF141926),
            border: Border.all(color: active ? _accent : Colors.white24),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(HeroStat stat, int rank) {
    final hero = _heroes[stat.key];
    final winColor = _winrateColor(stat.winrate);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF141926),
        border: Border(left: BorderSide(color: winColor, width: 3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(
            width: 46,
            height: 46,
            child: hero == null
                ? const ColoredBox(color: Color(0xFF1B2233))
                : Image.network(
                    buildImageUrl(hero.portrait, width: 100),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFF1B2233),
                      child: Icon(Icons.person, color: Colors.white24, size: 18),
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              (hero?.name ?? stat.key).toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
            ),
          ),
          _stat('VICT.', '${stat.winrate}%', winColor),
          _stat('SÉL.', '${stat.pickrate}%', Colors.white70),
          _stat('BAN', '${stat.banrate}%', stat.banrate >= 10 ? const Color(0xFFFF5252) : Colors.white38),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white24, fontSize: 8, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  /// 50 % est l'equilibre : on s'en ecarte vers le vert ou le rouge.
  Color _winrateColor(double winrate) {
    if (winrate >= 53) return const Color(0xFF00E676);
    if (winrate >= 50.5) return const Color(0xFF9CCC65);
    if (winrate >= 48.5) return const Color(0xFFB0BEC5);
    if (winrate >= 46) return const Color(0xFFFFA726);
    return const Color(0xFFFF5252);
  }
}
