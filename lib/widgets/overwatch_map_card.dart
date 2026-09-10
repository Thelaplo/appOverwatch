import 'package:flutter/material.dart';
import '../models/map_item.dart';
import '../utils/image_helper.dart';

class OverwatchMapCard extends StatefulWidget {
  final MapItem map;

  const OverwatchMapCard({super.key, required this.map});

  @override
  State<OverwatchMapCard> createState() => _OverwatchMapCardState();
}

class _OverwatchMapCardState extends State<OverwatchMapCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: Container(
          margin: const EdgeInsets.only(bottom: 18),
          height: 155,
          decoration: BoxDecoration(
            color: const Color(0xFF141822),
            border: Border.all(
              color: _isHovered ? const Color(0xFFF99E1A) : Colors.white12,
              width: _isHovered ? 2.0 : 1.0,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFFF99E1A).withAlpha(120),
                      blurRadius: 18,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (widget.map.image != null && widget.map.image!.isNotEmpty)
                AnimatedScale(
                  scale: _isHovered ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 250),
                  child: Image.network(
                    buildImageUrl(widget.map.image!, width: 700),
                    fit: BoxFit.cover,
                    cacheWidth: 700,
                  ),
                ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: [0.0, 0.45, 0.8],
                    colors: [
                      Color(0xFA0A0D14),
                      Color(0xCC0A0D14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 6,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  color: _isHovered ? const Color(0xFFF99E1A) : Colors.transparent,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform(
                      transform: Matrix4.skewX(-0.18),
                      child: Text(
                        widget.map.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: _isHovered ? const Color(0xFFF99E1A) : Colors.white,
                          shadows: const [
                            Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: widget.map.gamemodes.map((mode) {
                        return Transform(
                          transform: Matrix4.skewX(-0.18),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B202D),
                              border: Border.all(
                                color: _isHovered ? const Color(0xFFF99E1A) : Colors.white24,
                              ),
                            ),
                            child: Text(
                              mode,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.0,
                                color: _isHovered ? Colors.white : const Color(0xFFF99E1A),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}