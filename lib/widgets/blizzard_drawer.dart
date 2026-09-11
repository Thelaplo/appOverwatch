import 'package:flutter/material.dart';

class BlizzardDrawer extends StatelessWidget {
  final Function(int) onNavigate;
  const BlizzardDrawer({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                const Text('BLIZZARD', style: TextStyle(color: Color(0xFF0074E0), fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1.2)),
                const SizedBox(width: 40),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Image.network(
                'https://images.blz-contentstack.com/v3/assets/blt9c12f249ac15c7ec/blt6d55d28aa0743b17/633e0a29482813098319f359/overwatch-logo.png',
                height: 48,
                errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 40, color: Color(0xFFF99E1A)),
              ),
            ),
            const SizedBox(height: 16),
            // Barre de recherche joueurs
            Container(
              decoration: BoxDecoration(color: const Color(0xFFF2F4F7), borderRadius: BorderRadius.circular(4)),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, size: 18, color: Colors.black54),
                  hintText: 'Profils des joueurs',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.black38),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _menuTile('Informations sur le jeu', hasSub: true),
            _menuTile('Personnages', badge: 'NOUVEAU', isOpen: true, onTap: () {
              Navigator.pop(context);
              onNavigate(0);
            }),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Column(
                children: [
                  _subTile('Galerie des personnages', () {
                    Navigator.pop(context);
                    onNavigate(0);
                  }),
                  _subTile('Statistiques des personnages', () {
                    Navigator.pop(context);
                    onNavigate(3);
                  }, badge: 'NOUVEAU'),
                  _subTile('Boutique & Collabs', () {
                    Navigator.pop(context);
                    onNavigate(5);
                  }, badge: 'HOT'),
                ],
              ),
            ),
            _menuTile('Saison'),
            _menuTile('Actualités'),
            _menuTile('Communauté', hasSub: true),
          ],
        ),
      ),
    );
  }

  Widget _menuTile(String title, {String? badge, bool isOpen = false, bool hasSub = false, VoidCallback? onTap}) {
    return ListTile(
      dense: true,
      onTap: onTap,
      title: Row(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Color(0xFF141822))),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFF00A2FF), borderRadius: BorderRadius.circular(3)),
              child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
            ),
          ],
        ],
      ),
      trailing: hasSub ? const Icon(Icons.keyboard_arrow_down, size: 18) : (isOpen ? const Icon(Icons.keyboard_arrow_up, size: 18) : null),
    );
  }

  Widget _subTile(String title, VoidCallback onTap, {String? badge}) {
    return ListTile(
      dense: true,
      onTap: onTap,
      title: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2B3345))),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(color: const Color(0xFF00A2FF), borderRadius: BorderRadius.circular(3)),
              child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}