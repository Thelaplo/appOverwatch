import 'package:flutter/material.dart';
import '../models/hero.dart';
import '../utils/image_helper.dart';

class HeroCardBlizzard extends StatelessWidget {
  final HeroSummary hero;
  final bool isNew;
  final VoidCallback onTap;

  const HeroCardBlizzard({super.key, required this.hero, this.isNew = false, required this.onTap});

  IconData _roleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'tank': return Icons.shield_outlined;
      case 'damage': return Icons.gps_fixed;
      case 'support': return Icons.add_circle_outline;
      default: return Icons.star_border;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: const Color(0xFFE0E5EC)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 6, offset: const Offset(0, 3))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Portrait du héros avec tag NOUVEAU optionnel
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFF1E2838)),
                  Image.network(
                    buildImageUrl(hero.portrait, width: 260),
                    fit: BoxFit.cover,
                    cacheWidth: 260,
                  ),
                  if (isNew || hero.key == 'hazard' || hero.key == 'juno' || hero.key == 'venture')
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF99E1A),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text(
                          'NOUVEAU',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 0.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Pied de carte blanc avec picto officiel et nom
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_roleIcon(hero.role), size: 14, color: const Color(0xFF2B3345)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      hero.name.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 0.8, color: Color(0xFF141822)),
                    ),
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