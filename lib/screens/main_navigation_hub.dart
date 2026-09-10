import 'package:flutter/material.dart';
import 'hero_catalog_screen.dart';
import 'maps_screen.dart';
import 'comps_screen.dart';
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

  final List<Widget> _screens = const [
    HeroCatalogScreen(),
    MapsScreen(),
    CompsScreen(),
    CareerTrackerScreen(),
    CinematicsScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = const [
    {'label': 'HÉROS', 'icon': Icons.people},
    {'label': 'CARTES', 'icon': Icons.map},
    {'label': 'COMPOS', 'icon': Icons.shield},
    {'label': 'CARRIÈRE', 'icon': Icons.bar_chart},
    {'label': 'CINÉMATIQUES', 'icon': Icons.movie},
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0C0F16),
      // Bouton burger flottant sur mobile
      floatingActionButton: isMobile
          ? FloatingActionButton.small(
              backgroundColor: const Color(0xFFF99E1A),
              foregroundColor: Colors.black,
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              child: const Icon(Icons.menu),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      // Menu burger style Battle.net
      drawer: isMobile ? _buildOverwatchDrawer() : null,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      // Barre basse compacte à 5 onglets
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: const Color(0xFF080A0F),
        selectedItemColor: const Color(0xFFF99E1A),
        unselectedItemColor: Colors.white38,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        items: _navItems.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item['icon'] as IconData),
            label: item['label'] as String,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOverwatchDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0F131C),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12, width: 1)),
              ),
              child: Transform(
                transform: Matrix4.skewX(-0.16),
                child: const Text(
                  'OVERWATCH HUB',
                  style: TextStyle(
                    color: Color(0xFFF99E1A),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _navItems.length,
                itemBuilder: (context, i) {
                  final active = _currentIndex == i;
                  return InkWell(
                    onTap: () {
                      setState(() => _currentIndex = i);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF1B202D) : Colors.transparent,
                        border: Border(
                          left: BorderSide(
                            color: active ? const Color(0xFFF99E1A) : Colors.transparent,
                            width: 4,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _navItems[i]['icon'] as IconData,
                            color: active ? const Color(0xFFF99E1A) : Colors.white60,
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          Transform(
                            transform: Matrix4.skewX(-0.16),
                            child: Text(
                              _navItems[i]['label'] as String,
                              style: TextStyle(
                                color: active ? const Color(0xFFF99E1A) : Colors.white70,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}