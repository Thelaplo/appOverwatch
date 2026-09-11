import 'package:flutter/material.dart';

/// Pages qui s'ouvrent par-dessus le hub plutot que comme onglet.
enum DrawerPage { voiceLines, meta, quiz, randomPick, cinematics }

/// Menu principal de l'application.
///
/// L'ancienne version reprenait l'habillage du site Blizzard (fond blanc,
/// bouclier, rubriques « Saison » ou « Actualites ») dont la moitie ne menait
/// nulle part. Il suit maintenant l'identite sombre d'Athena et n'expose que
/// des entrees fonctionnelles.
class BlizzardDrawer extends StatelessWidget {
  /// Bascule vers un onglet de la barre du bas.
  final Function(int) onNavigate;

  /// Ouvre une page hors onglets.
  final Function(DrawerPage) onOpenPage;

  const BlizzardDrawer({
    super.key,
    required this.onNavigate,
    required this.onOpenPage,
  });

  static const _accent = Color(0xFFF99E1A);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0C101A),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _header(context),
            _sectionLabel('CONSULTER'),
            _tile(context, Icons.people, 'Héros', () => onNavigate(0)),
            _tile(context, Icons.map, 'Cartes', () => onNavigate(1)),
            _tile(context, Icons.shield, 'Compositions', () => onNavigate(2)),
            _tile(context, Icons.style, 'Galerie des skins', () => onNavigate(4)),
            _tile(context, Icons.shopping_bag, 'Boutique & collabs', () => onNavigate(5), badge: 'HOT'),
            _tile(
              context,
              Icons.movie,
              'Cinématiques',
              () => onOpenPage(DrawerPage.cinematics),
              badge: 'NOUVEAU',
            ),
            _divider(),
            _sectionLabel('GAMEPLAY'),
            _tile(
              context,
              Icons.trending_up,
              'Méta & tier list',
              () => onOpenPage(DrawerPage.meta),
              badge: 'NOUVEAU',
            ),
            _tile(context, Icons.inventory_2, 'Coffres & inventaire', () => onNavigate(3)),
            _divider(),
            _sectionLabel('POUR LE PLAISIR'),
            _tile(
              context,
              Icons.graphic_eq,
              'Répliques audio',
              () => onOpenPage(DrawerPage.voiceLines),
            ),
            _tile(
              context,
              Icons.quiz,
              'Quiz : devine le héros',
              () => onOpenPage(DrawerPage.quiz),
              badge: 'NOUVEAU',
            ),
            _tile(
              context,
              Icons.casino,
              'Je joue quoi ?',
              () => onOpenPage(DrawerPage.randomPick),
              badge: 'NOUVEAU',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2438), Color(0xFF0C101A)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white38),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Row(
            children: [
              Image.asset('assets/icon/athena_mark.png', height: 52),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform(
                    transform: Matrix4.skewX(-0.16),
                    child: const Text(
                      'ATHENA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'COMPAGNON OVERWATCH 2',
                    style: TextStyle(color: _accent, fontSize: 9, letterSpacing: 1.6, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.6,
          ),
        ),
      );

  Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Divider(color: Colors.white12, height: 1),
      );

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? badge,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: _accent, size: 20),
      title: Row(
        children: [
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              color: badge == 'HOT' ? const Color(0xFFD500F9) : const Color(0xFF00A2FF),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}
