import 'package:flutter/material.dart';
import '../widgets/blizzard_app_bar.dart';
import '../widgets/blizzard_drawer.dart';
import 'hero_catalog_screen.dart';
import 'maps_screen.dart';
import 'comps_screen.dart';
import 'loot_hub_screen.dart';
import 'skins_gallery_screen.dart';
import 'shop_collab_screen.dart';
import 'voice_lines_screen.dart';
import 'meta_screen.dart';
import 'voice_quiz_screen.dart';
import 'random_pick_screen.dart';
import 'cinematics_screen.dart';
import 'career_tracker_screen.dart';

class MainNavigationHub extends StatefulWidget {
  const MainNavigationHub({super.key});

  @override
  State<MainNavigationHub> createState() => _MainNavigationHubState();
}

class _MainNavigationHubState extends State<MainNavigationHub> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // L'ordre doit rester aligne sur les items de la barre du bas et sur les
  // index utilises par BlizzardDrawer.
  final List<Widget> _screens = const [
    HeroCatalogScreen(),
    MapsScreen(),
    CompsScreen(),
    LootHubScreen(),
    SkinsGalleryScreen(),
    ShopCollabScreen(),
  ];

  /// Ces ecrans s'ouvrent en page a part plutot que dans la pile d'onglets :
  /// la barre du bas est pleine, et un index sans onglet correspondant ferait
  /// echouer BottomNavigationBar.
  void _openPage(DrawerPage page) {
    final (title, body) = switch (page) {
      DrawerPage.voiceLines => ('RÉPLIQUES AUDIO', const VoiceLinesScreen()),
      DrawerPage.meta => ('MÉTA & TIER LIST', const MetaScreen()),
      DrawerPage.quiz => ('QUIZ DES RÉPLIQUES', const VoiceQuizScreen()),
      DrawerPage.randomPick => ('JE JOUE QUOI ?', const RandomPickScreen()),
      DrawerPage.cinematics => ('CINÉMATIQUES', const CinematicsScreen()),
      DrawerPage.career => ('PROFIL JOUEUR', const CareerTrackerScreen()),
    };

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFF090D15),
          appBar: AppBar(
            backgroundColor: const Color(0xFF04060A),
            elevation: 0,
            title: Transform(
              transform: Matrix4.skewX(-0.16),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2, fontSize: 16),
              ),
            ),
          ),
          body: body,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: BlizzardAppBar(onMenuTap: () => _scaffoldKey.currentState?.openDrawer()),
      drawer: BlizzardDrawer(
        onNavigate: (index) => setState(() => _currentIndex = index),
        onOpenPage: _openPage,
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: const Color(0xFF090D15),
        selectedItemColor: const Color(0xFFF99E1A),
        unselectedItemColor: Colors.white38,
        selectedFontSize: 9,
        unselectedFontSize: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'HÉROS'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'CARTES'),
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'COMPOS'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'BUTIN'),
          BottomNavigationBarItem(icon: Icon(Icons.style), label: 'SKINS'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'BOUTIQUE'),
        ],
      ),
    );
  }
}
