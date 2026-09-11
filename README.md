# Athena

Compagnon Overwatch 2 : héros, cartes, compositions, méta, coffres, skins,
répliques audio et cinématiques. Application Flutter fonctionnant sur
**Android** et sur le **web**.

> Projet personnel non officiel, sans lien avec Blizzard Entertainment.
> Toutes les données affichées proviennent de sources publiques.

---

## Démarrer

```bash
flutter pub get

flutter run -d chrome            # web, démarrage rapide (~30 s)
flutter run -d emulator-5554     # Android, plus lent (Gradle)
```

Depuis VS Code : `F5`. `Ctrl+S` déclenche le hot reload.

Prérequis : Flutter 3.47+, et pour Android le SDK avec le NDK réclamé par
`flutter.ndkVersion`.

### Régénérer l'icône

Le logo est dessiné par code, pas stocké comme image opaque :

```bash
dart run tool/generate_icon.dart   # produit les trois PNG
dart run flutter_launcher_icons    # décline les tailles Android
```

---

## Fonctionnalités

| Écran | Accès | Contenu |
|---|---|---|
| Héros | onglet | catalogue, fiche détaillée, capacités, contres |
| Cartes | onglet | cartes et modes de jeu |
| Compositions | onglet | compos méta + simulateur 5v5 avec analyse |
| Butin | onglet | coffres et inventaire persistant |
| Skins | onglet | vrais skins par héros |
| Boutique | onglet | collaborations officielles |
| Méta & tier list | menu | taux de victoire, sélection, bannissement |
| Profil joueur | menu | recherche par pseudo, rangs PC et console |
| Cinématiques | menu | courts-métrages lus dans l'app |
| Répliques audio | menu | vraies voix du jeu, ultimes en tête |
| Quiz / Je joue quoi ? | menu | deviner le héros, tirage au sort |

---

## Sources de données

Aucune clé d'API n'est nécessaire.

### OverFast API — `overfast-api.tekrop.fr`

Héros, cartes, points de vie, sous-rôles officiels, profils de joueurs, et
`/heroes/stats` pour la méta (taux de victoire, sélection, bannissement).

### Wiki Overwatch — API MediaWiki de Fandom

L'API OverFast n'expose **aucun** endpoint de cosmétiques, et les URLs de
skins qui étaient codées en dur renvoyaient 403. Le wiki, lui, expose ses
fichiers en accès libre :

- **Skins** : `<Héros>_Skin_<Nom>.png` — 52 des 53 héros couverts
- **Répliques** : `<Héros>_-_<Réplique>.ogg` — les vraies voix du jeu

Deux pièges à connaître si vous touchez à [`skin_api.dart`](lib/utils/skin_api.dart)
et [`voice_line_api.dart`](lib/utils/voice_line_api.dart) :

1. **Le nom wiki se déduit de la clé**, jamais du nom affiché : l'API renvoie
   les noms traduits (Mercy devient « Ange »). Quatre héros sont irréguliers :
   `dva → D.Va`, `soldier-76 → S76`, `lucio → Lúcio`, `torbjorn → Torbjörn`.
2. **L'ordre alphabétique piège les requêtes.** Les fichiers entre parenthèses
   passent avant les lettres : sans point de départ, les 100 premiers résultats
   de D.Va sont tous en coréen. Les répliques font donc deux passes — une pour
   attraper les vocalises de Jetpack Cat, une démarrant à la première lettre
   pour l'anglais.

### YouTube — chaînes officielles Blizzard

Cinématiques lues via le lecteur embarqué officiel. Onze en VF sur la chaîne
**Overwatch FR**, deux en VO sur **PlayOverwatch** faute de doublage publié.

Chaque identifiant a été vérifié via l'endpoint `oembed` de YouTube. **Ne les
devinez pas** : cinq des six premières tentatives pointaient sur des vidéos
inexistantes.

---

## Architecture

```
lib/
├── models/     données (héros, butin, inventaire, profil joueur)
├── screens/    un écran par sujet
├── utils/      accès réseau, analyse de compos, lecture audio
└── widgets/    composants réutilisables
```

### Multiplateforme

La vidéo de fond passe par des **conditional imports** : `<video>` HTML sur
web, `video_player` sur mobile.

```dart
export 'blizzard_background_video_native.dart'
    if (dart.library.js_interop) 'blizzard_background_video_web.dart';
```

Une garde `if (kIsWeb)` ne suffit pas : les `import 'dart:html'` sont résolus
à la compilation, avant que la moindre condition ne s'exécute. C'est ce qui
empêchait l'application de compiler pour Android.

L'audio, lui, n'a pas besoin de ce mécanisme : `audioplayers` fonctionne sur
les deux plateformes.

### Analyse de composition

[`comp_analyzer.dart`](lib/utils/comp_analyzer.dart) s'appuie sur les
**sous-rôles officiels** (`initiator`, `sharpshooter`, `medic`…) pour déduire
un style de jeu, et sur [`hero_traits.dart`](lib/utils/hero_traits.dart) pour
ce qu'ils ne disent pas : anti-soin, amplification de dégâts, protection,
réponse aérienne. Couper les soins et amplifier les dégâts résolvent le même
problème — l'avertissement ne se déclenche que si les deux manquent.

---

## Limites connues

- **Contres** : seuls 8 héros sur 53 sont documentés dans
  [`hero_matchups.dart`](lib/utils/hero_matchups.dart). La section disparaît
  pour les autres plutôt que d'afficher des généralités.
- **Ultimes** : 17 répliques identifiées, vérifiées une à une. Ni l'API ni le
  wiki ne les marquent — l'ordre des capacités de l'API est trompeur (elle
  désigne `Cyber-Agility` pour Genji) et les sections du wiki ne suivent pas
  d'ordre stable.
- **Répartition des rangs** : pas de graphique. Aucune source publique ne
  publie de distribution récente incluant Émeraude, ni séparée PC/console.
- **Rareté des coffres** : tirée indépendamment du skin, le wiki ne la
  fournissant pas.
- **Profils privés** : inaccessibles, c'est une limite du jeu.

---

## Dépannage

**Le daemon Gradle plante.** La heap est à 3 Go dans
`android/gradle.properties`. Elle était à 8 Go, ce qui faisait crasher le GC
sur une machine de 16 Go avec l'émulateur ouvert. Ne la remontez pas sans
raison.

**Erreur de NDK au build.** Le projet suit `flutter.ndkVersion`. Si la
version réclamée n'est plus téléchargeable, pointez `ndkVersion` sur un NDK
installé dans `android/app/build.gradle.kts`.

**Images ou audio absents.** Le wiki et l'API sont interrogés en direct. Tous
les appels retombent silencieusement sur un repli hors ligne ; aucun écran ne
reste bloqué sur un chargement infini.

---

## Tests

```bash
flutter test
flutter analyze
```

Le test de fumée vérifie que le hub expose ses six onglets. Il absorbe les
erreurs réseau : le binding de test fait échouer toute requête HTTP.
