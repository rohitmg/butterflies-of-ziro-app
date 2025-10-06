import 'package:flutter/material.dart';

/// A helper to store and generate color variants for each butterfly family.
class ButterflyFamilyColors {
  final String family;
  final Color base;

  ButterflyFamilyColors(this.family, this.base);

  /// Returns a map of generated variants.
  Map<String, Color> get variants => {
    "base": base,
    "vibrant": _adjustColor(base, saturation: 0.15),
    "dull": _adjustColor(base, saturation: -0.2, lightness: 0.1),
    "light": _adjustColor(base, lightness: 0.25),
    "dark": _adjustColor(base, lightness: -0.25),
  };

  /// Color adjustment helper similar to HSL-based Vue logic.
  Color _adjustColor(
    Color color, {
    double saturation = 0,
    double lightness = 0,
  }) {
    final hsl = HSLColor.fromColor(color);
    final adjusted = hsl
        .withSaturation((hsl.saturation + saturation).clamp(0.0, 1.0))
        .withLightness((hsl.lightness + lightness).clamp(0.0, 1.0));
    return adjusted.toColor();
  }
}

/// Define your butterfly color families here.
final List<ButterflyFamilyColors> butterflyFamilies = [
  ButterflyFamilyColors("Nymphalidae", const Color(0xFF9B59B6)),
  ButterflyFamilyColors("Lycaenidae", const Color(0xFF3498DB)),
  ButterflyFamilyColors("Pieridae", const Color(0xFFF1C40F)),
  ButterflyFamilyColors("Papilionidae", const Color(0xFF27AE60)),
  ButterflyFamilyColors("Hesperiidae", const Color(0xFFE67E22)),
  ButterflyFamilyColors("Riodinidae", const Color(0xFFC0392B)),
];

/// Optional: Build a lookup map for convenience
final Map<String, ButterflyFamilyColors> butterflyFamilyMap = {
  for (var f in butterflyFamilies) f.family: f,
};

/// Example usage:
///
/// ```dart
/// final nymphalidae = butterflyFamilyMap["Nymphalidae"];
/// final vibrantColor = nymphalidae?.variants["vibrant"];
/// ```
///
/// You can then use these in your Flutter UI widgets:
/// ```dart
/// Container(
///   color: vibrantColor,
///   child: Text("Nymphalidae"),
/// )
/// ```
