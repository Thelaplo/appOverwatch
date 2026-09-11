import 'package:flutter/material.dart';

class BlizzardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuTap;
  const BlizzardAppBar({super.key, required this.onMenuTap});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFF7F8FA),
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFF212529)),
        onPressed: onMenuTap,
      ),
      centerTitle: true,
      // Le logo distant renvoyait 422 : on affichait donc toujours le texte
      // de repli. La marque est maintenant embarquee dans l'application.
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icon/athena_mark.png', height: 30),
          const SizedBox(width: 10),
          Transform(
            transform: Matrix4.skewX(-0.16),
            child: const Text(
              'ATHENA',
              style: TextStyle(
                color: Color(0xFF212529),
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.person_outline, color: Color(0xFF212529), size: 24),
        ),
      ],
    );
  }
}