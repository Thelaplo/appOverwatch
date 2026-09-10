import 'package:flutter/material.dart';

class HeroPerk {
  final String name;
  final String desc;
  final IconData icon;
  const HeroPerk(this.name, this.desc, this.icon);
}

class HeroPerksData {
  final List<HeroPerk> minorPerks;
  final List<HeroPerk> majorPerks;
  const HeroPerksData({required this.minorPerks, required this.majorPerks});
}

class HeroPerksSection extends StatefulWidget {
  final String heroKey;
  const HeroPerksSection({super.key, required this.heroKey});

  @override
  State<HeroPerksSection> createState() => _HeroPerksSectionState();
}

class _HeroPerksSectionState extends State<HeroPerksSection> {
  int _selectedMinor = 0;
  int _selectedMajor = 0;

  static final Map<String, HeroPerksData> _heroPerksDatabase = {
    'ana': const HeroPerksData(
      minorPerks: [
        HeroPerk('RÉVEIL DIFFICILE', 'Les ennemis réveillés d’une fléchette hypodermique sont ralentis et subissent 50 dégâts.', Icons.flash_on),
        HeroPerk('RÉCUPÉRATION AGILE', 'Vitesse de rechargement et déplacement augmentées de 20 % pendant 3 s après un tir de capacité.', Icons.navigation),
      ],
      majorPerks: [
        HeroPerk('REBOND BIOTIQUE', 'La Grenade biotique rebondit et explose une seconde fois pour un surcroît de soins et dégâts.', Icons.medical_services),
        HeroPerk('SURCHARGE NANOMÉCANIQUE', 'Nanoboost accorde 1,5 s d’invulnérabilité complète à l’allié ciblé.', Icons.bolt),
      ],
    ),
    'ashe': const HeroPerksData(
      minorPerks: [
        HeroPerk('DÉTONATEUR RAPIDE', 'La Dynamite explose 20 % plus vite et son temps de recharge est réduit de 2 s.', Icons.timer),
        HeroPerk('RECUL PROVIGNÉ', 'Le Fusil à canon scié projette Ashe 25 % plus loin et étourdit brièvement les cibles proches.', Icons.north_east),
      ],
      majorPerks: [
        HeroPerk('B.O.B. ENRAGÉ', 'B.O.B. gagne 250 points d’armure supplémentaire et inflige des dégâts de piétinement accrus.', Icons.smart_toy),
        HeroPerk('COMBUSTION PERSISTANTE', 'Les brûlures de la dynamite durent 2 s de plus et révèlent la position des ennemis à travers les murs.', Icons.local_fire_department),
      ],
    ),
    'dva': const HeroPerksData(
      minorPerks: [
        HeroPerk('PROPULSEURS RENFORCÉS', 'Les turboréacteurs infligent 30 points de dégâts supplémentaires et ont un délai réduit.', Icons.speed),
        HeroPerk('MATRICE SURVITAMINÉE', 'La matrice de défense absorbe 1 seconde supplémentaire et convertit 10 % en armure.', Icons.shield),
      ],
      majorPerks: [
        HeroPerk('AUTODESTRUCTION MEGATONNE', 'Le rayon de déflagration ultime est augmenté de 25 % et la réinvocation du méca est instantanée.', Icons.warning),
        HeroPerk('MICRO-MISSILES GUIDÉS', 'Les micro-missiles acquièrent une légère trajectoire à tête chercheuse sur les cibles verrouillées.', Icons.rocket),
      ],
    ),
    'reinhardt': const HeroPerksData(
      minorPerks: [
        HeroPerk('FRAPPE DE FEU DOUBLE', 'Gagne une charge supplémentaire de Frappe de feu avec une vitesse de projectile accrue.', Icons.local_fire_department),
        HeroPerk('STABILITÉ DE CROISÉ', 'Résistance au recul augmentée de 40 % et régénération du bouclier accélérée de 20 %.', Icons.security),
      ],
      majorPerks: [
        HeroPerk('CHOC TERRESTRE SISMIQUE', 'Choc sismique traverse les petits obstacles et prolonge la mise à terre de 1 seconde.', Icons.gavel),
        HeroPerk('CHARGE IMPLACABLE', 'Pendant la Charge, Reinhardt est insensible aux étourdissements et gagne 150 points d’armure temporaire.', Icons.fast_forward),
      ],
    ),
    'kiriko': const HeroPerksData(
      minorPerks: [
        HeroPerk('PAS AGILE', 'Le Pas véloce soigne Kiriko de 50 PV et supprime tous les ralentissements actifs.', Icons.directions_run),
        HeroPerk('KUNAI ACÉRÉ', 'Les tirs critiques au Kunai réduisent le délai de récupération du Suzu de protection de 0,5 s.', Icons.gps_fixed),
      ],
      majorPerks: [
        HeroPerk('SUZU EXPANSION', 'Le Suzu applique une zone d’invulnérabilité 30 % plus large et repousse violemment les ennemis.', Icons.bubble_chart),
        HeroPerk('CHEMIN DE KITSUNE SPIRITUEL', 'L’ultime confère un vol temporaire de vie et une régénération de PV accrue à toute l’équipe.', Icons.pets),
      ],
    ),
  };

  HeroPerksData _getPerksForHero(String key) {
    final clean = key.toLowerCase().trim();
    if (_heroPerksDatabase.containsKey(clean)) {
      return _heroPerksDatabase[clean]!;
    }
    // Données par défaut pour les héros récents (comme Anran, Venture ou Juno)
    return HeroPerksData(
      minorPerks: [
        HeroPerk('CADENCE MARTIALE', 'Réduit les temps de recharge de 15 % et augmente la vitesse de replacement au combat.', Icons.flash_on),
        HeroPerk('SYNERGIE RÉFLEXE', 'L’élimination ou assistance confère un boost de vitesse de 25 % pendant 2,5 secondes.', Icons.bolt),
      ],
      majorPerks: [
        HeroPerk('SURCHARGE STRATÉGIQUE', 'La capacité ultime recharge instantanément toutes les compétences et octroie un surbouclier.', Icons.star),
        HeroPerk('IMPACT PRIMORDIAL', 'Les compétences infligent des dégâts de zone résiduels qui brûlent les cibles touchées.', Icons.local_fire_department),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final perksData = _getPerksForHero(widget.heroKey);
    final minorPerk = perksData.minorPerks[_selectedMinor.clamp(0, perksData.minorPerks.length - 1)];
    final majorPerk = perksData.majorPerks[_selectedMajor.clamp(0, perksData.majorPerks.length - 1)];

    return Container(
      color: const Color(0xFF0E131E),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          const Text('BONUS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text(
            'Débloquez des améliorations en cours de partie pour changer le cours de la bataille ! Choisissez de nouvelles capacités pour améliorer la puissance de votre personnage.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 24),
          _buildPerkLevel('BONUS MINEUR', '(NIVEAU 2)', perksData.minorPerks, _selectedMinor, minorPerk, (i) => setState(() => _selectedMinor = i)),
          const SizedBox(height: 24),
          _buildPerkLevel('BONUS MAJEUR', '(NIVEAU 3)', perksData.majorPerks, _selectedMajor, majorPerk, (i) => setState(() => _selectedMajor = i)),
        ],
      ),
    );
  }

  Widget _buildPerkLevel(String title, String lvl, List<HeroPerk> perks, int selectedIdx, HeroPerk current, ValueChanged<int> onSelect) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
        Text(lvl, style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 11)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: perks.asMap().entries.map((e) {
            final active = e.key == selectedIdx;
            return GestureDetector(
              onTap: () => onSelect(e.key),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF141926),
                  border: Border.all(color: active ? const Color(0xFFF99E1A) : Colors.white24, width: active ? 2.5 : 1),
                ),
                child: Icon(e.value.icon, color: active ? const Color(0xFFF99E1A) : Colors.white54, size: 22),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF1F293D), borderRadius: BorderRadius.circular(6)),
          child: Column(
            children: [
              Text(current.name, style: const TextStyle(color: Color(0xFFF99E1A), fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(current.desc, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}