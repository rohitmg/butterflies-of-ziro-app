// lib/features/explore/presentation/explore_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/painting.dart';

import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/providers/explore_provider.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';
import 'package:butterflies_of_ziro/features/species_details/presentation/species_details_screen.dart';
import 'package:butterflies_of_ziro/providers/filter_provider.dart';
import 'package:butterflies_of_ziro/providers/filter_state.dart';
import 'package:butterflies_of_ziro/providers/taxonomy_provider.dart';

import 'package:butterflies_of_ziro/features/explore/widgets/butterfly_card.dart';
import 'package:butterflies_of_ziro/features/explore/widgets/butterfly_list_tile.dart';
import 'package:butterflies_of_ziro/features/explore/widgets/taxonomy_tree_selector.dart';
import 'package:butterflies_of_ziro/features/explore/widgets/filter_dialog.dart';
import 'package:butterflies_of_ziro/core/constants.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  ViewType _currentView = ViewType.grid; // Use the enum for state

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(exploreProvider.notifier).loadSpecies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredSpeciesAsync = ref.watch(filteredSpeciesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Butterflies of Ziro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              // Now you can simply call the new function
              showFilterDialog(
                context: context,
                ref: ref,
                currentViewType: _currentView, // Pass the enum
                onViewChanged: (newViewType) {
                  // Receive the enum
                  setState(() {
                    _currentView = newViewType;
                  });
                },
              );
            },
          ),
        ],
      ),
      body: filteredSpeciesAsync.when(
        data: (speciesList) {
          switch (_currentView) {
            // Use a switch for cleaner logic
            case ViewType.grid:
              return _buildGridView(speciesList);
            case ViewType.list:
              return _buildListView(speciesList);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildGridView(List<SpeciesModel> speciesList) {
    // ... (Existing GridView code) ...
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      padding: const EdgeInsets.all(8.0),
      itemCount: speciesList.length,
      itemBuilder: (context, index) {
        final species = speciesList[index];
        final imageUrl = species.images.isNotEmpty
            ? 'assets/images/butterflies/${species.images.first}'
            : null;
        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SpeciesDetailScreen(species: species),
              ),
            );
          },
          child: ButterflyCard(species: species, imageUrl: imageUrl),
        );
      },
    );
  }

  Widget _buildListView(List<SpeciesModel> speciesList) {
    // ... (Existing ListView code) ...
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: speciesList.length,
      itemBuilder: (context, index) {
        final species = speciesList[index];
        return ButterflyListTile(species: species);
      },
    );
  }
}
