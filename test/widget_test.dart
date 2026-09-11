// Test de fumee : verifie que l'application demarre et que le hub de
// navigation expose bien tous ses onglets.

import 'package:flutter_test/flutter_test.dart';

import 'package:overwatch_hub/main.dart';

void main() {
  testWidgets('Le hub affiche les six onglets de navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const OverwatchApp());

    // Les ecrans interrogent l'API OverFast et le wiki dans leur initState.
    // En test, le binding fait echouer toute requete HTTP (code 400) et
    // certains ecrans relaient l'echec ; ces erreurs reseau sont attendues
    // et sans rapport avec la structure de navigation verifiee ici.
    await tester.pump(const Duration(seconds: 1));
    while (tester.takeException() != null) {}

    expect(find.text('HÉROS'), findsOneWidget);
    expect(find.text('CARTES'), findsOneWidget);
    expect(find.text('COMPOS'), findsOneWidget);
    expect(find.text('BUTIN'), findsOneWidget);
    expect(find.text('SKINS'), findsOneWidget);
    expect(find.text('BOUTIQUE'), findsOneWidget);
  });
}
