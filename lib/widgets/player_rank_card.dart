import 'package:flutter/material.dart';

import '../models/player_profile.dart';

/// Carte de profil d'un joueur : identite, niveau de recommandation et rangs.
class PlayerRankCard extends StatelessWidget {
  final PlayerProfile profile;

  const PlayerRankCard({super.key, required this.profile});

  static const _accent = Color(0xFFF99E1A);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _identity(),
        const SizedBox(height: 18),
        if (profile.isUnranked)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Aucun rang classé publié pour cette saison, ni sur PC ni sur console.\n'
              'Le joueur n\'a peut-être pas fait ses parties de placement, '
              'ou son profil est privé.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.5),
            ),
          )
        else ...[
          if (profile.season != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                'SAISON ${profile.season}',
                style: const TextStyle(
                  color: _accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ..._platformBlock('PC', Icons.computer, profile.pcRanks),
          ..._platformBlock('CONSOLE', Icons.sports_esports, profile.consoleRanks),
        ],
      ],
    );
  }

  Widget _identity() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141926),
        border: Border.all(color: _accent.withAlpha(110)),
      ),
      child: Row(
        children: [
          if (profile.avatar != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                profile.avatar!,
                width: 62,
                height: 62,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.white24, size: 40),
              ),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (profile.title != null && profile.title!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    profile.title!,
                    style: const TextStyle(color: _accent, fontSize: 11),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  'Recommandation niveau ${profile.endorsement}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bloc de rangs d'une plateforme, masque si le joueur n'y a pas de rang.
  List<Widget> _platformBlock(String label, IconData icon, List<RankInfo> ranks) {
    if (ranks.isEmpty) return const [];

    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white38, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
      ...ranks.map(_rankRow),
      const SizedBox(height: 10),
    ];
  }

  Widget _rankRow(RankInfo rank) {
    final color = Color(rank.colorValue);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141926),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: [
          // Icones officielles Blizzard : rang (metal) et division (chiffre).
          Image.network(
            rank.rankIcon,
            width: 46,
            height: 46,
            errorBuilder: (_, __, ___) => Icon(Icons.shield, color: color, size: 32),
          ),
          Image.network(
            rank.tierIcon,
            width: 34,
            height: 34,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _roleLabel(rank.role),
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rank.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) => switch (role) {
        'tank' => 'TANK',
        'damage' => 'DÉGÂTS',
        'support' => 'SOUTIEN',
        'open' => 'FILE LIBRE',
        _ => role.toUpperCase(),
      };
}
