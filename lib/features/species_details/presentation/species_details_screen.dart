import 'package:flutter/material.dart';
import 'package:butterflies_of_ziro/data/models/species_model.dart';

class SpeciesDetailScreen extends StatelessWidget {
  final SpeciesModel species;

  const SpeciesDetailScreen({
    Key? key,
    required this.species,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(species.commonName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              species.scientificName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text('Family: ${species.family}'),
            Text('Subfamily: ${species.subfamily ?? 'N/A'}'),
            const SizedBox(height: 24),
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(species.description ?? 'No description available.'),
          ],
        ),
      ),
    );
  }
}