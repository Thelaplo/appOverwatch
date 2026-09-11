import 'package:audioplayers/audioplayers.dart';

/// Joue les extraits audio officiels des heros.
///
/// Contrairement a [playVoiceLine] (dans voice_player.dart), qui synthetise
/// une voix faute de mieux, ce lecteur diffuse le vrai fichier du jeu.
/// audioplayers fonctionne aussi bien sur Android que sur le web, aucun
/// conditional import n'est donc necessaire ici.
class VoiceClipPlayer {
  static final AudioPlayer _player = AudioPlayer();

  /// Lance la lecture et indique si elle a pu demarrer.
  static Future<bool> play(String url) async {
    try {
      await _player.stop();
      await _player.play(UrlSource(url));
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
  }
}
