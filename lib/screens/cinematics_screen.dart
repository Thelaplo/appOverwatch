import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Un court-metrage officiel Overwatch.
class Cinematic {
  final String title;
  final String subtitle;
  final String description;

  /// Identifiant de la video sur la chaine officielle PlayOverwatch.
  final String youtubeId;

  const Cinematic({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.youtubeId,
  });

  String get thumbnail => 'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg';
}

/// Les cinematiques se regardent directement dans l'application, via le
/// lecteur YouTube officiel embarque.
///
/// Chaque identifiant ci-dessous a ete verifie avec l'endpoint oembed de
/// YouTube et provient de la chaine PlayOverwatch. Blizzard ne publie pas de
/// flux video exploitable de son cote : passer par le lecteur officiel est la
/// seule voie propre, et c'est l'usage prevu.
const List<Cinematic> kCinematics = [
  Cinematic(
    title: 'DRAGONS',
    subtitle: 'Hanzo & Genji',
    description:
        'Hanzo revient au sanctuaire familial de Hanamura et y affronte le fantôme '
        'du frère qu\'il croit avoir tué.',
    youtubeId: 'oJ09xdxzIJQ',
  ),
  Cinematic(
    title: 'HERO',
    subtitle: 'Soldat : 76',
    description:
        'À Dorado, un justicier masqué s\'en prend au gang des Muertos et protège '
        'une enfant prise dans la fusillade.',
    youtubeId: 'cPRRupAM4DI',
  ),
  Cinematic(
    title: 'HONOR AND GLORY',
    subtitle: 'Reinhardt',
    description:
        'Reinhardt se remémore la bataille d\'Eichenwalde et le sacrifice de '
        'Balderich von Adler.',
    youtubeId: 'sQfk5HykiEk',
  ),
  Cinematic(
    title: 'RISE AND SHINE',
    subtitle: 'Mei',
    description:
        'Réveillée d\'une cryostase de neuf ans à la station Écopoint : Antarctique, '
        'Mei découvre qu\'elle est la seule survivante.',
    youtubeId: '8tjcm_kI0n0',
  ),
  Cinematic(
    title: 'KIRIKO',
    subtitle: 'Overwatch 2',
    description:
        'Kiriko protège Kanezaka et les siens face au clan Hashimoto, entre '
        'tradition familiale et esprit renard.',
    youtubeId: '9acxn7qAST4',
  ),
  Cinematic(
    title: 'THE WASTELANDER',
    subtitle: 'Junkrat & Chopper',
    description:
        'Dans les terres désolées australiennes, une rencontre tourne mal pour '
        'ceux qui croisent la route du duo.',
    youtubeId: '8-nXN9ZMl8o',
  ),
];

class CinematicsScreen extends StatelessWidget {
  const CinematicsScreen({super.key});

  static const _accent = Color(0xFFF99E1A);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF090D15),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Le lore d\'Overwatch en vidéo, lu directement dans l\'application.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          ...kCinematics.map((c) => _card(context, c)),
        ],
      ),
    );
  }

  Widget _card(BuildContext context, Cinematic c) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => _CinematicPlayer(cinematic: c)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF141926),
          border: Border.all(color: _accent.withAlpha(120)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    c.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFF1B2233),
                      child: Center(child: Icon(Icons.movie, color: _accent, size: 40)),
                    ),
                  ),
                ),
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    shape: BoxShape.circle,
                    border: Border.all(color: _accent, width: 2),
                  ),
                  child: const Icon(Icons.play_arrow, color: _accent, size: 34),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Transform(
                          transform: Matrix4.skewX(-0.16),
                          child: Text(
                            c.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 17,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        color: _accent,
                        child: Text(
                          c.subtitle.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    c.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
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

/// Lecteur plein ecran d'une cinematique.
class _CinematicPlayer extends StatefulWidget {
  final Cinematic cinematic;

  const _CinematicPlayer({required this.cinematic});

  @override
  State<_CinematicPlayer> createState() => _CinematicPlayerState();
}

class _CinematicPlayerState extends State<_CinematicPlayer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.cinematic.youtubeId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        strictRelatedVideos: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04060A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF04060A),
        elevation: 0,
        title: Transform(
          transform: Matrix4.skewX(-0.16),
          child: Text(
            widget.cinematic.title,
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16),
          ),
        ),
      ),
      body: ListView(
        children: [
          YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cinematic.subtitle.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFF99E1A),
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.cinematic.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
