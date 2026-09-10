import 'package:flutter/material.dart';
import '../utils/image_helper.dart';

class ShopCollabScreen extends StatelessWidget {
  const ShopCollabScreen({super.key});

  final List<Map<String, String>> _collabs = const [
    {
      'title': 'OVERWATCH 2 × LE SSERAFIM',
      'hero': 'D.VA, KIRIKO, TRACER, BRIGITTE, SOMBRA',
      'tag': 'PERFECT NIGHT • ÉVÉNEMENT SPÉCIAL',
      'img': 'https://images.blz-contentstack.com/v3/assets/blt9c12f249ac15c7ec/bltb3e0545f44c7b8e1/653ff9d107a6be33605c30fb/LE_SSERAFIM_OW2_Header.jpg',
    },
    {
      'title': 'OVERWATCH 2 × PORSCHE',
      'hero': 'D.VA PORSCHE MACAN TURBO & PHARAH TAYCAN',
      'tag': 'COLLABORATION ÉLITE',
      'img': 'https://images.blz-contentstack.com/v3/assets/blt9c12f249ac15c7ec/blt01b1b3699b646c26/663d27bc991a0c810d8a571f/Porsche_Announcement_ArticleHeader_2000x1125_KP01.jpg',
    },
    {
      'title': 'OVERWATCH 2 × COWBOY BEBOP',
      'hero': 'CASSIDY SPIKE SPIEGEL & ASHE FAYE VALENTINE',
      'tag': 'LÉGENDAIRE ANIME',
      'img': 'https://images.blz-contentstack.com/v3/assets/blt9c12f249ac15c7ec/blt226ad287959b3ba8/65ee11f77d3f82087ba2df4b/CB_Announce_ArticleHeader_2000x1125_MB01.jpg',
    },
    {
      'title': 'OVERWATCH 2 × TRANSFORMERS',
      'hero': 'REINHARDT OPTIMUS PRIME & BASTION BUMBLEBEE',
      'tag': 'MECHA SHOWDOWN',
      'img': 'https://images.blz-contentstack.com/v3/assets/blt9c12f249ac15c7ec/blteeb39ebca03f4439/668ec009f449a03b5735b5a0/Transformers_Announcement_ArticleHeader_2000x1125_MB01.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF090D15),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'BOUTIQUE DES COLLABORATIONS',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.5),
          ),
          const SizedBox(height: 4),
          const Text(
            'Modèles exclusifs, célébrations musicales et partenariats mondiaux.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 18),
          ..._collabs.map((c) => _buildCollabCard(c)),
        ],
      ),
    );
  }

  Widget _buildCollabCard(Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF141926),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFF99E1A).withAlpha(140), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(90), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 190,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  buildImageUrl(item['img']!, width: 700),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF1B2233),
                    child: const Center(child: Icon(Icons.shopping_bag, size: 48, color: Color(0xFFF99E1A))),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xF2141926)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  color: const Color(0xFFF99E1A),
                  child: Text(
                    item['tag']!,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 9),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['title']!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(item['hero']!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}