import 'package:flutter/material.dart';
import '../widgets/blizzard_app_bar.dart';
import '../widgets/blizzard_drawer.dart';
import 'hero_catalog_screen.dart';
import 'maps_screen.dart';
import 'comps_screen.dart';
import 'lootbox_screen.dart';
import 'skins_gallery_screen.dart';

class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _screens = const [
    HeroCatalogScreen(),
    MapsScreen(),
    CompsScreen(),
    LootboxScreen(),
    SkinsGalleryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: BlizzardAppBar(onMenuTap: () => _scaffoldKey.currentState?.openDrawer()),
      drawer: BlizzardDrawer(onNavigate: (index) => setState(() => _currentIndex = index)),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: const Color(0xFF090D15),
        selectedItemColor: const Color(0xFFF99E1A),
        unselectedItemColor: Colors.white38,
        selectedFontSize: 10,
        unselectedFontSize: 9,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'HÉROS'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'CARTES'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'COMPOS'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'BUTIN'),
          BottomNavigationBarItem(icon: Icon(Icons.style), label: 'SKINS'),
        ],
      ),
    );
  }
}