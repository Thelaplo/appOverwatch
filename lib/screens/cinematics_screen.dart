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
/// Chaque identifiant a ete verifie un a un avec l'endpoint oembed de YouTube
/// et provient d'une chaine officielle Blizzard : « Overwatch FR » pour les
/// versions francaises, « PlayOverwatch » pour les deux courts non doubles.
/// Blizzard ne publie pas de flux video exploitable de son cote : passer par
/// le lecteur officiel est la voie propre, et c'est l'usage prevu.
///
/// Classees dans l'ordre de sortie.
const List<Cinematic> kCinematics = [
  Cinematic(
    title: 'LE RAPPEL',
    subtitle: 'Winston',
    description:
        'Attaqué par Reaper dans son laboratoire abandonné, Winston décide de '
        'réactiver le signal de rappel et de reformer Overwatch.',
    youtubeId: 'oyE56xeprQA',
  ),
  Cinematic(
    title: 'EN VIE',
    subtitle: 'Tracer & Widowmaker',
    description:
        'Widowmaker exécute un contrat sur Tekhartha Mondatta à King\'s Row. '
        'Tracer tente de l\'en empêcher, en vain.',
    youtubeId: '2gRgcasVRyw',
  ),
  Cinematic(
    title: 'DEUX DRAGONS',
    subtitle: 'Hanzo & Genji',
    description:
        'Hanzo revient au sanctuaire familial de Hanamura et y affronte le fantôme '
        'du frère qu\'il croit avoir tué.',
    youtubeId: 'BcXvkvxA4pw',
  ),
  Cinematic(
    title: 'HÉROS',
    subtitle: 'Soldat : 76',
    description:
        'À Dorado, un justicier masqué s\'en prend au gang des Muertos et protège '
        'une enfant prise dans la fusillade.',
    youtubeId: 'Lhdeme9Kd2s',
  ),
  Cinematic(
    title: 'LE DERNIER BASTION',
    subtitle: 'Bastion',
    description:
        'Réveillé après des décennies dans la forêt, un robot de guerre découvre '
        'la nature — jusqu\'à ce que ses souvenirs de combat resurgissent.',
    youtubeId: 'Uh--cnw1CxE',
  ),
  Cinematic(
    title: 'INFILTRATION',
    subtitle: 'Sombra, Reaper & Widowmaker',
    description:
        'Talon monte une opération contre Katya Volskaya. Sombra en profite pour '
        'mener son propre jeu.',
    youtubeId: '-IhWb0G18lk',
  ),
  Cinematic(
    title: 'HONNEUR ET GLOIRE',
    subtitle: 'Reinhardt',
    description:
        'Reinhardt se remémore la bataille d\'Eichenwalde et le sacrifice de '
        'Balderich von Adler.',
    youtubeId: 'LlAzoaudL9w',
  ),
  Cinematic(
    title: 'LE RÉVEIL',
    subtitle: 'Mei',
    description:
        'Réveillée d\'une cryostase de neuf ans à l\'Écopoint : Antarctique, Mei '
        'découvre qu\'elle est la seule survivante de l\'équipe.',
    youtubeId: 'xFSYN6jkirk',
  ),
  Cinematic(
    title: 'RETROUVAILLES',
    subtitle: 'Cassidy & Ashe',
    description:
        'Une attaque de train dans le désert donne à Cassidy l\'occasion de régler '
        'ses comptes avec ses anciens associés du gang Deadlock.',
    youtubeId: 'GJfIcDYnMTU',
  ),
  Cinematic(
    title: 'RÉPONDEZ À L\'APPEL',
    subtitle: 'Overwatch',
    description:
        'L\'appel du rappel résonne : les anciens agents reprennent du service.',
    youtubeId: 'ONj-m21GeqU',
  ),
  Cinematic(
    title: 'L\'HEURE ZÉRO',
    subtitle: 'Overwatch 2',
    description:
        'Paris tombe sous l\'assaut des omniaques. Winston réunit une poignée '
        'd\'agents pour répondre présent.',
    youtubeId: 'pyS3vmnWTyU',
  ),
  // Les deux suivantes n'ont pas de doublage francais publie : on garde la
  // version originale de la chaine PlayOverwatch.
  Cinematic(
    title: 'KIRIKO',
    subtitle: 'Overwatch 2 · VO',
    description:
        'Kiriko protège Kanezaka et les siens face au clan Hashimoto, entre '
        'tradition familiale et esprit renard.',
    youtubeId: '9acxn7qAST4',
  ),
  Cinematic(
    title: 'THE WASTELANDER',
    subtitle: 'Chopper · VO',
    description:
        'Dans les terres désolées australiennes, une rencontre tourne mal pour '
        'ceux qui croisent la route du Fatras.',
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
