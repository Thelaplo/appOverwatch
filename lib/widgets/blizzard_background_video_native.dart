import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Implementation mobile/desktop : la video de fond passe par le plugin
/// video_player. Tant que la video n'est pas prete (ou si elle echoue),
/// on affiche le meme fond uni que la version web.
class BlizzardBackgroundVideo extends StatefulWidget {
  final String videoUrl;
  const BlizzardBackgroundVideo({super.key, required this.videoUrl});

  @override
  State<BlizzardBackgroundVideo> createState() => _BlizzardBackgroundVideoState();
}

class _BlizzardBackgroundVideoState extends State<BlizzardBackgroundVideo> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _setupVideo();
  }

  void _setupVideo() {
    final url = widget.videoUrl;
    if (url.isEmpty || !url.startsWith('http')) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;

    controller.initialize().then((_) {
      // Le widget a pu etre demonte ou repointe sur une autre video
      // pendant le chargement reseau.
      if (!mounted || _controller != controller) {
        controller.dispose();
        return;
      }
      controller
        ..setLooping(true)
        ..setVolume(0)
        ..play();
      setState(() {});
    }).catchError((Object _) {
      if (_controller == controller) {
        _controller = null;
      }
      controller.dispose();
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant BlizzardBackgroundVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _setupVideo();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return Container(color: const Color(0xFF0F1523));
    }
    // Equivalent du `object-fit: cover` de la version web.
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
