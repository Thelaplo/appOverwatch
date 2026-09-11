import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'loot_drop.dart';

/// Un skin obtenu dans un coffre et conserve dans l'inventaire du joueur.
class InventoryItem {
  final String heroKey;
  final String heroName;
  final String skinName;
  final String portrait;
  final LootRarity rarity;
  final DateTime obtainedAt;

  const InventoryItem({
    required this.heroKey,
    required this.heroName,
    required this.skinName,
    required this.portrait,
    required this.rarity,
    required this.obtainedAt,
  });

  /// Identifie un skin unique : deux tirages du meme skin sur le meme heros
  /// sont des doublons.
  String get uniqueId => '$heroKey::$skinName';

  Map<String, dynamic> toJson() => {
        'heroKey': heroKey,
        'heroName': heroName,
        'skinName': skinName,
        'portrait': portrait,
        'rarity': rarity.name,
        'obtainedAt': obtainedAt.toIso8601String(),
      };

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      heroKey: json['heroKey'] as String? ?? '',
      heroName: json['heroName'] as String? ?? 'Inconnu',
      skinName: json['skinName'] as String? ?? 'Classique',
      portrait: json['portrait'] as String? ?? '',
      rarity: LootRarity.values.firstWhere(
        (r) => r.name == json['rarity'],
        orElse: () => LootRarity.common,
      ),
      obtainedAt:
          DateTime.tryParse(json['obtainedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Resultat d'un ajout de butin : permet a l'ecran des coffres de signaler
/// les nouveautes et les doublons.
class InventoryAddResult {
  final List<InventoryItem> added;
  final List<InventoryItem> duplicates;

  const InventoryAddResult({required this.added, required this.duplicates});
}

/// Persistance de l'inventaire via shared_preferences.
///
/// Les donnees restent locales a l'appareil : elles survivent au redemarrage
/// de l'app, mais ne sont pas synchronisees entre le web et le mobile.
class InventoryStore {
  static const String _storageKey = 'inventory_v1';

  static Future<List<InventoryItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Donnees corrompues ou format d'une ancienne version : on repart a zero
      // plutot que de bloquer l'ecran.
      return [];
    }
  }

  static Future<void> _save(List<InventoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
  }

  /// Ajoute les skins obtenus, en ecartant ceux deja possedes.
  static Future<InventoryAddResult> addAll(List<InventoryItem> items) async {
    final current = await load();
    final owned = current.map((e) => e.uniqueId).toSet();

    final added = <InventoryItem>[];
    final duplicates = <InventoryItem>[];

    for (final item in items) {
      // `owned` est mis a jour au fur et a mesure pour attraper aussi les
      // doublons presents dans le meme tirage.
      if (owned.add(item.uniqueId)) {
        added.add(item);
      } else {
        duplicates.add(item);
      }
    }

    if (added.isNotEmpty) {
      await _save([...current, ...added]);
    }
    return InventoryAddResult(added: added, duplicates: duplicates);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
