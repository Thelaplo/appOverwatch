import 'package:flutter/foundation.dart';

String buildImageUrl(String originalUrl, {int? width}) {
  if (originalUrl.isEmpty) return '';
  if (kIsWeb) {
    final cleanUrl = originalUrl.replaceFirst(RegExp(r'^https?:\/\/'), '');
    final resizeParam = width != null ? '&w=$width&q=80&output=webp' : '&q=85&output=webp';
    return 'https://images.weserv.nl/?url=$cleanUrl$resizeParam';
  }
  return originalUrl;
}
