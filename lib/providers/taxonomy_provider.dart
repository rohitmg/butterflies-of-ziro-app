// lib/providers/taxonomy_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:butterflies_of_ziro/data/models/species_model.dart';
import 'package:butterflies_of_ziro/data/models/taxonomy_node.dart';
import 'package:butterflies_of_ziro/providers/explore_provider.dart';

final taxonomyProvider = Provider<TaxonomyNode>((ref) {
  final speciesList = ref.watch(exploreProvider).speciesList;
  return buildTaxonomyTree(speciesList);
});

TaxonomyNode buildTaxonomyTree(List<SpeciesModel> speciesList) {
  final root = TaxonomyNode(
    name: 'Papilionoidea',
    level: 'Superfamily',
    children: [],
  );

  for (final species in speciesList) {
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
    }

    // Tribe Level
    if (species.tribe != null) {
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
    }

    // Genus Level
    if (species.genus != null) {
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
