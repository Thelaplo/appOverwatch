import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Implementation mobile/desktop.
///
/// Le web synthetisait le bip avec un oscillateur Web Audio et lisait la
/// replique avec speechSynthesis. Ici on reproduit les deux :
///  - le bip est genere a la main sous forme de WAV PCM joue par audioplayers
///  - la replique passe par flutter_tts (le TTS natif du systeme)

const int _sampleRate = 44100;
const double _durationSec = 0.35;
const double _glideSec = 0.30; // duree de la montee de freq -> freq * 1.6
const double _gainStart = 0.3;
const double _gainEnd = 0.01;

final AudioPlayer _player = AudioPlayer();
final FlutterTts _tts = FlutterTts();

void playVoiceLine(String text, double freq) {
  _playBeep(freq);
  _speak(text);
}

Future<void> _playBeep(double freq) async {
  try {
    await _player.stop();
    await _player.play(BytesSource(_buildSawtoothWav(freq)));
  } catch (_) {
    // Pas de son disponible : on laisse la replique TTS se jouer quand meme.
  }
}

Future<void> _speak(String text) async {
  try {
    await _tts.setLanguage('fr-FR');
    // flutter_tts normalise le debit differemment du web : 0.5 correspond
    // a la vitesse « normale » sur Android.
    await _tts.setSpeechRate(0.5);
    await _tts.stop();
    await _tts.speak(text.replaceAll(RegExp(r'[«»]'), '').trim());
  } catch (_) {}
}

/// Construit un WAV PCM 16 bits mono contenant une dent de scie dont la
/// frequence glisse de [freq] a `freq * 1.6`, avec un decay exponentiel.
Uint8List _buildSawtoothWav(double freq) {
  final sampleCount = (_sampleRate * _durationSec).round();
  final samples = Int16List(sampleCount);

  double phase = 0;
  for (var i = 0; i < sampleCount; i++) {
    final t = i / _sampleRate;

    // Montee exponentielle de la frequence, figee apres _glideSec.
    final glide = math.min(t / _glideSec, 1.0);
    final currentFreq = freq * math.pow(1.6, glide);

    phase = (phase + currentFreq / _sampleRate) % 1.0;
    final saw = 2 * phase - 1; // dent de scie dans [-1, 1]

    final envelope = _gainStart * math.pow(_gainEnd / _gainStart, t / _durationSec);
    samples[i] = (saw * envelope * 32767).round().clamp(-32768, 32767);
  }

  return _wrapAsWav(samples);
}

Uint8List _wrapAsWav(Int16List samples) {
  const headerSize = 44;
  final dataSize = samples.length * 2;
  final bytes = Uint8List(headerSize + dataSize);
  final view = ByteData.view(bytes.buffer);

  void writeAscii(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      bytes[offset + i] = value.codeUnitAt(i);
    }
  }

  writeAscii(0, 'RIFF');
  view.setUint32(4, 36 + dataSize, Endian.little); // taille du fichier - 8
  writeAscii(8, 'WAVE');

  writeAscii(12, 'fmt ');
  view.setUint32(16, 16, Endian.little); // taille du bloc fmt
  view.setUint16(20, 1, Endian.little); // format PCM
  view.setUint16(22, 1, Endian.little); // mono
  view.setUint32(24, _sampleRate, Endian.little);
  view.setUint32(28, _sampleRate * 2, Endian.little); // byte rate
  view.setUint16(32, 2, Endian.little); // block align
  view.setUint16(34, 16, Endian.little); // bits par echantillon

  writeAscii(36, 'data');
  view.setUint32(40, dataSize, Endian.little);

  for (var i = 0; i < samples.length; i++) {
    view.setInt16(headerSize + i * 2, samples[i], Endian.little);
  }

  return bytes;
}
