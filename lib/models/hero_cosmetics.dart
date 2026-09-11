enum CosmeticRarity {
  rare('RARE', 0xFF00E5FF),
  epic('ÉPIQUE', 0xFFD500F9),
  legendary('LÉGENDAIRE', 0xFFFFB300);

  final String label;
  final int colorValue;
  const CosmeticRarity(this.label, this.colorValue);
}

class HeroSkin {
  final String heroName;
  final String skinName;
  final CosmeticRarity rarity;
  final String portraitPath;

  const HeroSkin({
    required this.heroName,
    required this.skinName,
    required this.rarity,
    required this.portraitPath,
  });
}

class HeroVoiceLine {
  final String hero;
  final String text;
  final double freq;

  const HeroVoiceLine({
    required this.hero,
    required this.text,
    required this.freq,
  });
}

// Utilisation directe des portraits officiels certifiés de l'API OverFast
const List<HeroSkin> kOfficialSkins = [
  HeroSkin(
    heroName: 'D.VA',
    skinName: 'Waveracer (Nautique)',
    rarity: CosmeticRarity.legendary,
    portraitPath: 'https://d15f34w2p8l1cc.cloudfront.net/overwatch/0aa3027b4f73ae0a22a275ddbeeeae8fb41f17e089fa1bbfa752ea7ea383437e.png',
  ),
  HeroSkin(
    heroName: 'GENJI',
    skinName: 'Cyberdémon (Mythique)',
    rarity: CosmeticRarity.legendary,
    portraitPath: 'https://d15f34w2p8l1cc.cloudfront.net/overwatch/b083d81b9ee5caefb030b42ca2c63820610360a006c9a296d93b3fbafec809dd.png',
  ),
  HeroSkin(
    heroName: 'REINHARDT',
    skinName: 'Croisé Balderich',
    rarity: CosmeticRarity.legendary,
    portraitPath: 'https://d15f34w2p8l1cc.cloudfront.net/overwatch/a9e7d32c91b5d17978f107f960f274cb7eb45ef334cf33be3a7b4f5358055c11.png',
  ),
  HeroSkin(
    heroName: 'ANA',
    skinName: 'Capitaine Amari',
    rarity: CosmeticRarity.epic,
    portraitPath: 'https://d15f34w2p8l1cc.cloudfront.net/overwatch/3429c395726252984cfb7454f7a26fdb1cc93b454df7eb0f76e3d23f3fc575bc.png',
  ),
  HeroSkin(
    heroName: 'KIRIKO',
    skinName: 'Matsuri de Kanezaka',
    rarity: CosmeticRarity.epic,
    portraitPath: 'https://d15f34w2p8l1cc.cloudfront.net/overwatch/f460a5e2f7b5160be1c90dc88b7762d1cfa9ecdf8b816a695e2632e8f192eb68.png',
  ),
];

const List<HeroVoiceLine> kOfficialVoiceLines = [
  HeroVoiceLine(hero: 'D.VA', text: '« Nerf this ! »', freq: 587.33),
  HeroVoiceLine(hero: 'REINHARDT', text: '« Vivre avec honneur ! »', freq: 220.00),
  HeroVoiceLine(hero: 'ANA', text: '« La justice a besoin de repos. »', freq: 440.00),
  HeroVoiceLine(hero: 'KIRIKO', text: '« Sur ma bicyclette ! »', freq: 659.25),
  // Frequence tres aigue pour le chat a reaction, tres grave pour le tank samoan.
  HeroVoiceLine(hero: 'JETPACK CAT', text: '« Miaou ! Soutien aérien en approche ! »', freq: 880.00),
  HeroVoiceLine(hero: 'MAUGA', text: '« Chaos, chaos, chaos ! »', freq: 146.83),
];