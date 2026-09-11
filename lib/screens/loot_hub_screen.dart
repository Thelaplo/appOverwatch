import 'package:flutter/material.dart';

import 'inventory_screen.dart';
import 'lootbox_screen.dart';

/// Regroupe les coffres et l'inventaire dans un meme onglet.
///
/// Ouvrir un coffre alimente directement l'inventaire : les deux vues sont
/// reliees par [_inventoryKey] pour que la grille se recharge sans que
/// l'utilisateur ait a rafraichir.
class LootHubScreen extends StatefulWidget {
  const LootHubScreen({super.key});

  @override
  State<LootHubScreen> createState() => _LootHubScreenState();
}

class _LootHubScreenState extends State<LootHubScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final GlobalKey<InventoryScreenState> _inventoryKey = GlobalKey<InventoryScreenState>();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF07090E),
      child: Column(
        children: [
          ColoredBox(
            color: const Color(0xFF04060A),
            child: TabBar(
              controller: _tabs,
              indicatorColor: const Color(0xFFF99E1A),
              labelColor: const Color(0xFFF99E1A),
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
              tabs: const [
                Tab(text: 'COFFRES', icon: Icon(Icons.token, size: 18)),
                Tab(text: 'INVENTAIRE', icon: Icon(Icons.inventory_2, size: 18)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                LootboxScreen(
                  // Si l'inventaire n'a pas encore ete affiche, son initState
                  // fera le chargement lui-meme.
                  onInventoryChanged: () => _inventoryKey.currentState?.reload(),
                ),
                InventoryScreen(key: _inventoryKey),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
