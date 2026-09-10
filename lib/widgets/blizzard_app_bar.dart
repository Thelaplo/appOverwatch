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
      title: Image.network(
        'https://images.blz-contentstack.com/v3/assets/blt9c12f249ac15c7ec/blt6d55d28aa0743b17/633e0a29482813098319f359/overwatch-logo.png',
        height: 28,
        errorBuilder: (_, __, ___) => const Text(
          'OVERWATCH',
          style: TextStyle(color: Color(0xFF212529), fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16),
        ),
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