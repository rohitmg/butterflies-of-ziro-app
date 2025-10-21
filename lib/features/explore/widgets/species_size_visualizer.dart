import 'package:flutter/material.dart';

class SpeciesSizeVisualizer extends StatelessWidget {
  final String sizeRange; // e.g., '90-110 mm'
  final Color primaryColor;
  final String imagePath = 'assets/images/size.png';
  
  // Base constant: Assumes 100 mm maps to a certain logical size (e.g., 100 dp)
  // This ratio is arbitrary but crucial for proportional scaling.
  static const double _BASE_MM = 100.0;
  static const double _BASE_SIZE_DP = 100.0;

  const SpeciesSizeVisualizer({
    super.key,
    required this.sizeRange,
    required this.primaryColor,
  });

  // Parses the input string ("90-110 mm") into min and max integer values.
  Map<String, int?> _parseSizes() {
    final regex = RegExp(r'(\d+)\s*-\s*(\d+)');
    final match = regex.firstMatch(sizeRange);

    if (match != null) {
      try {
        return {
          'min': int.parse(match.group(1)!),
          'max': int.parse(match.group(2)!),
        };
      } catch (_) {
        // Handle malformed numbers
      }
    }
    return {'min': null, 'max': null};
  }

  // Calculates the display size (in dp) based on the proportional ratio.
  double _calculateDisplaySize(int mm) {
    return (mm / _BASE_MM) * _BASE_SIZE_DP;
  }

  @override
  Widget build(BuildContext context) {
    final sizes = _parseSizes();
    final minSize = sizes['min'];
    final maxSize = sizes['max'];

    if (minSize == null || maxSize == null) {
      return Text('Size: $sizeRange', style: TextStyle(color: primaryColor));
    }

    final minDisplaySize = _calculateDisplaySize(minSize);
    final maxDisplaySize = _calculateDisplaySize(maxSize);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Interactive Butterfly Comparison (Stacked Images)
        SizedBox(
          width: maxDisplaySize + 40, // Ensure enough width for max size + padding
          height: maxDisplaySize + 60, // Ensure enough height for scale bars
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // --- MAX SIZE BUTTERFLY (Background/Outline) ---
              Positioned(
                top: 0,
                child: Container(
                  width: maxDisplaySize,
                  height: maxDisplaySize,
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryColor.withOpacity(0.5)),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Opacity(
                      opacity: 0.6,
                      child: Image.asset(
                        imagePath,
                        width: maxDisplaySize,
                        height: maxDisplaySize,
                        color: primaryColor.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),
              ),

              // --- MIN SIZE BUTTERFLY (Foreground) ---
              Positioned(
                top: (maxDisplaySize - minDisplaySize) / 2, // Center vertically
                child: Container(
                  width: minDisplaySize,
                  height: minDisplaySize,
                  child: Image.asset(
                    imagePath,
                    width: minDisplaySize,
                    height: minDisplaySize,
                    color: primaryColor,
                  ),
                ),
              ),

              // --- Scale Bar for MAX Size ---
              Positioned(
                bottom: 25,
                child: _buildScaleBar(
                  maxDisplaySize,
                  maxSize,
                  primaryColor.withOpacity(0.5),
                ),
              ),
              
              // --- Scale Bar for MIN Size ---
              Positioned(
                bottom: 0,
                child: _buildScaleBar(
                  minDisplaySize,
                  minSize,
                  primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Helper widget to display a scaled bar and label
  Widget _buildScaleBar(double displaySize, int actualSize, Color color) {
    return Column(
      children: [
        Container(
          width: displaySize,
          height: 2,
          color: color,
        ),
        const SizedBox(height: 2),
        Text(
          '${actualSize} mm',
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}