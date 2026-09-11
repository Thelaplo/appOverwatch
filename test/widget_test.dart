// Test de fumee : verifie que l'application demarre et que le hub de
// navigation expose bien tous ses onglets.
//
// Les ecrans appellent l'API OverFast dans leur initState ; en test le reseau
// est indisponible, mais chaque appel est protege, donc l'arbre se construit
// quand meme. On utilise pump() et non pumpAndSettle() pour ne pas attendre
// ces requetes.

import 'package:flutter_test/flutter_test.dart';

import 'package:overwatch_hub/main.dart';

void main() {
  testWidgets('Le hub affiche les six onglets de navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const OverwatchApp());
    await tester.pump();

    expect(find.text('HÉROS'), findsOneWidget);
    expect(find.text('CARTES'), findsOneWidget);
    expect(find.text('COMPOS'), findsOneWidget);
    expect(find.text('BUTIN'), findsOneWidget);
    expect(find.text('SKINS'), findsOneWidget);
    expect(find.text('BOUTIQUE'), findsOneWidget);
  });
}
