// lib/data/models/taxonomy_node.dart

import 'package:flutter/foundation.dart';

@immutable // This annotation signals that the class is immutable.
class TaxonomyNode {
  final String name;
  final String level;
  final List<TaxonomyNode> children;

  const TaxonomyNode({
    required this.name,
    required this.level,
    this.children = const [],
  });

  // A helper method to get the parent of a node.
  // This would be implemented in your tree builder logic, not the model itself.
}
