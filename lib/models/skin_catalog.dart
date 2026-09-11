import 'dart:math';

import 'loot_drop.dart';

/// Noms de skins proposes par les coffres, classes par rarete.
///
/// Ce sont des modeles generiques (facon "skins de base" Overwatch) combines
/// au heros tire : un coffre peut donc rendre « GENJI — Carmin » ou
/// « MAUGA — Mythique ». Les collaborations officielles, elles, restent
/// dans l'ecran Boutique.
const Map<LootRarity, List<String>> kSkinNamesByRarity = {
  LootRarity.common: [
    'Classique',
    'Cadet',
    'Acier',
    'Cendre',
    'Graphite',
  ],
  LootRarity.rare: [
    'Cobalt',
    'Émeraude',
    'Carmin',
    'Ambre',
    'Ivoire',
    'Azur',
  ],
  LootRarity.epic: [
    'Cyber',
    'Spectre',
    'Néon',
    'Obsidienne',
    'Chromatique',
    'Vortex',
  ],
  LootRarity.legendary: [
    'Mythique',
    'Doré',
    'Céleste',
    'Éclipse',
    'Prisme Noir',
    'Aurore',
  ],
};

/// Tire un nom de skin coherent avec la rarete demandee.
String randomSkinName(LootRarity rarity, Random random) {
  final names = kSkinNamesByRarity[rarity] ?? const ['Classique'];
  return names[random.nextInt(names.length)];
}
