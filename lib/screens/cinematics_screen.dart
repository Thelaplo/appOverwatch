import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CinematicsScreen extends StatelessWidget {
  const CinematicsScreen({super.key});

  final List<Map<String, String>> cinematics = const [
    {
      'title': 'L’Épée du vent (Kiriko)',
      'hero': 'Kiriko',
      'duration': '8:48',
      'officialUrl': 'https://overwatch.blizzard.com/fr-fr/heroes/kiriko/',
      'thumbnail': 'https://images.weserv.nl/?url=overfast-api.tekrop.fr/static/heroes/kiriko/portrait.png&w=600&q=80',
      'desc': 'Kiriko protège Kanezaka et les siens face au clan Hashimoto. Disponible sur la page officielle Blizzard.',
    },
    {
      'title': 'Le Rappel (Recall)',
      'hero': 'Winston',
      'duration': '7:26',
      'officialUrl': 'https://overwatch.blizzard.com/fr-fr/heroes/winston/',
      'thumbnail': 'https://images.weserv.nl/?url=overfast-api.tekrop.fr/static/heroes/winston/portrait.png&w=600&q=80',
      'desc': 'Winston lutte contre les agents de la Griffe pour réactiver le réseau des agents Overwatch.',
    },
    {
      'title': 'En Vie (Alive)',
      'hero': 'Fatale & Tracer',
      'duration': '6:30',
      'officialUrl': 'https://overwatch.blizzard.com/fr-fr/heroes/widowmaker/',
      'thumbnail': 'https://images.weserv.nl/?url=overfast-api.tekrop.fr/static/heroes/widowmaker/portrait.png&w=600&q=80',
      'desc': 'Un assassinat sous haute tension dans les rues de King’s Row à Londres.',
    },
    {
      'title': 'Deux Dragons',
      'hero': 'Hanzo & Genji',
      'duration': '8:03',
      'officialUrl': 'https://overwatch.blizzard.com/fr-fr/heroes/genji/',
      'thumbnail': 'https://images.weserv.nl/?url=overfast-api.tekrop.fr/static/heroes/genji/portrait.png&w=600&q=80',
      'desc': 'Le duel fratricide légendaire entre les deux frères Shimada au temple d’Hanamura.',
    },
    {
      'title': 'Honneur et Gloire',
      'hero': 'Reinhardt',
      'duration': '7:33',
      'officialUrl': 'https://overwatch.blizzard.com/fr-fr/heroes/reinhardt/',
      'thumbnail': 'https://images.weserv.nl/?url=overfast-api.tekrop.fr/static/heroes/reinhardt/portrait.png&w=600&q=80',
      'desc': 'Le sacrifice et l’héritage de Balderich von Adler pendant la crise des Omniums.',
    },
    {
      'title': 'L’Étoile Filante (Shooting Star)',
      'hero': 'D.Va',
      'duration': '7:43',
      'officialUrl': 'https://overwatch.blizzard.com/fr-fr/heroes/dva/',
      'thumbnail': 'https://images.weserv.nl/?url=overfast-api.tekrop.fr/static/heroes/dva/portrait.png&w=600&q=80',
      'desc': 'D.Va défend la ville de Busan seule contre une invasion d’omniums colossaux.',
    },
  ];

  Future<void> _openOfficialPage(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible d\'ouvrir la page : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CINÉMATIQUES & LORE BLIZZARD'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cinematics.length,
        itemBuilder: (context, index) {
          final item = cinematics[index];

          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _openOfficialPage(context, item['officialUrl']!),
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: const Color(0xFF1F232D),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.network(
                        item['thumbnail']!,
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 190,
                          color: const Color(0xFF282E3E),
                          child: const Icon(Icons.movie, size: 50, color: Colors.white24),
                        ),
                      ),
                      Container(height: 190, color: Colors.black45),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF99E1A),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF99E1A).withAlpha(120),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.open_in_new, color: Colors.black, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'VOIR SUR BLIZZARD',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF99E1A),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item['hero']!.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title']!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item['desc']!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white60,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}