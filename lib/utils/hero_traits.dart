/// Particularites de chaque heros que le sous-role officiel ne capture pas.
///
/// Le sous-role (initiator, sharpshooter, medic...) suffit a deduire le style
/// de jeu, mais pas les outils precis d'une composition : qui coupe les soins,
/// qui protege, qui repond aux cibles aeriennes. Cette table complete.
enum HeroTrait {
  /// Reduit ou annule les soins adverses.
  antiHeal,

  /// Deploie une protection pour l'equipe (barriere, bouclier, mur).
  protection,

  /// Rend l'equipe temporairement invulnerable ou empeche la mort.
  immortality,

  /// Visee instantanee : repond aux Pharah, Echo et autres cibles aeriennes.
  antiAir,

  /// Casse efficacement barrieres et armures.
  shieldBreak,

  /// Accelere ou repositionne toute l'equipe.
  teamMobility,

  /// Immobilise, etourdit ou repousse.
  crowdControl,

  /// Soigne beaucoup d'un coup, utile contre les pics de degats.
  burstHeal,
}

/// Traits par cle de heros. Les heros absents n'ont simplement aucun trait
/// particulier : l'analyse reste valide, elle est juste moins precise.
const Map<String, Set<HeroTrait>> kHeroTraits = {
  // --- Tanks ---
  'reinhardt': {HeroTrait.protection, HeroTrait.crowdControl},
  'sigma': {HeroTrait.protection, HeroTrait.crowdControl},
  'ramattra': {HeroTrait.protection, HeroTrait.shieldBreak},
  'winston': {HeroTrait.protection, HeroTrait.shieldBreak},
  'zarya': {HeroTrait.protection},
  'orisa': {HeroTrait.crowdControl},
  'junker-queen': {HeroTrait.antiHeal, HeroTrait.crowdControl},
  'roadhog': {HeroTrait.crowdControl},
  'dva': {HeroTrait.protection, HeroTrait.antiAir},
  'wrecking-ball': {HeroTrait.crowdControl},
  'doomfist': {HeroTrait.crowdControl},
  'mauga': {HeroTrait.shieldBreak},

  // --- Degats ---
  'ashe': {HeroTrait.antiAir},
  'cassidy': {HeroTrait.antiAir, HeroTrait.crowdControl},
  'soldier-76': {HeroTrait.antiAir},
  'widowmaker': {HeroTrait.antiAir},
  'sojourn': {HeroTrait.antiAir},
  'bastion': {HeroTrait.shieldBreak},
  'mei': {HeroTrait.protection, HeroTrait.crowdControl},
  'reaper': {HeroTrait.shieldBreak},
  'symmetra': {HeroTrait.protection, HeroTrait.shieldBreak},
  'torbjorn': {HeroTrait.shieldBreak},
  'junkrat': {HeroTrait.crowdControl},
  'pharah': {HeroTrait.crowdControl},
  'sombra': {HeroTrait.crowdControl},
  'hanzo': {HeroTrait.shieldBreak},
  'echo': {HeroTrait.antiAir},

  // --- Soutiens ---
  'ana': {HeroTrait.antiHeal, HeroTrait.burstHeal, HeroTrait.crowdControl},
  'baptiste': {HeroTrait.immortality, HeroTrait.burstHeal, HeroTrait.antiAir},
  'kiriko': {HeroTrait.immortality, HeroTrait.burstHeal},
  'lucio': {HeroTrait.teamMobility, HeroTrait.crowdControl},
  'juno': {HeroTrait.teamMobility},
  'mercy': {HeroTrait.teamMobility},
  'brigitte': {HeroTrait.protection, HeroTrait.crowdControl},
  'lifeweaver': {HeroTrait.burstHeal},
  'zenyatta': {HeroTrait.burstHeal},
  'moira': {HeroTrait.burstHeal},
  'illari': {HeroTrait.burstHeal},
  'jetpack-cat': {HeroTrait.teamMobility},
};

/// Combos d'ultimes classiques. La cle declenche le combo, les valeurs sont
/// les heros qui en profitent le mieux.
const Map<String, List<String>> kUltimateCombos = {
  'zarya': ['genji', 'hanzo', 'pharah', 'reaper', 'soldier-76', 'junkrat', 'mei', 'sigma'],
  'reinhardt': ['junkrat', 'mei', 'cassidy', 'reaper'],
  'orisa': ['junkrat', 'mei', 'bastion'],
  'ana': ['genji', 'reinhardt', 'mauga', 'winston'],
  'sigma': ['genji', 'reaper', 'junkrat'],
};

/// Libelles francais des combos, indexes par la cle declencheuse.
const Map<String, String> kUltimateComboLabels = {
  'zarya': 'Gravitation de Zarya',
  'reinhardt': 'Frappe sismique de Reinhardt',
  'orisa': 'Assaut terrestre d\'Orisa',
  'ana': 'Nano-boost d\'Ana',
  'sigma': 'Flux gravitationnel de Sigma',
};

Set<HeroTrait> traitsOf(String heroKey) => kHeroTraits[heroKey] ?? const {};
