import 'package:flutter/material.dart';
import '../utils/hero_matchups.dart';

class HeroCountersSection extends StatelessWidget {
  final String heroKey;

  const HeroCountersSection({super.key, required this.heroKey});

  @override
  Widget build(BuildContext context) {
    final data = getMatchup(heroKey);
    if (data == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform(
            transform: Matrix4.skewX(-0.16),
            child: const Text(
              'MATCHUPS & STRATÉGIE',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          _buildMatchupBlock('AVANTAGE SUR (FORCES)', data.strongAgainst, const Color(0xFF00E676)),
          const SizedBox(height: 10),
          _buildMatchupBlock('VULNÉRABLE FACE À (FAIBLESSES)', data.weakAgainst, const Color(0xFFFF5252)),
        ],
      ),
    );
  }

  Widget _buildMatchupBlock(String title, List<String> heroes, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141822),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform(
            transform: Matrix4.skewX(-0.16),
            child: Text(
              title,
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.0),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: heroes.map((h) {
              return Transform(
                transform: Matrix4.skewX(-0.16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  color: const Color(0xFF1B202D),
                  child: Text(
                    h.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}