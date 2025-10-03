import 'package:flutter/material.dart';
import 'package:butterflies_of_ziro/data/models/species_model.dart';

class SpeciesDetailScreen extends StatelessWidget {
  final SpeciesModel species;

  const SpeciesDetailScreen({Key? key, required this.species})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final imageUrl = 'assets/images/butterflies/${species.images.first}';

    return Scaffold(
      appBar: AppBar(title: Text(species.commonName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the main image at the top
            Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox(), // Handle missing images gracefully
            ),
            const SizedBox(height: 16),
            Text(
              species.scientificName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            // ... (rest of the text fields)
          ],
        ),
      ),
    );
  }
}
