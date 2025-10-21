// lib/features/explore/widgets/butterfly_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';
import 'package:butterflies_of_ziro/features/species_details/presentation/species_details_screen.dart';

class ButterflyCard extends StatelessWidget {
  final SpeciesModel species;
  final String? imageUrl;

  const ButterflyCard({super.key, required this.species, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // 1. Get DULL color for background and DARK color for text
    final cardBaseColor =
        butterflyFamilyMap[species.family]?.variants['dark'] ?? Colors.grey;
    final textDarkColor =
        butterflyFamilyMap[species.family]?.variants['dark'] ?? Colors.black;

    // 2. Apply 15% opacity for subtle background tint
    final subtleBackgroundColor = cardBaseColor.withOpacity(0.05);

    // Check if the image is available
    final imageAsset = imageUrl != null ? AssetImage(imageUrl!) : null;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SpeciesDetailScreen(species: species),
          ),
        );
      },
      child: Card(
        elevation: 1.0, // Reduced elevation for a flatter look
        color: subtleBackgroundColor, // Apply subtle background color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: cardBaseColor.withOpacity(0.3),
            width: 1.0,
          ), // Subtle border
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8.0), // Rounded top corners
                ),
                child: Container(
                  padding: const EdgeInsets.all(
                    4.0,
                  ), // Small padding around the image area
                  child: imageAsset != null
                      ? Image(
                          image: imageAsset,
                          fit: BoxFit.contain, // Show full image
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color:
                                      Colors.black38, // Subtle error icon color
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
            const SizedBox(height: 2.0), // Minimal separation
            // --- Text Section (Minimal Padding) ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ), // Minimal padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    species.commonName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: textDarkColor, // Dark color for common name
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    species.scientificName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: textDarkColor.withOpacity(
                        0.7,
                      ), // Slightly lighter dark color
                      fontStyle: FontStyle.italic,
                      fontSize: 11, // Slightly smaller font size
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
