// lib/features/explore/widgets/taxonomy_tree_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterflies_of_ziro/providers/filter_state.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';
import 'package:butterflies_of_ziro/data/models/taxonomy_node.dart';

final _selectedNodeNameNotifier = ValueNotifier<String?>('Papilionoidea');

class TaxonomyTreeSelector extends ConsumerStatefulWidget {
  final TaxonomyNode currentNode;
  final FilterState localFilters;
  final Function(FilterState) onFiltersUpdated;
  final int level;
  final Color baseColor;
  final ValueNotifier<String?> selectedNodeNameNotifier;

  const TaxonomyTreeSelector({
    super.key,
    required this.currentNode,
    required this.localFilters,
    required this.onFiltersUpdated,
    this.level = 0,
    required this.baseColor,
    required this.selectedNodeNameNotifier,
  });

  @override
  ConsumerState<TaxonomyTreeSelector> createState() =>
      _TaxonomyTreeSelectorState();
}

class _TaxonomyTreeSelectorState extends ConsumerState<TaxonomyTreeSelector> {
  final Set<String> _expandedNodes = {};

  @override
  void initState() {
    super.initState();
  }

  void _initializeExpansion() {
    _expandedNodes.clear();

    // Ensure we start from the currently selected node (deepest filter)
    TaxonomyNode? node = _findSelectedNode(widget.currentNode);

    if (node == null) return;

    final Map<String, String> selectedFilters = {};

    while (node != null) {
      _expandedNodes.add(node.name);

      if (['Family', 'Subfamily', 'Tribe', 'Genus'].contains(node.level)) {
        selectedFilters[node.level] = node.name;
      }

      node = node.parent;
    }

    debugPrint('Selected filters: $selectedFilters');

    setState(() {});
  }

  TaxonomyNode? _findSelectedNode(TaxonomyNode root) {
    if (root.name == widget.selectedNodeNameNotifier.value) return root;
    for (final child in root.children) {
      final found = _findSelectedNode(child);
      if (found != null) return found;
    }
    return null;
  }

  void _selectNode(TaxonomyNode? node) {
    if (node == null) return;

    final ancestry = _getAncestry(node);

    // Construct new filter state
    FilterState newFilters = widget.localFilters;
    for (final ancestor in ancestry) {
      switch (ancestor.level) {
        case 'Family':
          newFilters = newFilters.copyWith(
            family: ancestor.name,
            subfamily: null,
            tribe: null,
            genus: null,
          );
          break;
        case 'Subfamily':
          newFilters = newFilters.copyWith(
            subfamily: ancestor.name,
            tribe: null,
            genus: null,
            family: ancestor.parent?.name ?? newFilters.family,
          );
          break;
        case 'Tribe':
          newFilters = newFilters.copyWith(
            tribe: ancestor.name,
            genus: null,
            subfamily: ancestor.parent?.name ?? newFilters.subfamily,
            family: ancestor.parent?.parent?.name ?? newFilters.family,
          );
          break;
        case 'Genus':
          newFilters = newFilters.copyWith(
            genus: ancestor.name,
            tribe: ancestor.parent?.name ?? newFilters.tribe,
            subfamily: ancestor.parent?.parent?.name ?? newFilters.subfamily,
            family: ancestor.parent?.parent?.parent?.name ?? newFilters.family,
          );
          break;
        default:
          break;
      }
    }

    widget.onFiltersUpdated(newFilters);
    widget.selectedNodeNameNotifier.value = node.name;
  }

  List<TaxonomyNode> _getAncestry(TaxonomyNode node) {
    final List<TaxonomyNode> ancestry = [];
    TaxonomyNode? current = node;
    while (current != null) {
      ancestry.insert(0, current); // insert at start
      current = current.parent;
    }
    return ancestry;
  }

  void _toggleExpansion(String nodeName) {
    setState(() {
      if (_expandedNodes.contains(nodeName)) {
        _expandedNodes.remove(nodeName);
      } else {
        _expandedNodes.add(nodeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentNode.children.isEmpty && widget.level > 0) {
      return const SizedBox.shrink();
    }

    _initializeExpansion();

    final familyName = widget.localFilters.family;
    final textColor = familyName != null
        ? butterflyFamilyMap[familyName]?.base ?? Colors.black
        : Colors.black;

    final nodeWidgets = <Widget>[];

    // ROOT NODE
    if (widget.level == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNodeTile(
            context,
            TaxonomyNode(
              name: 'Papilionoidea',
              level: 'Root',
              children: widget.currentNode.children,
            ),
            Colors.black,
            hasChildren: true,
            onTap: (node) => _selectNode(null),
            onExpand: widget.currentNode.children.isNotEmpty
                ? () => _toggleExpansion('Papilionoidea')
                : null,
          ),
          if (_expandedNodes.contains('Papilionoidea'))
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.currentNode.children.map((node) {
                  final familyColor =
                      butterflyFamilyMap[node.name]?.base ?? Colors.black;
                  return TaxonomyTreeSelector(
                    currentNode: node,
                    localFilters: widget.localFilters,
                    onFiltersUpdated: widget.onFiltersUpdated,
                    level: 1,
                    baseColor: familyColor,
                    selectedNodeNameNotifier: widget.selectedNodeNameNotifier,
                  );
                }).toList(),
              ),
            ),
        ],
      );
    }

    // RECURSIVE CHILDREN
    final children = widget.currentNode.children;
    final isExpanded = _expandedNodes.contains(widget.currentNode.name);

    nodeWidgets.add(
      _buildNodeTile(
        context,
        widget.currentNode,
        widget.baseColor,
        onTap: _selectNode,
        onExpand: children.isNotEmpty
            ? () => _toggleExpansion(widget.currentNode.name)
            : null,
        hasChildren: children.isNotEmpty,
      ),
    );

    if (children.isNotEmpty && isExpanded) {
      nodeWidgets.add(
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children.map((node) {
              return TaxonomyTreeSelector(
                currentNode: node,
                localFilters: widget.localFilters,
                onFiltersUpdated: widget.onFiltersUpdated,
                level: widget.level + 1,
                baseColor: widget.baseColor,
                selectedNodeNameNotifier: widget.selectedNodeNameNotifier,
              );
            }).toList(),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: nodeWidgets,
    );
  }

  Widget _buildNodeTile(
    BuildContext context,
    TaxonomyNode node,
    Color textColor, {
    required Function(TaxonomyNode) onTap,
    required Function()? onExpand,
    required bool hasChildren,
  }) {
    final isSelected = node.name == widget.selectedNodeNameNotifier.value;
    final isExpanded = _expandedNodes.contains(node.name);

    return InkWell(
      onTap: () => onTap(node),
      child: Container(
        color: isSelected ? textColor.withOpacity(0.15) : null,
        padding: EdgeInsets.only(left: 16.0 * widget.level),
        child: Row(
          children: [
            if (onExpand != null)
              IconButton(
                icon: Icon(
                  isExpanded ? Icons.remove : Icons.add,
                  color: Colors.grey,
                ),
                onPressed: onExpand,
              )
            else
              const SizedBox(width: 48, height: 48),
            Expanded(
              child: Text(
                node.name,
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;
  final int level;
  final int numChildren;

  const DottedLinePainter({
    required this.color,
    required this.level,
    required this.numChildren,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 3;
    const double dashSpace = 3;
    const double horizontalStubLength = 10;
    const double verticalLineX = 10.0;
    const double rowHeight = 48.0;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(verticalLineX, startY),
        Offset(verticalLineX, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }

    final numChildrenInView = (size.height / rowHeight).floor();
    for (int i = 0; i < numChildrenInView; i++) {
      double horizontalY = (i * rowHeight) + (rowHeight / 2.0);
      canvas.drawLine(
        Offset(verticalLineX, horizontalY),
        Offset(verticalLineX + horizontalStubLength, horizontalY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DottedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.level != level ||
        oldDelegate.numChildren != numChildren;
  }
}
