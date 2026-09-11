import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Implementation web : la video de fond est une balise <video> HTML native,
/// inseree dans l'arbre Flutter via une platform view.
/// Ce fichier n'est jamais compile sur mobile/desktop (voir la facade
/// blizzard_background_video.dart).
class BlizzardBackgroundVideo extends StatefulWidget {
  final String videoUrl;
  const BlizzardBackgroundVideo({super.key, required this.videoUrl});

  @override
  State<BlizzardBackgroundVideo> createState() => _BlizzardBackgroundVideoState();
}

class _BlizzardBackgroundVideoState extends State<BlizzardBackgroundVideo> {
  late String _viewId;
  html.VideoElement? _videoElement;

  @override
  void initState() {
    super.initState();
    _viewId = 'video-${widget.videoUrl.hashCode}';
    _setupVideo();
  }

  void _setupVideo() {
    _videoElement = html.VideoElement()
      ..autoplay = true
      ..loop = true
      ..muted = true
      ..setAttribute('playsinline', 'true')
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    if (widget.videoUrl.isNotEmpty && widget.videoUrl.startsWith('http')) {
      _videoElement!.src = widget.videoUrl;
    }

    ui_web.platformViewRegistry.registerViewFactory(
      _viewId,
      (int id) => _videoElement!,
    );
  }

  @override
  void didUpdateWidget(covariant BlizzardBackgroundVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl && _videoElement != null) {
      if (widget.videoUrl.isNotEmpty && widget.videoUrl.startsWith('http')) {
        _videoElement!.src = widget.videoUrl;
        _videoElement!.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videoUrl.isEmpty) {
      return Container(color: const Color(0xFF0F1523));
    }
    return HtmlElementView(viewType: _viewId);
  }
}
