import 'package:flutter/material.dart';
import 'screens/main_navigation_hub.dart';

void main() {
  runApp(const OverwatchApp());
}

class OverwatchApp extends StatelessWidget {
  const OverwatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Overwatch Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF14171E),
        primaryColor: const Color(0xFFF99E1A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF99E1A),
          secondary: Color(0xFF405275),
          surface: Color(0xFF1F232D),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF11141A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: Colors.white,
          ),
        ),
      ),
      home: const MainNavigationHub(),
    );
  }
}