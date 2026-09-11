/// Facade multiplateforme pour la video de fond.
///
/// Dart choisit l'implementation a la COMPILATION : sur web on prend la
/// version <video> HTML, partout ailleurs la version video_player.
/// Une simple garde `if (kIsWeb)` ne suffirait pas : les `import 'dart:html'`
/// sont resolus avant l'execution et feraient echouer le build Android.
library;

export 'blizzard_background_video_native.dart'
    if (dart.library.js_interop) 'blizzard_background_video_web.dart';
