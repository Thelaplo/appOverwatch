import 'package:flutter/material.dart';
import '../models/hero.dart';
import '../utils/image_helper.dart';

class OverwatchBevelClipper extends CustomClipper<Path> {
  final double cut;
  OverwatchBevelClipper({this.cut = 14.0});

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(cut, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - cut)
      ..lineTo(size.width - cut, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, cut)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class OverwatchHeroCard extends StatefulWidget {
  final HeroSummary hero;
  final VoidCallback onTap;

  const OverwatchHeroCard({super.key, required this.hero, required this.onTap});

  @override
  State<OverwatchHeroCard> createState() => _OverwatchHeroCardState();
}

class _OverwatchHeroCardState extends State<OverwatchHeroCard> {
  bool _isHovered = false;

  String _formatRole(String role) {
    switch (role) {
      case 'tank':
        return 'TANK';
      case 'damage':
        return 'DÉGÂTS';
      case 'support':
        return 'SOUTIEN';
      default:
        return role.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: ClipPath(
            clipper: OverwatchBevelClipper(cut: 14),
            child: Container(
              decoration: BoxDecoration(
                color: _isHovered ? const Color(0xFFF99E1A) : const Color(0xFF282E3E),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: const Color(0xFFF99E1A).withAlpha(140),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              padding: const EdgeInsets.all(2.0),
              child: ClipPath(
                clipper: OverwatchBevelClipper(cut: 12),
                child: Container(
                  color: const Color(0xFF131722),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: widget.hero.key,
                        child: AnimatedScale(
                          scale: _isHovered ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 220),
                          child: Image.network(
                            buildImageUrl(widget.hero.portrait, width: 320),
                            fit: BoxFit.cover,
                            cacheWidth: 320,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(Icons.person, size: 40, color: Colors.white24),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: const [0.3, 0.7, 1.0],
                              colors: [
                                Colors.transparent,
                                const Color(0xFF0C0F17).withAlpha(160),
                                _isHovered
                                    ? const Color(0xFFF99E1A).withAlpha(200)
                                    : const Color(0xFF0C0F17).withAlpha(245),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform(
                              transform: Matrix4.skewX(-0.2),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: _isHovered ? Colors.black : const Color(0xFFF99E1A),
                                child: Text(
                                  _formatRole(widget.hero.role),
                                  style: TextStyle(
                                    color: _isHovered ? const Color(0xFFF99E1A) : Colors.black,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Transform(
                              transform: Matrix4.skewX(-0.2),
                              child: Text(
                                widget.hero.name.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: _isHovered ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}