import '../models/hero.dart';
import 'hero_stats_api.dart';
import 'hero_traits.dart';

/// Style de jeu dominant deduit des sous-roles officiels.
enum CompStyle {
  dive('PLONGÉE', 'Engagement rapide sur les cibles isolées, en contournant la ligne de front.'),
  brawl('CHOC FRONTAL', 'Avancée groupée à courte portée, sous protection.'),
  poke('HARCÈLEMENT', 'Pression à longue portée pour user l\'adversaire avant l\'engagement.'),
  hybrid('HYBRIDE', 'Aucun style ne se dégage nettement.'),
  unknown('—', 'Complétez l\'escouade pour identifier un style.');

  final String label;
  final String description;
  const CompStyle(this.label, this.description);
}

enum NoteKind { strength, warning, tip }

class CompNote {
  final String text;
  final NoteKind kind;

  const CompNote(this.text, this.kind);
}

class CompAnalysis {
  final int totalHp;
  final int armor;
  final int shields;

  /// null tant que les points de vie reels n'ont pas ete recuperes.
  final bool hpIsExact;

  final CompStyle style;

  /// Part du style dominant, de 0 a 1 : sert a nuancer « hybride ».
  final double styleConfidence;

  final List<CompNote> notes;
  final List<String> ultCombos;
  final int tanks;
  final int damages;
  final int supports;

  const CompAnalysis({
    required this.totalHp,
    required this.armor,
    required this.shields,
    required this.hpIsExact,
    required this.style,
    required this.styleConfidence,
    required this.notes,
    required this.ultCombos,
    required this.tanks,
    required this.damages,
    required this.supports,
  });

  bool get isEmpty => tanks + damages + supports == 0;
}

/// Points de vie approximatifs, utilises tant que l'API n'a pas repondu.
const Map<String, int> _fallbackHpByRole = {
  'tank': 600,
  'damage': 225,
  'support': 225,
};

/// Analyse une escouade.
///
/// [hitpoints] associe une cle de heros a ses points de vie reels. Les heros
/// absents de cette table sont estimes d'apres leur role, et l'analyse le
/// signale via [CompAnalysis.hpIsExact].
CompAnalysis analyzeTeam(
  List<HeroSummary?> team, {
  Map<String, HeroHitpoints> hitpoints = const {},
}) {
  final selected = team.whereType<HeroSummary>().toList();

  if (selected.isEmpty) {
    return const CompAnalysis(
      totalHp: 0,
      armor: 0,
      shields: 0,
      hpIsExact: true,
      style: CompStyle.unknown,
      styleConfidence: 0,
      notes: [CompNote('Sélectionnez des héros pour analyser l\'escouade.', NoteKind.tip)],
      ultCombos: [],
      tanks: 0,
      damages: 0,
      supports: 0,
    );
  }

  final keys = selected.map((h) => h.key).toSet();
  final traits = <HeroTrait>{for (final h in selected) ...traitsOf(h.key)};

  // --- Points de vie ---
  var hp = 0;
  var armor = 0;
  var shields = 0;
  var hpIsExact = true;
  for (final hero in selected) {
    final real = hitpoints[hero.key];
    if (real != null) {
      hp += real.total;
      armor += real.armor;
      shields += real.shields;
    } else {
      hp += _fallbackHpByRole[hero.role] ?? 200;
      hpIsExact = false;
    }
  }

  // --- Repartition des roles ---
  final tanks = selected.where((h) => h.role == 'tank').length;
  final damages = selected.where((h) => h.role == 'damage').length;
  final supports = selected.where((h) => h.role == 'support').length;

  // --- Style de jeu, deduit des sous-roles ---
  final scores = <CompStyle, int>{CompStyle.dive: 0, CompStyle.brawl: 0, CompStyle.poke: 0};
  for (final hero in selected) {
    switch (hero.subrole) {
      case 'initiator':
      case 'flanker':
        scores[CompStyle.dive] = scores[CompStyle.dive]! + 1;
        break;
      case 'bruiser':
      case 'survivor':
        scores[CompStyle.brawl] = scores[CompStyle.brawl]! + 1;
        break;
      case 'sharpshooter':
      case 'recon':
        scores[CompStyle.poke] = scores[CompStyle.poke]! + 1;
        break;
      case 'stalwart':
        // Une ligne de front tient aussi bien le choc frontal que le poke.
        scores[CompStyle.brawl] = scores[CompStyle.brawl]! + 1;
        scores[CompStyle.poke] = scores[CompStyle.poke]! + 1;
        break;
      case 'medic':
      case 'specialist':
      case 'tactician':
        // Ces sous-roles s'adaptent a tous les styles.
        break;
    }
  }

  final totalScore = scores.values.fold(0, (a, b) => a + b);
  var style = CompStyle.unknown;
  var confidence = 0.0;

  if (totalScore > 0) {
    final best = scores.entries.reduce((a, b) => a.value >= b.value ? a : b);
    confidence = best.value / totalScore;
    // En dessous de la moitie des voix, aucun style ne se detache vraiment.
    style = confidence >= 0.5 ? best.key : CompStyle.hybrid;
  }

  final notes = <CompNote>[];

  // --- Forces ---
  if (traits.contains(HeroTrait.protection)) {
    notes.add(const CompNote('Protection disponible pour la ligne de front', NoteKind.strength));
  }
  if (traits.contains(HeroTrait.antiHeal)) {
    notes.add(const CompNote('Capacité à couper les soins adverses', NoteKind.strength));
  }
  if (traits.contains(HeroTrait.damageAmp)) {
    notes.add(const CompNote(
      'Amplification de dégâts : efficace contre les tanks sans barrière',
      NoteKind.strength,
    ));
  }
  if (traits.contains(HeroTrait.antiAir)) {
    notes.add(const CompNote('Réponse aux cibles aériennes (visée instantanée)', NoteKind.strength));
  }
  if (traits.contains(HeroTrait.immortality)) {
    notes.add(const CompNote('Sauvegarde d\'urgence contre les ultimes adverses', NoteKind.strength));
  }
  if (traits.contains(HeroTrait.teamMobility)) {
    notes.add(const CompNote('Mobilité d\'équipe pour prendre l\'espace', NoteKind.strength));
  }
  if (traits.contains(HeroTrait.shieldBreak)) {
    notes.add(const CompNote('Bon rendement contre barrières et armures', NoteKind.strength));
  }
  if (traits.contains(HeroTrait.crowdControl)) {
    notes.add(const CompNote('Contrôle de zone pour figer l\'adversaire', NoteKind.strength));
  }

  // --- Faiblesses ---
  if (!traits.contains(HeroTrait.antiAir)) {
    notes.add(const CompNote(
      'Aucune réponse aérienne : Pharah et Echo seront difficiles à déloger',
      NoteKind.warning,
    ));
  }
  // Couper les soins et amplifier les degats resolvent le meme probleme :
  // faire tomber une cible que l'equipe n'arrive pas a tuer. Une grenade
  // biotique d'Ana ou une Discorde de Zenyatta suffisent l'une comme l'autre.
  final canBreakThrough =
      traits.contains(HeroTrait.antiHeal) || traits.contains(HeroTrait.damageAmp);

  if (!canBreakThrough && selected.length >= 4) {
    notes.add(const CompNote(
      'Ni anti-soin ni amplification de dégâts : les cibles très soignées '
      'resteront difficiles à faire tomber',
      NoteKind.warning,
    ));
  } else if (traits.contains(HeroTrait.antiHeal) && !traits.contains(HeroTrait.damageAmp)) {
    notes.add(const CompNote(
      'Anti-soin présent, mais une Discorde ou une amplification ajouterait '
      'de la pression sur les tanks sans barrière',
      NoteKind.tip,
    ));
  }
  if (!traits.contains(HeroTrait.protection) && tanks > 0) {
    notes.add(const CompNote(
      'Ligne de front sans protection déployable : exposée aux dégâts à distance',
      NoteKind.warning,
    ));
  }
  if (!traits.contains(HeroTrait.burstHeal) && supports > 0) {
    notes.add(const CompNote(
      'Soins réguliers mais peu de soins d\'urgence face aux pics de dégâts',
      NoteKind.warning,
    ));
  }
  if (style == CompStyle.hybrid) {
    notes.add(const CompNote(
      'Styles de jeu mélangés : l\'équipe risque de manquer de cohésion',
      NoteKind.warning,
    ));
  }
  if (style == CompStyle.dive && !traits.contains(HeroTrait.teamMobility) && selected.length >= 4) {
    notes.add(const CompNote(
      'Plongée sans accélération d\'équipe : les soutiens suivront difficilement',
      NoteKind.warning,
    ));
  }

  // --- Conseils de composition ---
  if (tanks == 0) notes.add(const CompNote('Il manque un tank pour encaisser', NoteKind.tip));
  if (tanks > 1) notes.add(const CompNote('Deux tanks : impossible en file par rôle', NoteKind.tip));
  if (damages < 2) {
    notes.add(CompNote(
      'Il manque ${2 - damages} héros de dégâts',
      NoteKind.tip,
    ));
  }
  if (damages > 2) notes.add(const CompNote('Plus de deux DPS : impossible en file par rôle', NoteKind.tip));
  if (supports < 2) {
    notes.add(CompNote(
      'Il manque ${2 - supports} soutien${2 - supports > 1 ? 's' : ''} : volume de soins insuffisant',
      NoteKind.tip,
    ));
  }
  if (supports > 2) notes.add(const CompNote('Plus de deux soutiens : impossible en file par rôle', NoteKind.tip));

  // --- Combos d'ultimes ---
  final combos = <String>[];
  kUltimateCombos.forEach((trigger, partners) {
    if (!keys.contains(trigger)) return;
    final present = partners.where(keys.contains).toList();
    if (present.isEmpty) return;

    final partnerNames = present
        .map((k) => selected.firstWhere((h) => h.key == k).name)
        .join(', ');
    combos.add('${kUltimateComboLabels[trigger] ?? trigger} → $partnerNames');
  });

  return CompAnalysis(
    totalHp: hp,
    armor: armor,
    shields: shields,
    hpIsExact: hpIsExact,
    style: style,
    styleConfidence: confidence,
    notes: notes,
    ultCombos: combos,
    tanks: tanks,
    damages: damages,
    supports: supports,
  );
}
