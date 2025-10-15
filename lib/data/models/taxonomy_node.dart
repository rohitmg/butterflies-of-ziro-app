// lib/data/models/taxonomy_node.dart

class TaxonomyNode {
  final String name;
  final String level; // e.g. 'Family', 'Subfamily', 'Genus'
  final List<TaxonomyNode> children;
  TaxonomyNode? parent; // optional, assigned after construction

  TaxonomyNode({
    required this.name,
    required this.level,
    this.children = const [],
  }) {
    // Assign parent reference to children automatically
    for (final child in children) {
      child.parent = this;
    }
  }
}
