// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Implementation web : bip synthetise via la Web Audio API + lecture de la
/// replique via speechSynthesis. Jamais compile sur mobile/desktop.
void playVoiceLine(String text, double freq) {
  try {
    js.context.callMethod('eval', [
      '''
      (function(text, freq) {
        try {
          var AudioCtx = window.AudioContext || window.webkitAudioContext;
          if (AudioCtx) {
            var ctx = new AudioCtx();
            ctx.resume().then(function() {
              var osc = ctx.createOscillator();
              var gain = ctx.createGain();
              osc.type = 'sawtooth';
              osc.frequency.setValueAtTime(freq, ctx.currentTime);
              osc.frequency.exponentialRampToValueAtTime(freq * 1.6, ctx.currentTime + 0.3);
              gain.gain.setValueAtTime(0.3, ctx.currentTime);
              gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.35);
              osc.connect(gain);
              gain.connect(ctx.destination);
              osc.start(0);
              osc.stop(ctx.currentTime + 0.35);
            });
          }
          // Prononce également la réplique officielle à voix haute
          if ('speechSynthesis' in window) {
            window.speechSynthesis.cancel();
            var msg = new SpeechSynthesisUtterance(text.replace(/[«»]/g, ''));
            msg.lang = 'fr-FR';
            msg.rate = 1.05;
            window.speechSynthesis.speak(msg);
          }
        } catch(e) {}
      })('${text.replaceAll("'", "\\'")}', $freq)
      '''
    ]);
  } catch (_) {}
}
