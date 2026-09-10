import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CareerTrackerScreen extends StatefulWidget {
  const CareerTrackerScreen({super.key});

  @override
  State<CareerTrackerScreen> createState() => _CareerTrackerScreenState();
}

class _CareerTrackerScreenState extends State<CareerTrackerScreen> {
  // Ton URL officielle enregistrée par défaut
  final TextEditingController _urlCtrl = TextEditingController(
    text: 'https://overwatch.blizzard.com/fr-fr/career/c656a986b26197a2a4a221a0d7|28365ca0931d6c9cd59291a45e13bb98/',
  );

  Future<void> _openOfficialCareer(String url) async {
    final cleanUrl = url.trim();
    if (cleanUrl.isEmpty) return;

    final uri = Uri.parse(cleanUrl.startsWith('http') ? cleanUrl : 'https://$cleanUrl');
    await launchUrl(uri, mode: LaunchMode.externalApplication, webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0F16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF080A0F),
        elevation: 0,
        title: Transform(
          transform: Matrix4.skewX(-0.16),
          child: const Text(
            'CARRIÈRE OFFICIELLE BLIZZARD',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 18),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Carte principale style Battle.net
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141822),
                border: Border.all(color: const Color(0xFFF99E1A), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF99E1A).withAlpha(50),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: const Color(0xFF0C0F16),
                        child: const Icon(Icons.shield, color: Color(0xFFF99E1A), size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Transform(
                              transform: Matrix4.skewX(-0.16),
                              child: const Text(
                                'PROFIL DE JOUEUR VÉRIFIÉ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Compte synchronisé PC & Xbox',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'LIEN DE TA CARRIÈRE OVERWATCH 2 :',
                    style: TextStyle(color: Color(0xFFF99E1A), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    color: const Color(0xFF0C0F16),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TextField(
                      controller: _urlCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Colle ton lien de profil officiel Blizzard...',
                        hintStyle: TextStyle(color: Colors.white24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF99E1A),
                        foregroundColor: Colors.black,
                        shape: const BeveledRectangleBorder(),
                      ),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text(
                        'OUVRIR MA CARRIÈRE OFFICIELLE',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0),
                      ),
                      onPressed: () => _openOfficialCareer(_urlCtrl.text),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Note explicative Blizzard biseautée
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFF141822),
                border: Border(left: BorderSide(color: Colors.white24, width: 4)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SYNCHRONISATION MULTI-PLATEFORME',
                    style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900, fontSize: 11),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Les profils liés à la fois sur PC et Xbox utilisent un identifiant chiffré unique Blizzard. En passant par la passerelle officielle, toutes tes stats (temps de jeu, héros fétiches, ratios) s\'affichent sans restriction d\'API.',
                    style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
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