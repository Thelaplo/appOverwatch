import 'package:flutter/material.dart';

import '../models/player_profile.dart';
import '../utils/player_api.dart';
import '../widgets/player_rank_card.dart';

/// Recherche d'un joueur et affichage de ses rangs competitifs.
class CareerTrackerScreen extends StatefulWidget {
  const CareerTrackerScreen({super.key});

  @override
  State<CareerTrackerScreen> createState() => _CareerTrackerScreenState();
}

class _CareerTrackerScreenState extends State<CareerTrackerScreen> {
  static const _accent = Color(0xFFF99E1A);

  final TextEditingController _controller = TextEditingController();

  List<PlayerSearchResult>? _results;
  PlayerProfile? _profile;
  bool _loading = false;
  bool _profileUnavailable = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _loading = true;
      _profile = null;
      _profileUnavailable = false;
    });

    final results = await PlayerApi.search(name);
    if (!mounted) return;
    setState(() {
      _results = results;
      _loading = false;
    });
  }

  Future<void> _openProfile(PlayerSearchResult player) async {
    setState(() {
      _loading = true;
      _profile = null;
      _profileUnavailable = false;
    });

    final profile = await PlayerApi.summary(player.playerId);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _profileUnavailable = profile == null;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF090D15),
      child: SafeArea(
        child: Column(
          children: [
            _searchBar(),
            Expanded(child: _body()),
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cherche un joueur par son pseudo BattleTag (sans le #).',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: (_) => _search(),
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Pseudo du joueur',
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
                    filled: true,
                    fillColor: const Color(0xFF141926),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.black,
                    shape: const BeveledRectangleBorder(),
                  ),
                  onPressed: _loading ? null : _search,
                  child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }

    if (_profileUnavailable) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Profil inaccessible.\nIl est probablement configuré en privé '
            'dans les options du jeu.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
          ),
        ),
      );
    }

    final profile = _profile;
    if (profile != null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [PlayerRankCard(profile: profile)],
      );
    }

    final results = _results;
    if (results == null) {
      return _placeholder(
        Icons.person_search,
        'Entre un pseudo pour consulter les rangs d\'un joueur.',
      );
    }
    if (results.isEmpty) {
      return _placeholder(Icons.search_off, 'Aucun joueur trouvé pour ce pseudo.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: results.length,
      itemBuilder: (context, i) => _resultTile(results[i]),
    );
  }

  Widget _resultTile(PlayerSearchResult player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      color: const Color(0xFF141926),
      child: ListTile(
        leading: player.avatar == null
            ? const Icon(Icons.person, color: Colors.white24)
            : Image.network(
                player.avatar!,
                width: 40,
                height: 40,
                errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white24),
              ),
        title: Text(
          player.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
        ),
        subtitle: player.title == null || player.title!.isEmpty
            ? null
            : Text(player.title!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, color: _accent),
        onTap: () => _openProfile(player),
      ),
    );
  }

  Widget _placeholder(IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Colors.white.withAlpha(25)),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
