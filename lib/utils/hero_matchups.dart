class HeroMatchupData {
  final List<String> strongAgainst;
  final List<String> weakAgainst;

  const HeroMatchupData({required this.strongAgainst, required this.weakAgainst});
}

const Map<String, HeroMatchupData> kHeroMatchups = {
  'reinhardt': HeroMatchupData(
    strongAgainst: ['D.Va', 'Zarya', 'Sigma', 'Soldat : 76'],
    weakAgainst: ['Bastion', 'Pharah', 'Faucheur', 'Tracer'],
  ),
  'winston': HeroMatchupData(
    strongAgainst: ['Genji', 'Fatale', 'Hanzo', 'Ange'],
    weakAgainst: ['Faucheur', 'Bastion', 'Chopper', 'D.Va'],
  ),
  'dva': HeroMatchupData(
    strongAgainst: ['Pharah', 'Fatale', 'Soldat : 76', 'Moira'],
    weakAgainst: ['Zarya', 'Symmetra', 'Mei', 'Doomfist'],
  ),
  'genji': HeroMatchupData(
    strongAgainst: ['Fatale', 'Bastion', 'Hanzo', 'Zenyatta'],
    weakAgainst: ['Winston', 'Zarya', 'Mei', 'Moira'],
  ),
  'tracer': HeroMatchupData(
    strongAgainst: ['Zenyatta', 'Fatale', 'Reinhardt', 'Sigma'],
    weakAgainst: ['Cassidy', 'Torbjörn', 'Sombra', 'Brigitte'],
  ),
  'kiriko': HeroMatchupData(
    strongAgainst: ['Ana', 'Reinhardt', 'Junker Queen', 'Chacal'],
    weakAgainst: ['Fatale', 'Tracer', 'Genji', 'Winston'],
  ),
  'ana': HeroMatchupData(
    strongAgainst: ['Chopper', 'Mauga', 'Bouldozer', 'Chacal'],
    weakAgainst: ['Genji', 'Tracer', 'Winston', 'Sombra'],
  ),
  'mercy': HeroMatchupData(
    strongAgainst: ['Pharah', 'Echo', 'Soldat : 76', 'Ashe'],
    weakAgainst: ['Fatale', 'Genji', 'Tracer', 'Sombra'],
  ),
};

HeroMatchupData getMatchup(String heroKey) {
  return kHeroMatchups[heroKey.toLowerCase()] ??
      const HeroMatchupData(
        strongAgainst: ['Héros isolés', 'Cibles sans mobilité'],
        weakAgainst: ['Tirs de barrage', 'Contrôles de foule (CC)'],
      );
}