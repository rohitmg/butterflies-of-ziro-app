// lib/providers/taxonomy_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/data/models/taxonomy_node.dart';
import 'package:butterflies_of_ziro/providers/explore_provider.dart';

final taxonomyProvider = Provider<TaxonomyNode>((ref) {
  final speciesList = ref.watch(exploreProvider).speciesList;
  // If Superfamily is a fixed root, you might create it here
  return buildTaxonomyTree(speciesList);
});

TaxonomyNode buildTaxonomyTree(List<SpeciesModel> speciesList) {
  // Let's assume Superfamily is always 'Papilionoidea' as per your comment
  // and we make it the explicit root for the filter UI
  final root = TaxonomyNode(
    name: 'Papilionoidea',
    level: 'Superfamily',
    children: [],
  );

  for (final species in speciesList) {
    // We already have the Superfamily root, so we start from there
    TaxonomyNode currentParent = root;

    // Family Level
    var familyNode = currentParent.children.firstWhereOrNull(
      (node) => node.name == species.family,
    );
    if (familyNode == null) {
      familyNode = TaxonomyNode(
        name: species.family,
        level: 'Family',
        children: [],
      );
      currentParent.children.add(familyNode);
    }
    currentParent = familyNode;

    // Subfamily Level
    if (species.subfamily != null) {
      var subfamilyNode = currentParent.children.firstWhereOrNull(
        (node) => node.name == species.subfamily,
      );
      if (subfamilyNode == null) {
        subfamilyNode = TaxonomyNode(
          name: species.subfamily!,
          level: 'Subfamily',
          children: [],
        );
        currentParent.children.add(subfamilyNode);
      }
      currentParent = subfamilyNode;
    } else {
      // If no subfamily, the next level's parent is the family node itself
      // This is crucial for correctly linking lower levels when a level is skipped
      // In this specific UI, if a level is skipped, the user won't see it as an expand/collapse option
      // but the filter state still needs to be correctly managed for the filter logic.
    }

    // Tribe Level
    if (species.tribe != null) {
      // Find within currentParent's children
      var tribeNode = currentParent.children.firstWhereOrNull(
        (node) => node.name == species.tribe,
      );
      if (tribeNode == null) {
        tribeNode = TaxonomyNode(
          name: species.tribe!,
          level: 'Tribe',
          children: [],
        );
        currentParent.children.add(tribeNode);
      }
      currentParent = tribeNode;
    } else {
      // Skip tribe if null, currentParent remains the same
    }

    // Genus Level
    if (species.genus != null) {
      // Find within currentParent's children
      var genusNode = currentParent.children.firstWhereOrNull(
        (node) => node.name == species.genus,
      );
      if (genusNode == null) {
        genusNode = TaxonomyNode(
          name: species.genus!,
          level: 'Genus',
          children: [],
        );
        currentParent.children.add(genusNode);
      }
      // Genus is typically the lowest level we're building to for filtering
    }
  }

  // Sort the children alphabetically
  void sortChildren(TaxonomyNode node) {
    node.children.sort((a, b) => a.name.compareTo(b.name));
    for (var child in node.children) {
      sortChildren(child);
    }
  }

  sortChildren(root);

  return root;
}
