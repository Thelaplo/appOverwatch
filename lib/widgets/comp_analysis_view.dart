import 'package:flutter/material.dart';

import '../utils/comp_analyzer.dart';

/// Rendu du diagnostic d'escouade : style de jeu, points de vie,
/// repartition des roles et notes. Extrait de CompsScreen, qui melangeait
/// le simulateur, les compos meta et tout cet affichage dans un seul
/// fichier de plus de 450 lignes.
class CompAnalysisView extends StatelessWidget {
  final CompAnalysis analysis;

  const CompAnalysisView({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _styleBanner(analysis),
        const SizedBox(height: 12),
        _hitpointsPanel(analysis),
        const SizedBox(height: 12),
        _rolePanel(analysis),
        const SizedBox(height: 12),
        if (analysis.ultCombos.isNotEmpty) ...
          [
            _sectionTitle('COMBOS D\'ULTIMES'),
            ...analysis.ultCombos.map(
              (c) => _diag(c, const Color(0xFFD500F9), Icons.auto_awesome),
            ),
            const SizedBox(height: 6),
          ],
        ..._notesSection(analysis, NoteKind.strength, 'POINTS FORTS',
            const Color(0xFF00E676), Icons.check_circle_outline),
        ..._notesSection(analysis, NoteKind.warning, 'FAIBLESSES',
            const Color(0xFFFF5252), Icons.warning_amber_rounded),
        ..._notesSection(analysis, NoteKind.tip, 'À AJUSTER',
            const Color(0xFFF99E1A), Icons.lightbulb_outline),
      ],
    );
  }

  Widget _diag(String text, Color color, [IconData? icon]) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF141822),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70)),
            ),
          ],
        ),
      );

  Widget _sectionTitle(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 4),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      );

  /// Bandeau indiquant le style de jeu identifie.
  Widget _styleBanner(CompAnalysis analysis) {
    const colors = {
      CompStyle.dive: Color(0xFF00E5FF),
      CompStyle.brawl: Color(0xFFFF5252),
      CompStyle.poke: Color(0xFFF99E1A),
      CompStyle.hybrid: Color(0xFF9E9E9E),
      CompStyle.unknown: Color(0xFF9E9E9E),
    };
    final color = colors[analysis.style] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141822),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'STYLE : ${analysis.style.label}',
                style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14),
              ),
              const Spacer(),
              if (analysis.style != CompStyle.unknown && analysis.style != CompStyle.hybrid)
                Text(
                  '${(analysis.styleConfidence * 100).round()} %',
                  style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            analysis.style.description,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Points de vie cumules, avec le detail armure / boucliers.
  Widget _hitpointsPanel(CompAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF141822),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                analysis.hpIsExact ? 'POINTS DE VIE' : 'POINTS DE VIE (ESTIMÉS)',
                style: const TextStyle(
                  color: Color(0xFFF99E1A),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                '${analysis.totalHp} PV',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          if (analysis.armor > 0 || analysis.shields > 0) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                if (analysis.armor > 0)
                  Text(
                    '${analysis.armor} armure',
                    style: const TextStyle(color: Color(0xFFFFB300), fontSize: 11),
                  ),
                if (analysis.armor > 0 && analysis.shields > 0)
                  const Text('  •  ', style: TextStyle(color: Colors.white24, fontSize: 11)),
                if (analysis.shields > 0)
                  Text(
                    '${analysis.shields} boucliers',
                    style: const TextStyle(color: Color(0xFF00E5FF), fontSize: 11),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Rappel de la repartition des roles, comparee au 1-2-2 de la file par role.
  Widget _rolePanel(CompAnalysis analysis) {
    Widget cell(String label, int count, int expected) {
      final ok = count == expected;
      return Expanded(
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 2),
            Text(
              '$count / $expected',
              style: TextStyle(
                color: ok ? const Color(0xFF00E676) : const Color(0xFFFF5252),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: const Color(0xFF141822),
      child: Row(
        children: [
          cell('TANK', analysis.tanks, 1),
          cell('DÉGÂTS', analysis.damages, 2),
          cell('SOUTIEN', analysis.supports, 2),
        ],
      ),
    );
  }

  /// Une section de notes (forces, faiblesses, conseils), masquee si vide.
  List<Widget> _notesSection(
    CompAnalysis analysis,
    NoteKind kind,
    String title,
    Color color,
    IconData icon,
  ) {
    final notes = analysis.notes.where((n) => n.kind == kind).toList();
    if (notes.isEmpty) return const [];

    return [
      _sectionTitle(title),
      ...notes.map((n) => _diag(n.text, color, icon)),
      const SizedBox(height: 6),
    ];
  }
}
