import 'package:flutter/material.dart';

import '../models/inventory.dart';
import '../models/loot_drop.dart';
import '../utils/image_helper.dart';

/// Inventaire des skins obtenus dans les coffres.
///
/// L'ecran se recharge a chaque affichage via [InventoryScreenController]
/// pour refleter les tirages faits entre-temps dans l'onglet Butin.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => InventoryScreenState();
}

class InventoryScreenState extends State<InventoryScreen> {
  List<InventoryItem>? _items;
  String _filter = 'TOUS';

  @override
  void initState() {
    super.initState();
    reload();
  }

  /// Appele aussi depuis le hub de navigation quand on revient sur l'onglet.
  Future<void> reload() async {
    final items = await InventoryStore.load();
    if (!mounted) return;
    setState(() {
      // Les derniers obtenus en premier.
      _items = items.reversed.toList();
    });
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141926),
        title: const Text('VIDER L\'INVENTAIRE ?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        content: const Text(
          'Tous les skins obtenus seront definitivement perdus.',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULER', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('VIDER', style: TextStyle(color: Color(0xFFFF5252), fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await InventoryStore.clear();
      await reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;

    if (items == null) {
      return const ColoredBox(
        color: Color(0xFF090D15),
        child: Center(child: CircularProgressIndicator(color: Color(0xFFF99E1A))),
      );
    }

    final filtered = _filter == 'TOUS'
        ? items
        : items.where((i) => i.rarity.label == _filter).toList();

    return ColoredBox(
      color: const Color(0xFF090D15),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'INVENTAIRE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5),
                    ),
                  ),
                  if (items.isNotEmpty)
                    IconButton(
                      tooltip: 'Vider l\'inventaire',
                      onPressed: _confirmClear,
                      icon: const Icon(Icons.delete_outline, color: Colors.white38),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                items.isEmpty
                    ? 'Aucun skin pour le moment. Ouvre un coffre dans l\'onglet BUTIN.'
                    : '${items.length} skin${items.length > 1 ? 's' : ''} obtenu${items.length > 1 ? 's' : ''}.',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 14),
              SizedBox(
                height: 32,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    'TOUS',
                    ...LootRarity.values.map((r) => r.label),
                  ].map(_buildFilterChip).toList(),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Expanded(
              child: items.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      color: const Color(0xFFF99E1A),
                      backgroundColor: const Color(0xFF141926),
                      onRefresh: reload,
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 180,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _buildSkinCard(filtered[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final active = _filter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFF99E1A) : const Color(0xFF141926),
            border: Border.all(color: active ? const Color(0xFFF99E1A) : Colors.white24),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: const [
        SizedBox(height: 60),
        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white12),
        SizedBox(height: 16),
        Center(
          child: Text(
            'INVENTAIRE VIDE',
            style: TextStyle(
                color: Colors.white24,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildSkinCard(InventoryItem item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF10141D),
        border: Border.all(color: item.rarity.color, width: 2),
        boxShadow: [
          BoxShadow(color: item.rarity.color.withAlpha(70), blurRadius: 12, spreadRadius: 1),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3),
            color: item.rarity.color,
            child: Text(
              item.rarity.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w900, fontSize: 9, letterSpacing: 1),
            ),
          ),
          Expanded(
            child: item.portrait.isEmpty
                ? const ColoredBox(
                    color: Color(0xFF1B2233),
                    child: Center(child: Icon(Icons.person, color: Colors.white24, size: 36)),
                  )
                : Image.network(
                    buildImageUrl(item.portrait, width: 220),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFF1B2233),
                      child: Center(child: Icon(Icons.person, color: Colors.white24, size: 36)),
                    ),
                  ),
          ),
          Container(
            width: double.infinity,
            color: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            child: Column(
              children: [
                Text(
                  item.heroName.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 11, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Text(
                  item.skinName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, color: item.rarity.color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
