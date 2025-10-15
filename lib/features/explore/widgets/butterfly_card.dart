// lib/features/explore/widgets/butterfly_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';

class ButterflyCard extends StatelessWidget {
  final SpeciesModel species;
  final String? imageUrl;

  const ButterflyCard({
    Key? key,
    required this.species,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the color from the new utility class
    final cardColor = butterflyFamilyMap[species.family]?.variants['dull'] ??
        Colors.grey;
    final textColor = butterflyFamilyMap[species.family]?.variants['dark'] ??
        Colors.black;

    return Card(
      elevation: 4.0,
      color: cardColor.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4.0),
              ),
              child: imageUrl != null
                  ? Image.asset(
                      imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white70,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white70,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 2.0),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  species.commonName,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  species.scientificName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: textColor.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}