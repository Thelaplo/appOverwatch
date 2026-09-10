class PlayerProfile {
  final String username;
  final String? avatar;
  final String? title;
  final int endorsement;
  final String? tankRank;
  final String? damageRank;
  final String? supportRank;

  PlayerProfile({
    required this.username,
    this.avatar,
    this.title,
    required this.endorsement,
    this.tankRank,
    this.damageRank,
    this.supportRank,
  });

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>? ?? {};
    final comp = summary['competitive'] as Map<String, dynamic>? ?? {};
    final pc = comp['pc'] as Map<String, dynamic>? ?? {};

    String? parseDivision(dynamic roleData) {
      if (roleData is Map<String, dynamic>) {
        final div = roleData['division']?.toString().toUpperCase() ?? '';
        final tier = roleData['tier']?.toString() ?? '';
        return '$div $tier'.trim();
      }
      return null;
    }

    return PlayerProfile(
      username: summary['username'] ?? 'Inconnu',
      avatar: summary['avatar'],
      title: summary['title'],
      endorsement: summary['endorsement']?['level'] ?? 1,
      tankRank: parseDivision(pc['tank']),
      damageRank: parseDivision(pc['damage']),
      supportRank: parseDivision(pc['support']),
    );
  }
}