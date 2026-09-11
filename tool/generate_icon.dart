// Genere l'icone de l'application : la chouette d'Athena.
//
// Athena, l'IA d'Overwatch, n'a aucune representation visuelle dans le jeu
// (elle n'existe que par la voix). Le logo puise donc dans la mythologie :
// la chouette d'Athena, symbole de sagesse et de connaissance, qui a le bon
// gout d'etre dans le domaine public.
//
// Lancer avec : dart run tool/generate_icon.dart

import 'dart:io';

import 'package:image/image.dart' as img;

const int size = 1024;

// Palette de l'application.
final orange = img.ColorRgb8(249, 158, 26); // 0xFFF99E1A
final nightTop = img.ColorRgb8(26, 36, 56); // haut du degrade
final nightBottom = img.ColorRgb8(9, 13, 21); // 0xFF090D15

void main() {
  // Icone complete, fond compris.
  final icon = img.Image(width: size, height: size);
  _paintBackground(icon);
  _paintOwl(icon);
  _write('assets/icon/athena.png', icon);

  // Calque avant de l'icone adaptative Android : fond transparent, et
  // chouette reduite pour rester dans la zone sure (Android rogne les bords
  // selon la forme choisie par le constructeur).
  final foreground = img.Image(width: size, height: size, numChannels: 4);
  img.fill(foreground, color: img.ColorRgba8(0, 0, 0, 0));

  // Les decoupes (yeux, bec, plumage) restent dans le bleu nuit de l'app :
  // il sert aussi de fond a l'icone adaptative, donc elles se fondent dedans.
  final owl = img.Image(width: size, height: size, numChannels: 4);
  img.fill(owl, color: img.ColorRgba8(0, 0, 0, 0));
  _paintOwl(owl);

  // Marque seule, sur fond transparent : utilisee dans la barre de titre.
  final mark = img.copyCrop(owl, x: 290, y: 150, width: 444, height: 752);
  _write('assets/icon/athena_mark.png', mark);

  // On redimensionne la chouette DECOUPEE, pas le canvas entier : sinon elle
  // se retrouve minuscule au centre de l'icone. Sa hauteur occupe la zone
  // sure, qu'Android rogne selon la forme choisie par le constructeur.
  const safe = 0.66;
  final targetHeight = (size * safe).round();
  final scaled = img.copyResize(
    mark,
    height: targetHeight,
    width: (mark.width * targetHeight / mark.height).round(),
    interpolation: img.Interpolation.cubic,
  );
  img.compositeImage(
    foreground,
    scaled,
    dstX: ((size - scaled.width) / 2).round(),
    dstY: ((size - scaled.height) / 2).round(),
  );
  _write('assets/icon/athena_foreground.png', foreground);
}

void _write(String path, img.Image image) {
  final out = File(path);
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync(img.encodePng(image));
  stdout.writeln('Ecrit : $path (${image.width}x${image.height})');
}

/// Fond degrade vertical, du bleu nuit vers le presque noir de l'app.
void _paintBackground(img.Image image) {
  for (var y = 0; y < size; y++) {
    final t = y / (size - 1);
    final color = img.ColorRgb8(
      _lerp(nightTop.r.toInt(), nightBottom.r.toInt(), t),
      _lerp(nightTop.g.toInt(), nightBottom.g.toInt(), t),
      _lerp(nightTop.b.toInt(), nightBottom.b.toInt(), t),
    );
    img.drawLine(image, x1: 0, y1: y, x2: size - 1, y2: y, color: color);
  }
}

void _paintOwl(img.Image image) {
  const cx = size ~/ 2;

  // --- Aigrettes (les « oreilles ») ---
  img.fillPolygon(
    image,
    vertices: [
      img.Point(cx - 178, 352),
      img.Point(cx - 140, 168),
      img.Point(cx - 44, 300),
    ],
    color: orange,
  );
  img.fillPolygon(
    image,
    vertices: [
      img.Point(cx + 178, 352),
      img.Point(cx + 140, 168),
      img.Point(cx + 44, 300),
    ],
    color: orange,
  );

  // --- Tete ---
  img.fillCircle(image, x: cx, y: 430, radius: 212, color: orange);

  // --- Corps : un trapeze prolonge par un arrondi en bas ---
  img.fillPolygon(
    image,
    vertices: [
      img.Point(cx - 208, 430),
      img.Point(cx + 208, 430),
      img.Point(cx + 170, 700),
      img.Point(cx - 170, 700),
    ],
    color: orange,
  );
  img.fillCircle(image, x: cx, y: 700, radius: 170, color: orange);

  // --- Yeux : anneaux epais, tres lisibles en petite taille ---
  for (final eyeX in [cx - 92, cx + 92]) {
    img.fillCircle(image, x: eyeX, y: 424, radius: 84, color: nightBottom);
    img.fillCircle(image, x: eyeX, y: 424, radius: 36, color: orange);
  }

  // --- Bec ---
  img.fillPolygon(
    image,
    vertices: [
      img.Point(cx - 34, 470),
      img.Point(cx + 34, 470),
      img.Point(cx, 536),
    ],
    color: nightBottom,
  );

  // --- Plumage : trois chevrons sur le ventre ---
  for (var i = 0; i < 3; i++) {
    final y = 620 + i * 62;
    _chevron(image, cx, y, 104 - i * 18);
  }

  // --- Serres ---
  for (final footX in [cx - 62, cx + 62]) {
    img.fillPolygon(
      image,
      vertices: [
        img.Point(footX - 30, 852),
        img.Point(footX + 30, 852),
        img.Point(footX + 20, 892),
        img.Point(footX - 20, 892),
      ],
      color: orange,
    );
  }
}

/// Un chevron pointant vers le bas, evoquant le plumage.
void _chevron(img.Image image, int cx, int y, int halfWidth) {
  const thickness = 16;
  img.fillPolygon(
    image,
    vertices: [
      img.Point(cx - halfWidth, y),
      img.Point(cx, y + halfWidth * 0.52),
      img.Point(cx + halfWidth, y),
      img.Point(cx + halfWidth, y + thickness),
      img.Point(cx, y + halfWidth * 0.52 + thickness),
      img.Point(cx - halfWidth, y + thickness),
    ],
    color: nightBottom,
  );
}

int _lerp(int a, int b, double t) => (a + (b - a) * t).round().clamp(0, 255);

