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
  @override
  void initState() {
    super.initState();
    // Use `addPostFrameCallback` to trigger loading after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exploreProvider.notifier).loadSpecies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final exploreState = ref.watch(exploreProvider);

    if (exploreState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // ... (rest of the build method)
    return Scaffold(
      appBar: AppBar(title: const Text('Butterflies of Ziro')),
      body: ListView.builder(
        itemCount: exploreState.speciesList.length,
        itemBuilder: (context, index) {
          final species = exploreState.speciesList[index];
          return ListTile(
            title: Text(species.commonName),
            subtitle: Text(species.scientificName),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SpeciesDetailScreen(species: species),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
