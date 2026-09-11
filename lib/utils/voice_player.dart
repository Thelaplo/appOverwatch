/// Facade multiplateforme pour la lecture des repliques de heros.
///
/// Expose `playVoiceLine(text, freq)`. L'implementation est choisie a la
/// COMPILATION : Web Audio + speechSynthesis sur web, audioplayers +
/// flutter_tts partout ailleurs.
library;

export 'voice_player_native.dart'
    if (dart.library.js_interop) 'voice_player_web.dart';
