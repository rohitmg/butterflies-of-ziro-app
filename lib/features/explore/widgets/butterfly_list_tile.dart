// lib/features/explore/widgets/butterfly_list_tile.dart

import 'package:flutter/material.dart';
import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';
import 'package:butterflies_of_ziro/features/species_details/presentation/species_details_screen.dart';

class ButterflyListTile extends StatelessWidget {
  final SpeciesModel species;
  final List<SpeciesModel> speciesList; // NEW: Full list
  final int index; // NEW: Current index

  const ButterflyListTile({
    Key? key,
    required this.species,
    required this.speciesList, // Required
    required this.index, // Required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = species.images.isNotEmpty
        ? 'assets/images/butterflies/${species.images.first}'
        : null;

    final cardColor =
        butterflyFamilyMap[species.family]?.variants['dull'] ?? Colors.grey;
    final textColor =
        butterflyFamilyMap[species.family]?.variants['dark'] ?? Colors.black;

    return InkWell(
      onTap: () {
        // UPDATED: Pass the full list and the starting index
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SpeciesDetailScreen(
              speciesList: speciesList,
              initialIndex: index,
            ),
          ),
        );
      },
      child: Card(
        color: cardColor,
        child: ListTile(
          leading: imageUrl != null
              ? Image.asset(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
              : const SizedBox(width: 50, height: 50),
          title: Text(
            species.commonName,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: textColor),
          ),
          subtitle: Text(
            species.scientificName,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: textColor.withOpacity(0.7)),
          ),
        ),
      ),
    );
  }
}