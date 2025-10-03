// lib/features/explore/presentation/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterflies_of_ziro/providers/explore_provider.dart';
import 'package:butterflies_of_ziro/features/species_details/presentation/species_details_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  // Your color data array
  final List<Map<String, dynamic>> _colorData = const [
    {
      "family": "Nymphalidae",
      "color": "#9c51b6",
      "alternatives": ["#9c51b6", "#b579d6", "#833ab4", "#d8b6e5"],
    },
    {
      "family": "Lycaenidae",
      "color": "#4e54c8",
      "alternatives": ["#4e54c8", "#5f63d6", "#3f44b5", "#6f73e0"],
    },
    {
      "family": "Pieridae",
      "color": "#ffdd44",
      "alternatives": ["#ffdd44", "#ffe770", "#ffd21a", "#ffeb8e"],
    },
    {
      "family": "Papilionidae",
      "color": "#2e8b57",
      "alternatives": ["#2e8b57", "#3cb371", "#228b22", "#66cdaa"],
    },
    {
      "family": "Hesperiidae",
      "color": "#ff9500",
      "alternatives": ["#ff9500", "#ffaa33", "#e68600", "#ffc266"],
    },
    {
      "family": "Riodinidae",
      "color": "#c41e3a",
      "alternatives": ["#c41e3a", "#dc4460", "#a50e2a", "#e57a8a"],
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exploreProvider.notifier).loadSpecies();
    });
  }

  // Helper function to convert a hex string to a Color object
  Color _hexToColor(String hexString) {
    return Color(int.parse(hexString.replaceAll('#', '0xFF')));
  }

  // Helper function to find the color for a given family
  Color _getColorForFamily(String family) {
    final familyColor = _colorData.firstWhere(
      (data) => data['family'] == family,
      orElse: () => {"color": "#CCCCCC"}, // Default color if not found
    );
    return _hexToColor(familyColor['color']);
  }

  @override
  Widget build(BuildContext context) {
    final exploreState = ref.watch(exploreProvider);

    if (exploreState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Butterflies of Ziro')),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        padding: const EdgeInsets.all(8.0),
        itemCount: exploreState.speciesList.length,
        itemBuilder: (context, index) {
          final species = exploreState.speciesList[index];
          final imageUrl = species.images.isNotEmpty
              ? 'assets/images/butterflies/${species.images.first}'
              : null;

          final cardColor = _getColorForFamily(species.family);

          return Card(
            elevation: 4.0,
            color: cardColor, // Apply the color here
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SpeciesDetailScreen(species: species),
                  ),
                );
              },
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
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(child: Icon(Icons.broken_image)),
                            )
                          : const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          species.commonName,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          species.scientificName,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.white70),
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
        },
      ),
    );
  }
}
