import '../models/hero.dart';

class CompAnalysis {
  final int totalHp;
  final List<String> strengths;
  final List<String> warnings;

  CompAnalysis({required this.totalHp, required this.strengths, required this.warnings});
}

CompAnalysis analyzeTeam(List<HeroSummary?> team) {
  final selected = team.whereType<HeroSummary>().toList();
  if (selected.isEmpty) {
    return CompAnalysis(totalHp: 0, strengths: [], warnings: ['Sélectionnez des héros pour analyser l\'escouade.']);
  }

  int hp = 0;
  final names = selected.map((h) => h.name.toLowerCase()).toList();

  for (final hero in selected) {
    switch (hero.role) {
      case 'tank': hp += 650; break;
      case 'damage': hp += 250; break;
      case 'support': hp += 225; break;
      default: hp += 200;
    }
  }

  final strengths = <String>[];
  final warnings = <String>[];

  // Analyse bouclier / frontline
  if (names.any((n) => n.contains('rein') || n.contains('sigma') || n.contains('ramattra'))) {
    strengths.add('Excellente protection de ligne de front (Shield)');
  } else if (names.any((n) => n.contains('winston') || n.contains('d.va') || n.contains('doomfist'))) {
    strengths.add('Forte capacité d\'agression et de plongée (Dive)');
  }

  // Analyse Hitscan / Anti-aérien
  if (names.any((n) => n.contains('soldat') || n.contains('cassidy') || n.contains('ashe') || n.contains('fatale'))) {
    strengths.add('Pression à distance et réponse anti-aérienne (Hitscan)');
  } else {
    warnings.add('Attention aux cibles volantes (Pharah / Echo)');
  }

  // Analyse Soutien
  final supportCount = selected.where((h) => h.role == 'support').length;
  if (supportCount < 2 && selected.length == 5) {
    warnings.add('Volume de soins potentiellement insuffisant');
  }

  return CompAnalysis(totalHp: hp, strengths: strengths, warnings: warnings);
}