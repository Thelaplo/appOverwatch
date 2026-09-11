import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/hero.dart';
import '../utils/image_helper.dart';
import '../utils/voice_clip_player.dart';
import '../utils/voice_line_api.dart';

/// Quiz : une replique est jouee, il faut reconnaitre le heros parmi quatre.
///
/// Reutilise le catalogue de repliques du wiki : les extraits sont les vraies
/// voix du jeu, donc l'oreille sert autant que la lecture du texte.
class VoiceQuizScreen extends StatefulWidget {
  const VoiceQuizScreen({super.key});

  @override
  State<VoiceQuizScreen> createState() => _VoiceQuizScreenState();
}

class _VoiceQuizScreenState extends State<VoiceQuizScreen> {
  static const _accent = Color(0xFFF99E1A);

  /// Heros dont on sait que le wiki fournit des repliques anglaises.
  static const List<String> _pool = [
    'ana', 'ashe', 'baptiste', 'bastion', 'brigitte', 'cassidy', 'dva',
    'doomfist', 'echo', 'genji', 'hanzo', 'junkrat', 'junker-queen', 'kiriko',
    'lucio', 'mauga', 'mei', 'mercy', 'moira', 'orisa', 'pharah', 'ramattra',
    'reaper', 'reinhardt', 'roadhog', 'sigma', 'sombra', 'symmetra',
    'torbjorn', 'tracer', 'widowmaker', 'winston', 'zarya', 'zenyatta',
  ];

  final Random _random = Random();

  Map<String, HeroSummary> _heroes = {};
  WikiVoiceLine? _line;
  String? _answerKey;
  List<String> _choices = [];
  String? _picked;
  bool _loading = true;

  int _score = 0;
  int _asked = 0;
  int _streak = 0;
  int _bestStreak = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    VoiceClipPlayer.stop();
    super.dispose();
  }

  Future<void> _start() async {
    try {
      final res = await http.get(
        Uri.parse('https://overfast-api.tekrop.fr/heroes?locale=fr-fr'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
        _heroes = {
          for (final j in data)
            (j as Map<String, dynamic>)['key'] as String: HeroSummary.fromJson(j),
        };
      }
    } catch (_) {
      // Sans les portraits le quiz n'a pas d'interet : on affichera l'erreur.
    }
    await _nextQuestion();
  }

  Future<void> _nextQuestion() async {
    setState(() {
      _loading = true;
      _picked = null;
      _line = null;
    });

    // Certains heros peuvent n'avoir aucune replique exploitable : on
    // reessaie avec un autre plutot que de bloquer le quiz.
    for (var attempt = 0; attempt < 5; attempt++) {
      final key = _pool[_random.nextInt(_pool.length)];
      final hero = _heroes[key];
      if (hero == null) continue;

      final lines = await VoiceLineApi.fetchVoiceLines(key, hero.name.toUpperCase());
      final usable = lines.where((l) => l.text.length > 3).toList();
      if (usable.isEmpty) continue;

      final line = usable[_random.nextInt(usable.length)];

      final others = [..._pool]
        ..remove(key)
        ..shuffle(_random);
      final choices = [key, ...others.take(3)]..shuffle(_random);

      if (!mounted) return;
      setState(() {
        _line = line;
        _answerKey = key;
        _choices = choices;
        _loading = false;
      });

      await VoiceClipPlayer.play(line.audioUrl);
      return;
    }

    if (mounted) setState(() => _loading = false);
  }

  void _pick(String key) {
    if (_picked != null) return;

    setState(() {
      _picked = key;
      _asked++;
      if (key == _answerKey) {
        _score++;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
      } else {
        _streak = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF090D15),
      child: SafeArea(
        child: Column(
          children: [
            _scoreBar(),
            Expanded(child: _content()),
          ],
        ),
      ),
    );
  }

  Widget _scoreBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF141926),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _counter('SCORE', '$_score / $_asked'),
          _counter('SÉRIE', '$_streak'),
          _counter('RECORD', '$_bestStreak'),
        ],
      ),
    );
  }

  Widget _counter(String label, String value) => Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: _accent, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      );

  Widget _content() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }

    final line = _line;
    if (line == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Impossible de charger une réplique.\nVérifie ta connexion.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _nextQuestion,
                child: const Text('RÉESSAYER', style: TextStyle(color: _accent, fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'QUI PARLE ?',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
        const SizedBox(height: 14),
        GestureDetector(
          onTap: () => VoiceClipPlayer.play(line.audioUrl),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF141926),
              border: Border.all(color: _accent.withAlpha(120)),
            ),
            child: Row(
              children: [
                const Icon(Icons.replay, color: _accent, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '« ${line.text} »',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Touche la réplique pour la réécouter.',
          style: TextStyle(color: Colors.white24, fontSize: 11),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.95,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: _choices.map(_choiceCard).toList(),
        ),
        const SizedBox(height: 16),
        if (_picked != null)
          SizedBox(
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: Colors.black,
                shape: const BeveledRectangleBorder(),
              ),
              onPressed: _nextQuestion,
              child: const Text(
                'RÉPLIQUE SUIVANTE',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _choiceCard(String key) {
    final hero = _heroes[key];
    final isAnswer = key == _answerKey;
    final isPicked = key == _picked;

    Color border = Colors.white24;
    if (_picked != null) {
      if (isAnswer) {
        border = const Color(0xFF00E676);
      } else if (isPicked) {
        border = const Color(0xFFFF5252);
      }
    }

    return GestureDetector(
      onTap: () => _pick(key),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF141926),
          border: Border.all(color: border, width: border == Colors.white24 ? 1 : 3),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: hero == null
                  ? const ColoredBox(color: Color(0xFF1B2233))
                  : Image.network(
                      buildImageUrl(hero.portrait, width: 200),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Color(0xFF1B2233),
                        child: Icon(Icons.person, color: Colors.white24),
                      ),
                    ),
            ),
            Container(
              width: double.infinity,
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Text(
                (hero?.name ?? key).toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
