class Ability {
  final String name;
  final String description;
  final String iconUrl;
  final String? videoUrl;

  Ability({
    required this.name,
    required this.description,
    required this.iconUrl,
    this.videoUrl,
  });

  factory Ability.fromJson(Map<String, dynamic> json) {
    final videoObj = json['video'] as Map<String, dynamic>?;
    final linkObj = videoObj?['link'] as Map<String, dynamic>?;
    final video = linkObj?['mp4'] ?? videoObj?['link'];

    return Ability(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['icon'] ?? '',
      videoUrl: video is String ? video : null,
    );
  }
}