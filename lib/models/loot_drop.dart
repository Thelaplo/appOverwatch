import 'dart:math';
import 'package:flutter/material.dart';
import 'hero.dart';

enum LootRarity {
  common('COMMUN', Color(0xFFB0BEC5), 0.50),
  rare('RARE', Color(0xFF00E5FF), 0.30),
  epic('ÉPIQUE', Color(0xFFD500F9), 0.15),
  legendary('LÉGENDAIRE', Color(0xFFFFB300), 0.05);

  final String label;
  final Color color;
  final double probability;

  const LootRarity(this.label, this.color, this.probability);
}

class LootItem {
  final HeroSummary hero;
  final LootRarity rarity;

  LootItem({required this.hero, required this.rarity});
}

class LootboxRoll {
  static List<LootItem> roll4Items(List<HeroSummary> heroes) {
    final rand = Random();
    return List.generate(4, (_) {
      final roll = rand.nextDouble();
      LootRarity rarity;
      if (roll < 0.08) {
        rarity = LootRarity.legendary;
      } else if (roll < 0.25) {
        rarity = LootRarity.epic;
      } else if (roll < 0.60) {
        rarity = LootRarity.rare;
      } else {
        rarity = LootRarity.common;
      }
      final hero = heroes[rand.nextInt(heroes.length)];
      return LootItem(hero: hero, rarity: rarity);
    });
  }
}