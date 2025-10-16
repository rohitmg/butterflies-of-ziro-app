// lib/features/explore/widgets/taxonomy_tree_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:butterflies_of_ziro/data/models/taxonomy_node.dart';
import 'package:butterflies_of_ziro/providers/filter_state.dart';
import 'package:butterflies_of_ziro/core/app_colors.dart';

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
    // This part should handle the initial expansion
    _initializeExpansion();
  }

  void _initializeExpansion() {
    _expandedNodes.clear();
    List<String> path = [];
    if (widget.localFilters.family != null) {
      path.add(widget.localFilters.family!);
      if (widget.localFilters.subfamily != null) {
        path.add(widget.localFilters.subfamily!);
        if (widget.localFilters.tribe != null) {
          path.add(widget.localFilters.tribe!);
          if (widget.localFilters.genus != null) {
            path.add(widget.localFilters.genus!);
          }
        }
      }
    }
    setState(() {
      for (String nodeName in path) {
        _expandedNodes.add(nodeName);
      }
    });
  }

  void _selectNode(TaxonomyNode? node) {
    FilterState newFilters = widget.localFilters;
    String? nodeName = node?.name;

    if (node == null || node.level == 'Root') {
      newFilters = const FilterState();
      nodeName = 'Papilionoidea';
    } else {
      newFilters = newFilters.copyWith(
        family: null,
        subfamily: null,
        tribe: null,
        genus: null,
      );

      switch (node.level) {
        case 'Family':
          newFilters = newFilters.copyWith(family: node.name);
          break;
        case 'Subfamily':
          newFilters = newFilters.copyWith(subfamily: node.name);
          break;
        case 'Tribe':
          newFilters = newFilters.copyWith(tribe: node.name);
          break;
        case 'Genus':
          newFilters = newFilters.copyWith(genus: node.name);
          break;
      }
    }

    widget.onFiltersUpdated(newFilters);
    widget.selectedNodeNameNotifier.value = nodeName;
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

    final nodeWidgets = <Widget>[];

    if (widget.level == 0) {
      nodeWidgets.add(
        _buildNodeTile(
          context,
          TaxonomyNode(
            name: 'Papilionoidea',
            level: 'Root',
            children: widget.currentNode.children,
          ),
          Colors.black,
          onTap: (node) {
            _selectNode(null);
          },
          onExpand: widget.currentNode.children.isNotEmpty
              ? () => _toggleExpansion('Papilionoidea')
              : null,
          hasChildren: widget.currentNode.children.isNotEmpty,
          verticalOffset: 0.0, // No vertical offset for root
        ),
      );

      if (_expandedNodes.contains('Papilionoidea')) {
        final children = widget.currentNode.children;
        nodeWidgets.add(
          CustomPaint(
            painter: DottedLinePainter(
              color: Colors.black.withOpacity(0.5),
              numChildren: children.length,
              verticalLineOffset: 24.0, // Adjusted offset
              horizontalStubOffset: 12.0, // Adjusted offset
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children.map((node) {
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
          ),
        );
      }
    } else {
      final children = widget.currentNode.children;
      final isExpanded = _expandedNodes.contains(widget.currentNode.name);

      nodeWidgets.add(
        _buildNodeTile(
          context,
          widget.currentNode,
          widget.baseColor,
          onTap: (selectedNode) {
            if (widget.selectedNodeNameNotifier.value == selectedNode.name) {
              _selectNode(null);
            } else {
              _selectNode(selectedNode);
            }
          },
          onExpand: children.isNotEmpty
              ? () => _toggleExpansion(widget.currentNode.name)
              : null,
          hasChildren: children.isNotEmpty,
          verticalOffset: 0.0, // No vertical offset for children
        ),
      );

      if (children.isNotEmpty && isExpanded) {
        nodeWidgets.add(
          CustomPaint(
            painter: DottedLinePainter(
              color: widget.baseColor.withOpacity(0.5),
              numChildren: children.length,
              verticalLineOffset: 24.0, // Adjusted offset
              horizontalStubOffset: 12.0, // Adjusted offset
            ),
            child: Padding(
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
          ),
        );
      }
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
    double verticalOffset = 0.0,
  }) {
    final isSelected = node.name == widget.selectedNodeNameNotifier.value;
    final isExpanded = _expandedNodes.contains(node.name);

    return InkWell(
      onTap: () => onTap(node),
      child: Container(
        height: 40.0, // Reduced height for less vertical padding
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
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 48,
                  minHeight: 48,
                ), // Match width of SizedBox
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
  final double verticalLineOffset;
  final double horizontalStubOffset;
  final int numChildren;

  const DottedLinePainter({
    required this.color,
    required this.verticalLineOffset,
    required this.horizontalStubOffset,
    required this.numChildren,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double dashWidth = 3;
    const double dashSpace = 3;
    const double rowHeight = 40.0; // Adjusted row height
    const double horizontalStubLength = 10;

    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // 1. Draw the main vertical dotted line
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(verticalLineOffset, startY),
        Offset(verticalLineOffset, startY + dashWidth),
        paint,
      );
      startY += dashWidth + dashSpace;
    }

    // 2. Draw horizontal stubs for each child node
    for (int i = 0; i < numChildren; i++) {
      double horizontalY = (i * rowHeight) + (rowHeight / 2.0);
      canvas.drawLine(
        Offset(verticalLineOffset, horizontalY),
        Offset(verticalLineOffset + horizontalStubLength, horizontalY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DottedLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.verticalLineOffset != verticalLineOffset ||
        oldDelegate.horizontalStubOffset != horizontalStubOffset ||
        oldDelegate.numChildren != numChildren;
  }
}
