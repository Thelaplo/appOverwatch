/// Rang competitif d'un joueur sur un role donne.
class RankInfo {
  final String role;
  final String division;
  final int tier;
  final String rankIcon;
  final String tierIcon;

  const RankInfo({
    required this.role,
    required this.division,
    required this.tier,
    required this.rankIcon,
    required this.tierIcon,
  });

  /// Divisions telles que declarees par l'API : bronze, silver, gold,
  /// platinum, emerald, diamond, master, grandmaster, ultimate.
  static const Map<String, String> _divisionLabels = {
    'bronze': 'BRONZE',
    'silver': 'ARGENT',
    'gold': 'OR',
    'platinum': 'PLATINE',
    'emerald': 'ÉMERAUDE',
    'diamond': 'DIAMANT',
    'master': 'MAÎTRE',
    'grandmaster': 'GRAND MAÎTRE',
    'ultimate': 'ULTIME',
  };

  String get label => '${_divisionLabels[division] ?? division.toUpperCase()} $tier';

  /// Couleur associee a la division, pour l'habillage.
  int get colorValue => switch (division) {
        'bronze' => 0xFFB0764A,
        'silver' => 0xFFB0BEC5,
        'gold' => 0xFFFFC107,
        'platinum' => 0xFF4DD0E1,
        'emerald' => 0xFF2ECC71,
        'diamond' => 0xFF64B5F6,
        'master' => 0xFFFFB300,
        'grandmaster' => 0xFFFF7043,
        'ultimate' => 0xFFD500F9,
        _ => 0xFF9E9E9E,
      };

  static RankInfo? fromJson(String role, Map<String, dynamic>? json) {
    if (json == null) return null;
    return RankInfo(
      role: role,
      division: json['division'] as String? ?? '',
      tier: (json['tier'] as num?)?.toInt() ?? 0,
      rankIcon: json['rank_icon'] as String? ?? '',
      tierIcon: json['tier_icon'] as String? ?? '',
    );
  }
}

/// Profil public d'un joueur, tel qu'expose par l'API OverFast.
class PlayerProfile {
  final String username;
  final String? avatar;
  final String? namecard;
  final String? title;
  final int endorsement;
  final int? season;

  /// Rangs par plateforme. Un joueur console n'a rien sur PC et
  /// reciproquement : les deux sont donc lus et affiches separement.
  final List<RankInfo> pcRanks;
  final List<RankInfo> consoleRanks;

  const PlayerProfile({
    required this.username,
    this.avatar,
    this.namecard,
    this.title,
    required this.endorsement,
    this.season,
    required this.pcRanks,
    required this.consoleRanks,
  });

  /// Aucun rang classe publie, sur aucune plateforme.
  bool get isUnranked => pcRanks.isEmpty && consoleRanks.isEmpty;

  static List<RankInfo> _ranksOf(Map<String, dynamic>? platform) {
    if (platform == null) return const [];

    final ranks = <RankInfo>[];
    for (final role in ['tank', 'damage', 'support', 'open']) {
      final rank = RankInfo.fromJson(role, platform[role] as Map<String, dynamic>?);
      if (rank != null) ranks.add(rank);
    }
    return ranks;
  }

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final competitive = json['competitive'] as Map<String, dynamic>?;
    final pc = competitive?['pc'] as Map<String, dynamic>?;
    final console = competitive?['console'] as Map<String, dynamic>?;

    // Un objet plateforme peut exister avec tous ses roles a null : lire
    // « pc ?? console » renvoyait alors une plateforme vide et masquait les
    // rangs console du joueur.
    final pcRanks = _ranksOf(pc);
    final consoleRanks = _ranksOf(console);

    return PlayerProfile(
      username: json['username'] as String? ?? 'Inconnu',
      avatar: json['avatar'] as String?,
      namecard: json['namecard'] as String?,
      title: json['title'] as String?,
      endorsement: (json['endorsement']?['level'] as num?)?.toInt() ?? 0,
      season: (pc?['season'] ?? console?['season']) as int?,
      pcRanks: pcRanks,
      consoleRanks: consoleRanks,
    );
  }
}

/// Un joueur remonte par la recherche.
class PlayerSearchResult {
  final String playerId;
  final String name;
  final String? avatar;
  final String? title;

  const PlayerSearchResult({
    required this.playerId,
    required this.name,
    this.avatar,
    this.title,
  });

  factory PlayerSearchResult.fromJson(Map<String, dynamic> json) => PlayerSearchResult(
        playerId: json['player_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        avatar: json['avatar'] as String?,
        title: json['title'] as String?,
      );
}
