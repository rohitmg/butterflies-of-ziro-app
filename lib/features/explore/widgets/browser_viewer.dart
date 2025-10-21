// lib/features/explore/widgets/browser_viewer.dart

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart'; // Ensure this is accessible

// --- MAIN WIDGET ---

class BrowserImageViewer extends StatefulWidget {
  final SpeciesModel species;
  final TransformationController transformationController;
  final bool isZoomed;
  final VoidCallback onResetZoom;

  const BrowserImageViewer({
    super.key,
    required this.species,
    required this.transformationController,
    required this.isZoomed,
    required this.onResetZoom,
  });

  @override
  State<BrowserImageViewer> createState() => _BrowserImageViewerState();
}

class _BrowserImageViewerState extends State<BrowserImageViewer> {
  final GlobalKey _imageViewKey = GlobalKey();
  Size? _imageWidgetSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_imageViewKey.currentContext != null) {
        final RenderBox renderBox =
            _imageViewKey.currentContext!.findRenderObject() as RenderBox;
        setState(() {
          _imageWidgetSize = renderBox.size;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.species.images.isNotEmpty
        ? 'assets/images/butterflies/${widget.species.images.first}'
        : null;

    // Minimap dimensions based on 3:2 aspect ratio
    const double minimapWidth = 100.0;
    const double minimapHeight = minimapWidth / 1.5;

    return Stack(
      children: [
        // --- 1. Main Interactive Image Viewer ---
        AspectRatio(
          aspectRatio: 3 / 2,
          child: InteractiveViewer(
            key: _imageViewKey,
            transformationController: widget.transformationController,
            maxScale: 5.0,
            minScale: 1.0,
            constrained: true,
            boundaryMargin: EdgeInsets.zero, // Pan restriction applied here
            child: imageUrl != null
                ? Image.asset(imageUrl, fit: BoxFit.cover)
                : const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
          ),
        ),

        // --- 2. Minimap (Context Viewer and Reset Button) ---
        if (widget.isZoomed)
          Positioned(
            top: 10,
            left: 10,
            child: InkWell(
              onTap: widget.onResetZoom, // Tapping Minimap resets zoom
              child: Opacity(
                opacity: 0.8,
                child: Container(
                  width: minimapWidth,
                  height: minimapHeight,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    border: Border.all(color: Colors.white, width: 1.0),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Stack(
                      children: [
                        // Minimap Background (Always shows full context)
                        SizedBox.expand(
                          child: imageUrl != null
                              ? Image.asset(imageUrl, fit: BoxFit.cover)
                              : const SizedBox.expand(),
                        ),

                        // Highlight Box - CustomPainter (No interaction here)
                        CustomPaint(
                          size: Size.infinite,
                          painter: MinimapHighlightPainter(
                            transformationController:
                                widget.transformationController,
                            imageWidgetSize: _imageWidgetSize,
                            species: widget.species,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// --- CUSTOM PAINTER FOR MINIMAP HIGHLIGHT ---
class MinimapHighlightPainter extends CustomPainter {
  final TransformationController transformationController;
  final Size? imageWidgetSize;
  final SpeciesModel species; // New: Pass the species model for coloring

  MinimapHighlightPainter({
    required this.transformationController,
    required this.imageWidgetSize,
    required this.species, // New: Required
  }) : super(repaint: transformationController);

  // Helper to get the family color
  Color _getHighlightColor() {
    return butterflyFamilyMap[species.family]?.base ?? Colors.blueGrey;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (imageWidgetSize == null ||
        transformationController.value.getMaxScaleOnAxis() <= 1.0) {
      return;
    }

    final Matrix4 matrix = transformationController.value;
    final double currentScale = matrix.getMaxScaleOnAxis();

    // 1. Calculate Minimap Scaling Factors (Minimap Size / Image Widget Size)
    final double minimapScaleX = size.width / imageWidgetSize!.width;
    final double minimapScaleY = size.height / imageWidgetSize!.height;

    // 2. Calculate the position of the highlight box based on the main image's translation (pan)
    // The translation vector (x, y) tells us how far the image has been shifted.
    final double translateX = matrix.getTranslation().x;
    final double translateY = matrix.getTranslation().y;

    // 3. Calculate the size of the highlight box (Viewport size / current zoom level)
    final double highlightWidth =
        (imageWidgetSize!.width / currentScale) * minimapScaleX;
    final double highlightHeight =
        (imageWidgetSize!.height / currentScale) * minimapScaleY;

    // 4. Calculate the top-left corner of the highlight box on the minimap
    final double drawLeft = -translateX * minimapScaleX / currentScale;
    final double drawTop = -translateY * minimapScaleY / currentScale;

    // The rect represents where the viewer's screen *is* on the minimap image
    final Rect highlightRect = Rect.fromLTWH(
      drawLeft,
      drawTop,
      highlightWidth,
      highlightHeight,
    );

    // 5. Clamping and Edge Case Handling (Ensures the box stays on the minimap)
    // We only draw the part of the box that is within the minimap bounds (size.width/size.height)
    final Rect boundedHighlightRect = Rect.fromLTWH(
      highlightRect.left.clamp(0.0, size.width),
      highlightRect.top.clamp(0.0, size.height),
      highlightRect.width.clamp(
        0.0,
        size.width -
            highlightRect.left.clamp(0.0, size.width - highlightRect.width),
      ),
      highlightRect.height.clamp(
        0.0,
        size.height -
            highlightRect.top.clamp(0.0, size.height - highlightRect.height),
      ),
    );

    // 6. Drawing with Dynamic Color
    final Color familyColor = _getHighlightColor();

    final Paint paint = Paint()
      ..color = familyColor.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = familyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(boundedHighlightRect, paint);
    canvas.drawRect(boundedHighlightRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant MinimapHighlightPainter oldDelegate) {
    return oldDelegate.transformationController.value !=
            transformationController.value ||
        oldDelegate.imageWidgetSize != imageWidgetSize ||
        oldDelegate.species.family != species.family;
  }
}
