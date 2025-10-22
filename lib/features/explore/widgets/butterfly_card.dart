// lib/features/explore/widgets/butterfly_card.dart

import 'package:flutter/material.dart';
import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';
import 'package:butterflies_of_ziro/features/species_details/presentation/species_details_screen.dart';

class ButterflyCard extends StatelessWidget {
  final SpeciesModel species;
  final String? imageUrl;
  final int columnCount;

  const ButterflyCard({
    super.key,
    required this.species,
    this.imageUrl,
    required this.columnCount,
  });

  static final BorderRadius _cardBorderRadius = BorderRadius.circular(12.0);

  // --- NEW: Sizing Logic based on Column Count ---
  double _getFontSize(int columns) {
    if (columns == 1) return 24.0; // Large for single column
    if (columns == 2) return 16.0; // Standard size (was 18.0)
    if (columns == 3) return 10.0; // Small, but legible
    return 0.0; // Hide names for 4+ columns
  }

  @override
  Widget build(BuildContext context) {
    final cardBaseColor =
        butterflyFamilyMap[species.family]?.variants['lightest'] ?? Colors.grey;
    final textDarkColor =
        butterflyFamilyMap[species.family]?.variants['dark'] ?? Colors.black;

    final subtleBackgroundColor = cardBaseColor.withOpacity(0.10);
    final imageAsset = imageUrl != null ? AssetImage(imageUrl!) : null;
    final commonNameSize = _getFontSize(columnCount);

    // Condition to hide text entirely for 4+ columns
    final bool hideText = columnCount >= 4;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SpeciesDetailScreen(species: species),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: _cardBorderRadius,
          color: subtleBackgroundColor,
          border: Border.all(color: textDarkColor.withValues(alpha: 0.15), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. IMAGE AREA (Fixed Aspect Ratio to prevent overlap/scaling issues)
            ClipRRect(
              borderRadius: _cardBorderRadius,
              child: Container(
                // 1. THIS CONTAINER ACTS AS THE BORDER PADDING
                padding: const EdgeInsets.all(3.0), // The border thickness
                decoration: BoxDecoration(
                  color: cardBaseColor, // The color of the border
                  borderRadius: _cardBorderRadius,
                ),

                child: ClipRRect(
                  // 2. THIS CLIPRRECT CLIPS THE IMAGE INSIDE THE BORDER
                  borderRadius: _cardBorderRadius,
                  child: imageAsset != null
                      ? Image(
                          image: imageAsset,
                          // FIX: Use BoxFit.cover to ensure image fills the entire 3:2 area (edge-to-edge)
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.black38,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.black38,
                            size: 32,
                          ),
                        ),
                ),
              ),
            ),
            // 2. TEXT METADATA AREA (Conditional Height)
            if (!hideText)
              Padding(
                // FIX: Minimal vertical padding (top/bottom)
                padding: const EdgeInsets.fromLTRB(10.0, 6.0, 10.0, 6.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min, // Use minimum space required
                  children: [
                    // --- Common Name ---
                    Text(
                      species.commonName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textDarkColor,
                        fontWeight: FontWeight.w700,
                        fontSize: commonNameSize, // Fixed size
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // FIX: Minimal space between names
                    const SizedBox(height: 2.0),

                    // --- Scientific Name ---
                    Text(
                      species.scientificName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textDarkColor.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                        fontSize: commonNameSize * 0.75, // Fixed scaled size
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
